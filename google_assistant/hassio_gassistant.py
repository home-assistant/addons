"""Hass.IO Google Assistant."""
import sys
from pathlib import Path

import google.oauth2.credentials

from google.assistant.library import Assistant
from google.assistant.library.event import EventType


def process_event(event):
    if event.type == EventType.ON_CONVERSATION_TURN_STARTED:
        print()

    print(event)

    if (event.type == EventType.ON_CONVERSATION_TURN_FINISHED and event.args and not event.args['with_follow_on_turn']):
        print()


if __name__ == '__main__':
    cred_json = Path(sys.argv[1])

    # open credentials
    with cred_json.open('r') as data:
        credentials = google.oauth2.credentials.Credentials(token=None, **json.load(data))

    # run assistant
    with Assistant(credentials) as assistant:
        for event in assistant.start():
            process_event(event)
