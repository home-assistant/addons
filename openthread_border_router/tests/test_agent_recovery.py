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
bashio::config.has_value() { [[ "$1" == backbone_interface ]]; }
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
# shorter delay so exhaustion and unavailable-device tests complete quickly.
sleep() {
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
    time.sleep(0.02)
'''


def write_executable(path, content):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)
    path.chmod(0o755)


class AgentRecoveryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
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
        Path("/usr/local/bin/migrate_otbr_settings.py").write_text("# No migration in the fake radio fixture.\n")
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
''')
        Path("/run/s6-linux-init-container-results").mkdir(exist_ok=True)
        write_executable("/run/s6/basedir/bin/halt", "#!/bin/bash\ntouch /tmp/otbr-test-state/halted\n")
        Path("/data/thread").mkdir(parents=True, exist_ok=True)
        Path("/data/thread/test.data").write_bytes(b"saved thread dataset fixture")

    def setUp(self):
        self.state = Path("/tmp/otbr-test-state")
        shutil.rmtree(self.state, ignore_errors=True)
        self.state.mkdir()
        for name in ("/run/otbr-agent-recovery-count", "/run/otbr-agent-started",
                     "/run/openthread-wpan0.sock", "/tmp/otbr-test-radio",
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
        self.supervisor = subprocess.Popen(["s6-supervise", str(self.service)], stdout=self.log, stderr=self.log)

    def wait_for(self, predicate, timeout=8):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            if predicate():
                return
            time.sleep(0.02)
        self.fail("Timed out:\n" + (self.state / "log").read_text())

    def status(self, field):
        result = subprocess.run(["s6-svstat", "-o", field, str(self.service)], capture_output=True, text=True)
        return result.stdout.strip()

    def ready(self):
        self.wait_for(lambda: self.status("ready") == "true")

    def crash(self):
        (self.state / "crash").touch()

    def tearDown(self):
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

    def test_startup_failure_exhausts_budget(self):
        (self.state / "fail-start").touch()
        self.start()
        self.wait_for(lambda: (self.state / "halted").exists())
        self.assertEqual((self.state / "starts").read_text(), "4")
        self.assertEqual(self.status("wantedup"), "false")
        self.assertEqual(Path("/run/s6-linux-init-container-results/exitcode").read_text().strip(), "1")
        self.assertFalse((self.state / "configured").exists())

    def test_missing_device_exhausts_budget(self):
        self.start()
        self.ready()
        Path("/tmp/otbr-test-radio").unlink()
        self.crash()
        self.wait_for(lambda: (self.state / "halted").exists())
        self.assertEqual((self.state / "starts").read_text(), "1")
        self.assertIn("unavailable after 30 seconds", (self.state / "log").read_text())

    def test_repeated_short_runs_do_not_reset_budget(self):
        self.start()
        for instance in range(1, 5):
            self.wait_for(lambda: (self.state / "starts").exists()
                          and (self.state / "starts").read_text() == str(instance))
            self.ready()
            self.crash()
            if instance < 4:
                self.wait_for(lambda: (self.state / "starts").read_text() == str(instance + 1))
        self.wait_for(lambda: (self.state / "halted").exists())
        self.assertEqual((self.state / "starts").read_text(), "4")

    def test_stable_operation_resets_budget(self):
        self.start()
        self.ready()
        Path("/run/otbr-agent-recovery-count").write_text("3\n")
        Path("/run/otbr-agent-started").write_text(f"{int(time.time()) - 301}\n")
        self.crash()
        self.wait_for(lambda: (self.state / "starts").read_text() == "2")
        self.ready()
        self.assertEqual(Path("/run/otbr-agent-recovery-count").read_text().strip(), "1")
        self.assertFalse((self.state / "halted").exists())

    def test_intentional_forced_stop_does_not_recover(self):
        (self.state / "ignore-term").touch()
        self.start()
        self.ready()
        time.sleep(0.05)
        subprocess.run(["s6-svc", "-d", str(self.service)], check=True)
        subprocess.run(["s6-svc", "-k", str(self.service)], check=True)
        self.wait_for(lambda: self.status("up") == "false")
        self.wait_for(lambda: "teardown completed" in (self.state / "log").read_text())
        self.wait_for(lambda: not Path("/run/otbr-agent-started").exists())
        self.assertFalse((self.state / "halted").exists())
        self.assertFalse(Path("/run/otbr-agent-recovery-count").exists())
        self.assertEqual((self.state / "starts").read_text(), "1")

    def test_service_dependencies_compile(self):
        output = self.service / "compiled"
        subprocess.run(["s6-rc-compile", str(output), "/etc/s6-overlay/s6-rc.d",
                        "/package/admin/s6-overlay/etc/s6-rc/sources"], check=True)


if __name__ == "__main__":
    unittest.main(verbosity=2)
