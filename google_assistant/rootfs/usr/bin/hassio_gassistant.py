"""Home Assistant Google Assistant."""
import json
import sys
from pathlib import Path
import subprocess
import json
import google.oauth2.credentials

from google.assistant.library import Assistant
from google.assistant.library.event import EventType
from google.assistant.library.device_helpers import register_device

DEVICE_CONFIG = "/data/device.json"

PACAT_MAX_VOLUME = 65536

feedback = json.loads(sys.argv[4])
feedback_volume = feedback.get("volume", 0) * PACAT_MAX_VOLUME // 100

def play_sound(sound_file):
    if feedback["enable"] and feedback_volume > 0:
        subprocess.Popen(["paplay", "--volume={v}".format(v=feedback_volume), "/usr/share/sounds/{f}".format(f=sound_file)])

def process_event(event):
    if event.type == EventType.ON_CONVERSATION_TURN_STARTED:
        play_sound("start_sound.wav")
        print()

    if event.type == EventType.ON_RECOGNIZING_SPEECH_FINISHED:
        play_sound("end_sound.wav")
        
    try:
        print(event)
    except UnicodeEncodeError as err:
        print("Can't print event: {}".format(err))

    if (event.type == EventType.ON_CONVERSATION_TURN_FINISHED and event.args and not event.args['with_follow_on_turn']):
        print()


if __name__ == '__main__':
    cred_json = Path(sys.argv[1])
    device_json = Path(DEVICE_CONFIG)

    # Open credentials
    print("OAuth with Google")
    with cred_json.open('r') as data:
        credentials = google.oauth2.credentials.Credentials(token=None, **json.load(data))

    # Read device info
    print("Initialize device infos")
    if device_json.exists():
        with device_json.open('r') as data:
            device_info = json.load(data)

        device_model_id = device_info['model_id']
        last_device_id = device_info.get('last_device_id', None)
    else:
        device_model_id = sys.argv[3]
        last_device_id = None

    # Run assistant
    print("Run Google Assistant SDK")
    with Assistant(credentials, device_model_id) as assistant:
        events = assistant.start()
        device_id = assistant.device_id

        print("device_model_id: {}".format(device_model_id))
        print("device_id: {}".format(device_id))

        # Register device
        if last_device_id != device_id:
            register_device(sys.argv[2], credentials, device_model_id, device_id)
            with device_json.open('w') as dev_file:
                json.dump({
                    'last_device_id': device_id,
                    'model_id': device_model_id,
                }, dev_file)

        for event in events:
            process_event(event)

    print("Close Google Assistant SDK")
