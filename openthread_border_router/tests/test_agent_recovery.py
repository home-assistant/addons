"""Exercise the agent scripts with real s6 supervision in a disposable container.

Run from the repository root (no privileges or radio required):
  docker run --rm --entrypoint python3 -v "$PWD:/repo:ro" \
    homeassistant/amd64-addon-otbr:3.3.0 \
    /repo/openthread_border_router/tests/test_agent_recovery.py

Only the radio, Supervisor API, and network commands are replaced. The run,
finish, readiness, and runtime configuration scripts and s6 programs are real.
"""

import hashlib
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import unittest


ROOTFS = Path(__file__).resolve().parents[1] / "rootfs"

BASHIO = r'''#!/bin/bash
set -eEuo pipefail
bashio::config.exists() { return 1; }
bashio::config.has_value() {
    [[ "$1" == backbone_interface ]] ||
        { [[ "$1" == network_device ]] && [[ -f /tmp/otbr-test-state/network-device ]]; }
}
bashio::config.true() { [[ "$1" == firewall || "$1" == nat64 ]]; }
bashio::config() {
    case "$1" in
        device) echo /tmp/otbr-test-radio ;;
        backbone_interface) echo lo ;;
        baudrate) echo 460800 ;;
        otbr_log_level) echo notice ;;
        *) return 1 ;;
    esac
}
bashio::addon.port() { :; }
bashio::addon.ip_address() { echo 127.0.0.1; }
bashio::var.has_value() { [[ -n "$1" ]]; }
bashio::string.lower() { echo "${1,,}"; }
bashio::log.info() { echo "INFO: $*"; }
bashio::log.warning() { echo "WARNING: $*"; }
bashio::log.error() { echo "ERROR: $*"; }
bashio::exit.nok() { echo "ERROR: $*"; exit 1; }
# Keep the production delay in the first integration test. Other cases use a
# shorter delay so repeated failures and long device waits complete quickly.
sleep() {
    echo "$1" >> /tmp/otbr-test-state/sleeps
    if [[ -f /tmp/otbr-test-fast ]]; then
        /bin/sleep 0.02
    else
        /bin/sleep "$@"
    fi
}
script="$1"
shift
source "${script}" "$@"
'''

RADIO = r'''#!/usr/bin/python3
from pathlib import Path
import signal
import socket
import sys
import time

root = Path("/tmp/otbr-test-state")
starts = root / "starts"
count = int(starts.read_text()) + 1 if starts.exists() else 1
starts.write_text(str(count))
if (root / "fail-start").exists():
    sys.exit(1)
socket_path = Path("/run/openthread-wpan0.sock")
socket_path.unlink(missing_ok=True)
sock = socket.socket(socket.AF_UNIX)
sock.bind(str(socket_path))
signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
while True:
    if (root / "ignore-term").exists():
        signal.signal(signal.SIGTERM, signal.SIG_IGN)
    if (root / "crash").exists():
        (root / "crash").unlink()
        sys.exit(1)
    if (root / "clean-exit").exists():
        (root / "clean-exit").unlink()
        sys.exit(0)
    time.sleep(0.02)
'''


def write_executable(path, content):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)
    path.chmod(0o755)


class AgentRecoveryTests(unittest.TestCase):
    """Verify waiting, recovery, readiness, and stop behavior with real s6."""

    @classmethod
    def setUpClass(cls):
        """Overlay production scripts and isolate radio/network side effects."""
        if not Path("/.dockerenv").exists():
            raise RuntimeError("Run these tests only in the disposable Docker image.")
        # Overlay the app scripts onto the stock image, including removal of the
        # obsolete oneshot so s6-rc dependency compilation tests the final graph.
        services = Path("/etc/s6-overlay/s6-rc.d")
        shutil.rmtree(services / "otbr-agent-configure", ignore_errors=True)
        for path in services.rglob("otbr-agent-configure"):
            if path.is_file():
                path.unlink()
        for path in ROOTFS.rglob("*"):
            if path.is_file():
                destination = Path("/") / path.relative_to(ROOTFS)
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_bytes(path.read_bytes().replace(b"\r\n", b"\n"))
                if destination.name in {"run", "finish", "check"} or destination.suffix == ".sh":
                    destination.chmod(0o755)
        # Real with-contenv, stub Bashio API; match the real loader's strict flags.
        Path("/run/s6/container_environment").mkdir(parents=True, exist_ok=True)
        Path("/usr/lib/bashio/bashio").write_text(BASHIO)
        write_executable("/usr/sbin/otbr-agent", RADIO)
        Path("/usr/local/bin/migrate_otbr_settings.py").write_text('''from pathlib import Path
import sys
root = Path("/tmp/otbr-test-state")
with (root / "probes").open("a") as probes:
    probes.write("probe\\n")
sys.exit(1 if (root / "fail-probe").exists() else 0)
''')
        for name in ("iptables", "ip6tables"):
            write_executable(f"/usr/local/bin/{name}", '''#!/bin/bash
printf '%s %s\n' "$0" "$*" >> /tmp/otbr-test-state/network-commands
for arg in "$@"; do
    [[ "$arg" == -C || "$arg" == -L ]] && exit 1
done
exit 0
''')
        write_executable("/usr/local/bin/ipset", '''#!/bin/bash
[[ "$1" == list ]] && exit 1
exit 0
''')
        write_executable("/usr/local/bin/nc", "#!/bin/bash\nexit 0\n")
        write_executable("/usr/local/bin/ot-ctl", '''#!/bin/bash
printf '%s:%s\n' "$(cat /tmp/otbr-test-state/starts)" "$*" >> /tmp/otbr-test-state/configured
[[ ! -f /tmp/otbr-test-state/fail-configure ]]
''')
        Path("/run/s6-linux-init-container-results").mkdir(exist_ok=True)
        write_executable("/run/s6/basedir/bin/halt", "#!/bin/bash\ntouch /tmp/otbr-test-state/halted\n")
        Path("/data/thread").mkdir(parents=True, exist_ok=True)
        Path("/data/thread/test.data").write_bytes(b"saved thread dataset fixture")

    def setUp(self):
        """Create a fresh supervised service and a serial-device fixture."""
        self.state = Path("/tmp/otbr-test-state")
        shutil.rmtree(self.state, ignore_errors=True)
        self.state.mkdir()
        for name in ("/run/otbr-agent-restarting", "/run/otbr-agent-recovery-count", "/run/otbr-agent-started",
                     "/run/openthread-wpan0.sock", "/tmp/otbr-test-radio",
                     "/tmp/ttyOTBR",
                     "/run/s6-linux-init-container-results/exitcode"):
            Path(name).unlink(missing_ok=True)
        Path("/tmp/otbr-test-radio").symlink_to("/dev/null")
        Path("/tmp/otbr-test-fast").touch()
        self.temp = tempfile.TemporaryDirectory()
        self.service = Path(self.temp.name)
        original = Path("/etc/s6-overlay/s6-rc.d/otbr-agent")
        for name in ("run", "finish", "notification-fd"):
            shutil.copy2(original / name, self.service / name)
        shutil.copytree(original / "data", self.service / "data")
        self.log = (self.state / "log").open("w")
        self.supervisor = None

    def start(self):
        """Launch real s6 supervision without launching container init."""
        self.supervisor = subprocess.Popen(["s6-supervise", str(self.service)], stdout=self.log, stderr=self.log)

    def wait_for(self, predicate, timeout=8):
        """Wait for observable behavior, including service logs on failure."""
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            if predicate():
                return
            time.sleep(0.02)
        self.fail("Timed out:\n" + (self.state / "log").read_text())

    def status(self, field):
        """Read one field from the real supervisor's service status."""
        result = subprocess.run(["s6-svstat", "-o", field, str(self.service)], capture_output=True, text=True)
        return result.stdout.strip()

    def ready(self):
        """Wait for readiness after runtime configuration completes."""
        self.wait_for(lambda: self.status("ready") == "true")

    def crash(self):
        """Make the radio fixture exit as it would on a serial EOF."""
        (self.state / "crash").touch()

    def tearDown(self):
        """Stop only the service tree created by this test."""
        if self.supervisor:
            subprocess.run(["s6-svc", "-dx", str(self.service)], check=False)
            try:
                self.supervisor.wait(timeout=5)
            except subprocess.TimeoutExpired:
                subprocess.run(["s6-svc", "-k", str(self.service)], check=False)
                self.supervisor.wait(timeout=5)
        self.log.close()
        self.temp.cleanup()

    def test_disconnect_reconnect_reconfigures_before_ready(self):
        """Use the real retry delay and reconfigure the recovered agent."""
        Path("/tmp/otbr-test-fast").unlink()
        checksum = hashlib.sha256(Path("/data/thread/test.data").read_bytes()).digest()
        self.start()
        self.ready()
        Path("/tmp/otbr-test-radio").unlink()
        start = time.monotonic()
        self.crash()
        self.wait_for(lambda: "Waiting for RCP serial" in (self.state / "log").read_text(), timeout=15)
        self.assertGreaterEqual(time.monotonic() - start, 9.5)
        self.assertEqual(self.status("ready"), "false")
        Path("/tmp/otbr-test-radio").symlink_to("/dev/null")
        self.wait_for(lambda: (self.state / "starts").read_text() == "2")
        self.ready()
        commands = (self.state / "configured").read_text().splitlines()
        expected = ["trel enable", "nat64 enable", "dns server upstream enable",
                    "mdns localhostname", "mdns enable", "txpower 6"]
        for instance in (1, 2):
            for command in expected:
                self.assertTrue(any(line.startswith(f"{instance}:{command}") for line in commands))
        self.assertFalse((self.state / "halted").exists())
        self.assertEqual(checksum, hashlib.sha256(Path("/data/thread/test.data").read_bytes()).digest())

    def test_startup_failure_keeps_retrying_and_recovers(self):
        """Repeated launch failures must not halt the container."""
        (self.state / "fail-start").touch()
        self.start()
        self.wait_for(lambda: (self.state / "starts").exists()
                      and int((self.state / "starts").read_text() or "0") >= 6)
        self.assertEqual(self.status("wantedup"), "true")
        self.assertEqual(self.status("ready"), "false")
        self.assertFalse((self.state / "halted").exists())
        self.assertFalse((self.state / "configured").exists())
        (self.state / "fail-start").unlink()
        self.ready()
        self.assertFalse(Path("/run/s6-linux-init-container-results/exitcode").exists())

    def wait_for_long_device_wait(self):
        """Exercise more wait polls than all three previous 30-second attempts."""
        self.wait_for(lambda: (self.state / "sleeps").exists()
                      and (self.state / "sleeps").read_text().splitlines().count("1") >= 120)

    def test_missing_device_waits_without_repeated_probes(self):
        """A prolonged absence must wait without relaunching or probing."""
        self.start()
        self.ready()
        Path("/tmp/otbr-test-radio").unlink()
        self.crash()
        self.wait_for_long_device_wait()
        self.assertEqual((self.state / "starts").read_text(), "1")
        self.assertEqual((self.state / "probes").read_text().splitlines(), ["probe"])
        self.assertEqual((self.state / "log").read_text().count("Waiting for RCP serial"), 1)
        self.assertEqual(self.status("ready"), "false")
        self.assertFalse((self.state / "halted").exists())
        Path("/tmp/otbr-test-radio").symlink_to("/dev/null")
        self.wait_for(lambda: (self.state / "starts").read_text() == "2")
        self.ready()

    def test_missing_device_before_first_launch_waits(self):
        """Wait if a device disappears after Supervisor admits the container."""
        Path("/tmp/otbr-test-radio").unlink()
        self.start()
        self.wait_for_long_device_wait()
        self.assertFalse((self.state / "starts").exists())
        self.assertFalse((self.state / "probes").exists())
        self.assertEqual(self.status("ready"), "false")
        self.assertFalse((self.state / "halted").exists())
        Path("/tmp/otbr-test-radio").symlink_to("/dev/null")
        self.ready()

    def test_network_device_waits_for_socat_pty(self):
        """Network mode must wait on its PTY rather than the dummy device."""
        (self.state / "network-device").touch()
        self.start()
        self.wait_for(lambda: "Waiting for RCP serial device /tmp/ttyOTBR" in (self.state / "log").read_text())
        self.assertFalse((self.state / "probes").exists())
        Path("/tmp/ttyOTBR").symlink_to("/dev/null")
        self.ready()

    def test_repeated_short_runs_keep_recovering(self):
        """More than three successive runtime failures must still recover."""
        self.start()
        for instance in range(1, 8):
            self.wait_for(lambda: (self.state / "starts").exists()
                          and (self.state / "starts").read_text() == str(instance))
            self.ready()
            self.crash()
            self.wait_for(lambda: (self.state / "starts").read_text() == str(instance + 1))
        self.ready()
        self.assertEqual((self.state / "starts").read_text(), "8")
        self.assertFalse((self.state / "halted").exists())

    def test_unexpected_clean_exit_is_delayed_and_recovered(self):
        """An unrequested clean exit also needs a paced restart."""
        self.start()
        self.ready()
        (self.state / "clean-exit").touch()
        self.wait_for(lambda: (self.state / "starts").read_text() == "2")
        self.ready()
        self.assertIn("10", (self.state / "sleeps").read_text().splitlines())
        self.assertFalse((self.state / "halted").exists())

    def test_probe_failure_recovers(self):
        """A device can disappear between the presence check and the probe."""
        (self.state / "fail-probe").touch()
        self.start()
        self.wait_for(lambda: (self.state / "probes").exists()
                      and len((self.state / "probes").read_text().splitlines()) >= 5)
        self.assertFalse((self.state / "starts").exists())
        self.assertFalse((self.state / "halted").exists())
        (self.state / "fail-probe").unlink()
        self.ready()

    def test_configuration_failure_does_not_report_ready(self):
        """The recovered process must apply settings before readiness."""
        (self.state / "fail-configure").touch()
        self.start()
        self.wait_for(lambda: (self.state / "configured").exists())
        self.assertEqual(self.status("ready"), "false")
        (self.state / "fail-configure").unlink()
        self.ready()

    def test_intentional_forced_stop_does_not_recover(self):
        """A forced kill after an explicit stop must not schedule recovery."""
        (self.state / "ignore-term").touch()
        self.start()
        self.ready()
        time.sleep(0.05)
        subprocess.run(["s6-svc", "-d", str(self.service)], check=True)
        subprocess.run(["s6-svc", "-k", str(self.service)], check=True)
        self.wait_for(lambda: self.status("up") == "false")
        self.wait_for(lambda: "teardown completed" in (self.state / "log").read_text())
        self.wait_for(lambda: not Path("/run/otbr-agent-restarting").exists())
        self.assertFalse((self.state / "halted").exists())
        self.assertFalse(Path("/run/otbr-agent-restarting").exists())
        self.assertEqual((self.state / "starts").read_text(), "1")

    def test_stop_while_waiting_for_device(self):
        """Explicit stop must cancel a long serial-device wait promptly."""
        self.start()
        self.ready()
        Path("/tmp/otbr-test-radio").unlink()
        self.crash()
        self.wait_for(lambda: "Waiting for RCP serial" in (self.state / "log").read_text())
        subprocess.run(["s6-svc", "-d", str(self.service)], check=True)
        self.wait_for(lambda: self.status("up") == "false")
        self.wait_for(lambda: not Path("/run/otbr-agent-restarting").exists())
        self.assertEqual(self.status("wantedup"), "false")
        self.assertFalse((self.state / "halted").exists())
        self.assertEqual((self.state / "starts").read_text(), "1")

    def test_service_dependencies_compile(self):
        """The production service dependency graph must still compile."""
        output = self.service / "compiled"
        subprocess.run(["s6-rc-compile", str(output), "/etc/s6-overlay/s6-rc.d",
                        "/package/admin/s6-overlay/etc/s6-rc/sources"], check=True)


if __name__ == "__main__":
    unittest.main(verbosity=2)
