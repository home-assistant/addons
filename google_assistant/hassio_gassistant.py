"""Hass.IO Google Assistant."""
import json
import sys
from pathlib import Path

import google.oauth2.credentials

from google.assistant.library import Assistant
from google.assistant.library.event import EventType
from google.assistant.library.device_helpers import register_device

DEVICE_CONFIG = "/data/device.json"


def process_event(event):
    if event.type == EventType.ON_CONVERSATION_TURN_STARTED:
        print()

    print(event)

    if (event.type == EventType.ON_CONVERSATION_TURN_FINISHED and event.args and not event.args['with_follow_on_turn']):
        print()


if __name__ == '__main__':
    cred_json = Path(sys.argv[1])
    device_json = Path(DEVICE_CONFIG)

    # open credentials
    with cred_json.open('r') as data:
        credentials = google.oauth2.credentials.Credentials(token=None, **json.load(data))

    # Read device info
    if device_json.exists():
        with device_json.open('r') as data:
            device_info = json.load(data)

        device_model_id = device_config['model_id']
        last_device_id = device_config.get('last_device_id', None)
    else:
        device_model_id = sys.argv[3]
        last_device_id = None
    
    # run assistant
    with Assistant(credentials, device_model_id) as assistant:
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

        for event in assistant.start():
            process_event(event)
