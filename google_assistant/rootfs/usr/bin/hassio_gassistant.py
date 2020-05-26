"""Home Assistant Google Assistant."""
import json
import sys
from pathlib import Path
import subprocess

import google.oauth2.credentials

from google.assistant.library import Assistant
from google.assistant.library.event import EventType
from google.assistant.library.device_helpers import register_device

DEVICE_CONFIG = "/data/device.json"

def process_event(event, use_feedback_sound):
    if event.type == EventType.ON_CONVERSATION_TURN_STARTED:
        if use_feedback_sound:
            subprocess.Popen(["aplay", "-q", "/usr/share/sounds/start_sound.wav"])
        print()

    if event.type == EventType.ON_RECOGNIZING_SPEECH_FINISHED:
        if use_feedback_sound:
            subprocess.Popen(["aplay", "-q", "/usr/share/sounds/end_sound.wav"])
        
    try:
        print(event)
    except UnicodeEncodeError as err:
        print("Can't print event: {}".format(err))

    if (event.type == EventType.ON_CONVERSATION_TURN_FINISHED and event.args and not event.args['with_follow_on_turn']):
        print()


if __name__ == '__main__':
    cred_json = Path(sys.argv[1])
    device_json = Path(DEVICE_CONFIG)
    use_feedback_sound = True if sys.argv[4] == "true" else False

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
            process_event(event, use_feedback_sound)

    print("Close Google Assistant SDK")
