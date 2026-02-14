import asyncio
import argparse
import datetime
import re
import zigpy.serial
from pathlib import Path
from serialx import PinState

from enum import Enum
from universal_silabs_flasher.spinel import (
    SpinelProtocol,
    CommandID,
    PropertyID,
    ResetReason,
)

CONNECT_TIMEOUT = 10
AFTER_DISCONNECT_DELAY = 1
SETTINGS_FILE_PATTERN = re.compile(r"^\d+_[0-9a-f]+\.data$")


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


async def get_adapter_hardware_addr(
    port: str, baudrate: int = 460800, flow_control: str | None = None
) -> str:
    loop = asyncio.get_running_loop()

    async with asyncio.timeout(CONNECT_TIMEOUT):
        _, protocol = await zigpy.serial.create_serial_connection(
            loop=loop,
            protocol_factory=SpinelProtocol,
            url=port,
            baudrate=baudrate,
            flow_control=flow_control,
            # OTBR uses `uart-init-deassert` when flow control is disabled
            rtsdtr_on_open=(
                PinState.HIGH if flow_control == "hardware" else PinState.LOW
            ),
            rtsdtr_on_close=PinState.LOW,
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
        if not SETTINGS_FILE_PATTERN.match(settings_path.name):
            continue

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
            print(
                f"Adapter settings file {expected_settings_path} is the most recently used, skipping"
            )
            return

        # If the settings file is old, we should "delete" it
        print(
            f"Settings file for adapter {hwaddr} already exists at {expected_settings_path} but appears to be old, archiving"
        )
        backup_file(expected_settings_path)

    # Write back a new settings file that keeps only a few keys
    new_settings = [
        (key, value)
        for key, value in most_recent_settings
        if key
        in (
            OtbrSettingsKey.ACTIVE_DATASET,
            OtbrSettingsKey.PENDING_DATASET,
            OtbrSettingsKey.CHILD_INFO,
        )
    ]

    expected_settings_path.write_bytes(serialize_otbr_settings(new_settings))
    print(f"Wrote new settings file to {expected_settings_path}")

    await asyncio.sleep(AFTER_DISCONNECT_DELAY)


if __name__ == "__main__":
    import coloredlogs

    coloredlogs.install(level="DEBUG")
    asyncio.run(main())
