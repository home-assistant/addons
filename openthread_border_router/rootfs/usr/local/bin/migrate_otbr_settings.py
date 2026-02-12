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
MIN_ACTIVE_DATASET_SIZE = 32


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


MIGRATED_KEYS = frozenset(
    {
        OtbrSettingsKey.ACTIVE_DATASET,
        OtbrSettingsKey.PENDING_DATASET,
        OtbrSettingsKey.CHILD_INFO,
    }
)


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
    active_dataset = get_active_dataset(settings)
    return active_dataset is not None and len(active_dataset) >= MIN_ACTIVE_DATASET_SIZE


def get_active_dataset(settings: list[tuple[OtbrSettingsKey, bytes]]) -> bytes | None:
    """Get the active dataset value from parsed settings."""
    for key, value in settings:
        if key == OtbrSettingsKey.ACTIVE_DATASET:
            return value
    return None


def filter_settings_for_migration(
    settings: list[tuple[OtbrSettingsKey, bytes]],
) -> list[tuple[OtbrSettingsKey, bytes]]:
    """Keep only the keys that should be preserved during migration."""
    return [(key, value) for key, value in settings if key in MIGRATED_KEYS]


def find_valid_settings_files(
    data_dir: Path,
) -> list[tuple[float, Path, list[tuple[OtbrSettingsKey, bytes]]]]:
    """Scan data directory for valid OTBR settings files, sorted newest first."""
    all_settings = []

    for settings_path in data_dir.glob("*.data"):
        if not SETTINGS_FILE_PATTERN.match(settings_path.name):
            continue

        mod_time = settings_path.stat().st_mtime
        otbr_settings = parse_otbr_settings(settings_path.read_bytes())

        # Ensure our parsing is valid
        assert serialize_otbr_settings(otbr_settings) == settings_path.read_bytes()

        if not is_valid_otbr_settings_file(otbr_settings):
            print(
                f"Settings file {settings_path} is not a valid OTBR settings file,"
                f" skipping"
            )
            continue

        all_settings.append((mod_time, settings_path, otbr_settings))

    all_settings.sort(reverse=True)
    return all_settings


def find_best_backup_settings(
    settings_path: Path,
) -> list[tuple[OtbrSettingsKey, bytes]] | None:
    """Find the most recent backup with a valid active dataset, filtered for migration."""
    backups = []

    for backup_path in settings_path.parent.glob(settings_path.name + ".backup-*"):
        otbr_settings = parse_otbr_settings(backup_path.read_bytes())

        active_dataset = get_active_dataset(otbr_settings)
        if active_dataset is None or len(active_dataset) < MIN_ACTIVE_DATASET_SIZE:
            continue

        mod_time = backup_path.stat().st_mtime
        backups.append((mod_time, backup_path, otbr_settings))

    if not backups:
        return None

    _, backup_path, backup_settings = sorted(backups, reverse=True)[0]
    print(f"Found valid backup: {backup_path}")

    return filter_settings_for_migration(backup_settings)


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


def try_recover_corrupted_settings(
    expected_settings_path: Path,
) -> list[tuple[OtbrSettingsKey, bytes]] | None:
    """If the expected settings file exists but has a corrupted active dataset,
    attempt recovery from a backup file.

    Returns recovered settings, or None if no recovery was needed or possible.
    Archives the corrupted file as a side effect when recovery succeeds.
    """
    if not expected_settings_path.exists():
        return None

    current_settings = parse_otbr_settings(expected_settings_path.read_bytes())

    if is_valid_otbr_settings_file(current_settings):
        return None

    # Active dataset is missing or too small, likely corrupted by erroneous
    # tmp file migration. Try to recover from a backup.
    active_dataset = get_active_dataset(current_settings)
    print(
        f"Active dataset in {expected_settings_path} is only"
        f" {len(active_dataset) if active_dataset else 0} bytes,"
        f" attempting recovery from backup"
    )

    recovered = find_best_backup_settings(expected_settings_path)

    if recovered is None:
        print("No valid backup found, cannot recover")
        return None

    backup_file(expected_settings_path)
    return recovered


def resolve_migration_settings(
    expected_settings_path: Path,
    all_settings: list[tuple[float, Path, list[tuple[OtbrSettingsKey, bytes]]]],
) -> list[tuple[OtbrSettingsKey, bytes]] | None:
    """Determine what settings should be written for the current adapter.

    Returns the settings to write, or None if no migration is needed.
    Archives stale settings files as a side effect.
    """
    _, most_recent_path, _ = all_settings[0]

    if most_recent_path == expected_settings_path:
        print(
            f"Adapter settings file {expected_settings_path} is the most"
            f" recently used, skipping"
        )
        return None

    # Adapter either has a stale settings file or no settings file at all.
    if expected_settings_path.exists():
        print(
            f"Settings file for adapter already exists at"
            f" {expected_settings_path} but appears to be old, archiving"
        )
        backup_file(expected_settings_path)

    return filter_settings_for_migration(all_settings[0][2])


async def main() -> None:
    parser = argparse.ArgumentParser(
        description="Migrate OTBR settings to new adapter"
    )
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

    flow_control = args.flow_control if args.flow_control != "none" else None

    hwaddr = await get_adapter_hardware_addr(
        port=args.adapter,
        baudrate=args.baudrate,
        flow_control=flow_control,
    )

    expected_settings_path = args.data_dir / hwaddr_to_filename(hwaddr)

    # If the current adapter's settings file has a corrupted dataset (e.g. from
    # an erroneous tmp file migration), try to restore it from a backup first.
    recovered = try_recover_corrupted_settings(expected_settings_path)

    if recovered is not None:
        expected_settings_path.write_bytes(serialize_otbr_settings(recovered))
        print(f"Recovered settings written to {expected_settings_path}")
        return

    all_settings = find_valid_settings_files(args.data_dir)

    if not all_settings:
        print("No existing settings files found, skipping")
        return

    new_settings = resolve_migration_settings(expected_settings_path, all_settings)

    if new_settings is None:
        return

    expected_settings_path.write_bytes(serialize_otbr_settings(new_settings))
    print(f"Wrote new settings file to {expected_settings_path}")

    await asyncio.sleep(AFTER_DISCONNECT_DELAY)


if __name__ == "__main__":
    import coloredlogs

    coloredlogs.install(level="DEBUG")
    asyncio.run(main())
