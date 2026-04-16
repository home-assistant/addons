import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent / "rootfs/usr/local/bin"))

import pytest
import shutil
from unittest.mock import patch
from migrate_otbr_settings import main, parse_otbr_settings, is_valid_otbr_settings_file


def copy_otbr_test_data(name: str, dst: Path) -> None:
    """Copy test data, preserving modification times and permissions."""
    path = Path(__file__).parent / "data" / name
    shutil.copytree(path, dst, dirs_exist_ok=True)


@pytest.mark.asyncio
async def test_migration_complex(tmp_path: Path, caplog) -> None:
    copy_otbr_test_data("otbr_settings_complex_running", tmp_path)

    with (
        patch(
            "migrate_otbr_settings.get_adapter_hardware_addr",
            return_value="f074bffffeaad34f",
            autospec=True,
        ),
        patch(
            "sys.argv",
            [sys.argv[0], "--data-dir", str(tmp_path), "--adapter", "/dev/null"],
        ),
        caplog.at_level("INFO", logger="migrate_otbr_settings"),
    ):
        await main()

    assert "0_f074bffffeaad34f.data is the most recently used, skipping" in caplog.text


@pytest.mark.asyncio
async def test_migration_broken(tmp_path: Path, caplog) -> None:
    copy_otbr_test_data("otbr_settings_broken", tmp_path)

    with (
        patch(
            "migrate_otbr_settings.get_adapter_hardware_addr",
            return_value="f074bffffeaad34f",
            autospec=True,
        ),
        patch(
            "sys.argv",
            [sys.argv[0], "--data-dir", str(tmp_path), "--adapter", "/dev/null"],
        ),
        caplog.at_level("DEBUG", logger="migrate_otbr_settings"),
    ):
        await main()

    assert "is only 8 bytes, attempting recovery from backup" in caplog.text
    assert "Found valid backup:" in caplog.text
    assert "Recovered settings written to" in caplog.text

    # Verify the recovered file has a real active dataset
    recovered = parse_otbr_settings((tmp_path / "0_f074bffffeaad34f.data").read_bytes())
    assert is_valid_otbr_settings_file(recovered)
