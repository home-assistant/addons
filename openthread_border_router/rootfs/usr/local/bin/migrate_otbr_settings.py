import asyncio
import argparse
import dataclasses
import datetime
from typing import Self
import serialx
from pathlib import Path

from enum import Enum
from universal_silabs_flasher.spinel import (
    SpinelProtocol,
    CommandID,
    PropertyID,
    ResetReason,
)

CONNECT_TIMEOUT = 10
AFTER_DISCONNECT_DELAY = 1


class OtbrSettingsKey(Enum):
    ACTIVE_DATASET = 0x0001
    PENDING_DATASET = 0x0002
    NETWORK_INFO = 0x0003
    PARENT_INFO = 0x0004
    CHILD_INFO = 0x0005
    SLAAC_IID_SECRET_KEY = 0x0007
    DAD_INFO = 0x0008
    SRP_ECDSA_KEY = 0x000B
    SRP_CLIENT_INFO = 0x000C
    SRP_SERVER_INFO = 0x000D
    BR_ULA_PREFIX = 0x000F
    BR_ON_LINK_PREFIXES = 0x0010
    BORDER_AGENT_ID = 0x0011


def parse_otbr_settings(data: bytes) -> list[tuple[OtbrSettingsKey, bytes]]:
    """Parses an OTBR binary settings file."""
    settings = []

    while data:
        key_bytes = data[:2]
        if not key_bytes:
            break

        assert len(key_bytes) == 2
        key = int.from_bytes(key_bytes, "little")

        length_bytes = data[2:4]
        assert len(length_bytes) == 2

        length = int.from_bytes(length_bytes, "little")
        value = data[4 : 4 + length]
        assert len(value) == length

        settings.append((OtbrSettingsKey(key), value))
        data = data[4 + length :]

    return settings


def serialize_otbr_settings(settings: list[tuple[OtbrSettingsKey, bytes]]) -> bytes:
    """Serialize OTBR binary settings."""
    data = b""

    for key, value in settings:
        key_bytes = key.value.to_bytes(2, "little")
        length_bytes = len(value).to_bytes(2, "little")
        data += key_bytes + length_bytes + value

    return data


def is_valid_otbr_settings_file(settings: list[tuple[OtbrSettingsKey, bytes]]) -> bool:
    """Check if parsed settings represent a valid OTBR settings file."""
    return {OtbrSettingsKey.ACTIVE_DATASET} <= {key for key, _ in settings}


@dataclasses.dataclass
class NetworkInfo:
    """OpenThread NetworkInfo settings structure."""

    role: int
    device_mode: int
    rloc16: int
    key_sequence: int
    mle_frame_counter: int
    mac_frame_counter: int
    previous_partition_id: int
    ext_address: bytes
    ml_iid: bytes
    version: int

    @classmethod
    def from_bytes(cls, data: bytes) -> Self:
        return cls(
            role=data[0],
            device_mode=data[1],
            rloc16=int.from_bytes(data[2:4], "little"),
            key_sequence=int.from_bytes(data[4:8], "little"),
            mle_frame_counter=int.from_bytes(data[8:12], "little"),
            mac_frame_counter=int.from_bytes(data[12:16], "little"),
            previous_partition_id=int.from_bytes(data[16:20], "little"),
            ext_address=data[20:28],
            ml_iid=data[28:36],
            version=int.from_bytes(data[36:38], "little"),
        )

    def to_bytes(self) -> bytes:
        return (
            self.role.to_bytes(1, "little")
            + self.device_mode.to_bytes(1, "little")
            + self.rloc16.to_bytes(2, "little")
            + self.key_sequence.to_bytes(4, "little")
            + self.mle_frame_counter.to_bytes(4, "little")
            + self.mac_frame_counter.to_bytes(4, "little")
            + self.previous_partition_id.to_bytes(4, "little")
            + self.ext_address
            + self.ml_iid
            + self.version.to_bytes(2, "little")
        )


async def get_adapter_hardware_addr(
    port: str, baudrate: int = 460800, flow_control: str | None = None
) -> str:
    loop = asyncio.get_running_loop()

    async with asyncio.timeout(CONNECT_TIMEOUT):
        _, protocol = await serialx.create_serial_connection(
            loop,
            SpinelProtocol,
            url=port,
            baudrate=baudrate,
            xonxoff=(flow_control == "software"),
            rtscts=(flow_control == "hardware"),
            # OTBR uses `uart-init-deassert` when flow control is disabled
            rtsdtr_on_open=(
                serialx.PinState.HIGH
                if flow_control == "hardware"
                else serialx.PinState.LOW
            ),
            rtsdtr_on_close=serialx.PinState.LOW,
        )
        await protocol.wait_until_connected()

    await protocol.reset(ResetReason.STACK)

    try:
        rsp = await protocol.send_command(
            CommandID.PROP_VALUE_GET,
            PropertyID.HWADDR.serialize(),
        )
    finally:
        await protocol.disconnect()

    prop_id, hwaddr = PropertyID.deserialize(rsp.data)
    assert prop_id == PropertyID.HWADDR

    return hwaddr.hex()


def hwaddr_to_filename(hwaddr: str) -> str:
    port_offset = 0
    node_id = int(hwaddr, 16)

    return f"{port_offset}_{node_id:x}.data"


def backup_file(path: Path) -> Path:
    suffix = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    backup_path = path.with_suffix(path.suffix + f".backup-{suffix}")
    path.rename(backup_path)
    return backup_path


async def main() -> None:
    parser = argparse.ArgumentParser(description="Migrate OTBR settings to new adapter")
    parser.add_argument(
        "--data-dir", type=Path, help="Path to OTBR data directory", required=True
    )
    parser.add_argument(
        "--adapter", type=str, help="Serial port of the new adapter", required=True
    )
    parser.add_argument(
        "--baudrate", type=int, default=460800, help="Baudrate of the new adapter"
    )
    parser.add_argument(
        "--flow-control",
        type=str,
        default="none",
        help="Flow control for the serial connection (hardware, software, or none)",
    )
    parser.add_argument(
        "--thread-version",
        type=int,
        default=None,
        help="Thread version to set in NETWORK_INFO (4=1.3, 5=1.4)",
    )

    args = parser.parse_args()

    flow_control = args.flow_control

    if flow_control == "none":
        flow_control = None

    # First, read the hardware address of the new adapter
    hwaddr = await get_adapter_hardware_addr(
        port=args.adapter,
        baudrate=args.baudrate,
        flow_control=flow_control,
    )

    # Then, look at existing settings
    all_settings = []

    for settings_path in args.data_dir.glob("*.data"):
        mod_time = settings_path.stat().st_mtime
        otbr_settings = parse_otbr_settings(settings_path.read_bytes())

        # Ensure our parsing is valid
        assert serialize_otbr_settings(otbr_settings) == settings_path.read_bytes()

        if not is_valid_otbr_settings_file(otbr_settings):
            print(
                f"Settings file {settings_path} is not a valid OTBR settings file, skipping"
            )
            continue

        all_settings.append((mod_time, settings_path, otbr_settings))

    if not all_settings:
        print("No existing settings files found, skipping")
        return

    most_recent_settings_info = sorted(all_settings, reverse=True)[0]
    most_recent_settings_path = most_recent_settings_info[1]
    most_recent_settings = most_recent_settings_info[2]

    expected_settings_path = args.data_dir / hwaddr_to_filename(hwaddr)

    if expected_settings_path.exists():
        if most_recent_settings_path == expected_settings_path:
            # Check if thread version needs updating
            current_version = None
            for key, value in most_recent_settings:
                if key == OtbrSettingsKey.NETWORK_INFO:
                    current_version = NetworkInfo.from_bytes(value).version
                    break

            if args.thread_version is None or current_version == args.thread_version:
                print(
                    f"Adapter settings file {expected_settings_path} is the most recently used, skipping"
                )
                return

            print(
                f"Updating thread version from {current_version} to {args.thread_version}"
            )
        else:
            # If the settings file is old, we should "delete" it
            print(
                f"Settings file for adapter {hwaddr} already exists at {expected_settings_path} but appears to be old, archiving"
            )
            backup_file(expected_settings_path)

    # Write back a new settings file that keeps only a few keys
    new_settings = []

    for key, value in most_recent_settings:
        if key == OtbrSettingsKey.NETWORK_INFO and args.thread_version is not None:
            network_info = NetworkInfo.from_bytes(value)
            assert network_info.to_bytes() == value

            # To support transparent upgrades, we modify the Thread version
            network_info = dataclasses.replace(
                network_info, version=args.thread_version
            )
            new_settings.append((key, network_info.to_bytes()))
        elif key in (
            OtbrSettingsKey.ACTIVE_DATASET,
            OtbrSettingsKey.PENDING_DATASET,
            OtbrSettingsKey.CHILD_INFO,
            OtbrSettingsKey.NETWORK_INFO,
        ):
            new_settings.append((key, value))

    expected_settings_path.write_bytes(serialize_otbr_settings(new_settings))
    print(f"Wrote new settings file to {expected_settings_path}")

    await asyncio.sleep(AFTER_DISCONNECT_DELAY)


if __name__ == "__main__":
    import coloredlogs

    coloredlogs.install(level="DEBUG")
    asyncio.run(main())
