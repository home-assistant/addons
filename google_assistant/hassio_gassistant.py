"""Hass.IO Google Assistant."""
import sys

from google.assistant.library import Assistant
from google.assistant.library.event import EventType

from google.oauth2 import service_account


def process_event(event):
    if event.type == EventType.ON_CONVERSATION_TURN_STARTED:
        print()

    print(event)

    if (event.type == EventType.ON_CONVERSATION_TURN_FINISHED and event.args and not event.args['with_follow_on_turn']):
        print()


if __name__ == '__main__':
    credentials = service_account.Credentials.from_service_account_file(sys.argv[1])
    scoped_credentials = credentials.with_scopes(['https://www.googleapis.com/auth/assistant-sdk-prototype'])

    with Assistant(scoped_credentials) as assistant:
        for event in assistant.start():
            process_event(event)
