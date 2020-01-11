"""Run small webservice for oath."""
import json
import sys
from pathlib import Path

import cherrypy
from requests_oauthlib import OAuth2Session
from google.oauth2.credentials import Credentials


class oauth2Site(object):
    """Website for handling oauth2."""

    def __init__(self, user_data, cred_file):
        """Init webpage."""
        self.cred_file = cred_file
        self.user_data = user_data

        self.oauth2 = OAuth2Session(
            self.user_data['client_id'],
            redirect_uri='urn:ietf:wg:oauth:2.0:oob',
            scope="https://www.googleapis.com/auth/assistant-sdk-prototype"
        )

        self.auth_url, _ = self.oauth2.authorization_url(self.user_data['auth_uri'], access_type='offline', prompt='consent')

    @cherrypy.expose
    def index(self):
        """Landingpage."""
        return str("""<html>
          <head></head>
          <body>
            <p>
                Get token from google: <a href="{url}" target="_blank">Authentication</a>
            </p>
            <form method="get" action="token">
              <input type="text" value="" name="token" />
              <button type="submit">Connect</button>
            </form>
          </body>
        </html>""").format(url=self.auth_url)

    @cherrypy.expose
    def token(self, token):
        """Read access token and process it."""
        self.oauth2.fetch_token(self.user_data['token_uri'], client_secret=self.user_data['client_secret'], code=token)

        # create credentials
        credentials = Credentials(
            self.oauth2.token['access_token'],
            refresh_token=self.oauth2.token.get('refresh_token'),
            token_uri=self.user_data['token_uri'],
            client_id=self.user_data['client_id'],
            client_secret=self.user_data['client_secret'],
            scopes=self.oauth2.scope
        )

        # write credentials json file
        with self.cred_file.open('w') as json_file:
            json_file.write(json.dumps({
                'refresh_token': credentials.refresh_token,
                'token_uri': credentials.token_uri,
                'client_id': credentials.client_id,
                'client_secret': credentials.client_secret,
                'scopes': credentials.scopes,
            }))

        sys.exit(0)


if __name__ == '__main__':
    oauth_json = Path(sys.argv[1])
    cred_json = Path(sys.argv[2])

    with oauth_json.open('r') as data:
        user_data = json.load(data)['installed']

    cherrypy.config.update({'server.socket_port': 9324, 'server.socket_host': '0.0.0.0'})
    cherrypy.quickstart(oauth2Site(user_data, cred_json))
