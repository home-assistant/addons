"""Run small webservice for oath."""
import json
import sys
from pathlib import Path
import threading
import time

import cherrypy
from requests_oauthlib import OAuth2Session
from google.oauth2.credentials import Credentials

HEADERS = str("""
  <link rel="icon" href="/static/favicon.ico?v=1">
  <link href="/static/css/style.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet">
""")

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
        """Landing page."""
        return str("""<html>
          <head>{headers}</head>
          <body>
            <form method="get" action="token">
              <div class="card">
                <div class="card-content">
                  <img src="/static/logo.png" alt="Google Assistant Logo" />
                  <h1>Google Assistant SDK</h1>
                  <p>Initial setup</p>
                  <ol>
                    <li><a href="{url}" target="_blank">Get a code from Google here</a></li>
                    <li><input type="text" value="" name="token" placeholder="Paste the code here" /></li>
                  </ol>
                </div>
                <div class="card-actions">
                  <button type="submit">CONNECT</button>
                </div>
              </div>
            </form>
          </body>
        </html>""").format(url=self.auth_url, headers=HEADERS)

    @cherrypy.expose
    def token(self, token):
        """Read access token and process it."""
        try:
            self.oauth2.fetch_token(self.user_data['token_uri'], client_secret=self.user_data['client_secret'], code=token)
        except Exception as e:
            cherrypy.log("Error with the given token: {error}".format(error=str(e)))
            cherrypy.log("Restarting authentication process.")
            raise cherrypy.HTTPRedirect('/')

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

        threading.Thread(target=self.exit_app).start()
        return str("""<html>
          <head>{headers}</head>
          <body>
            <div class="card">
              <div class="card-content">
                <img src="/static/logo.png" alt="Google Assistant Logo" />
                <h1>Google Assistant SDK</h1>
                <p>Setup completed.</p>
                <p>You can now close this window.</p>
              </div>
            </div>
          </body>
        </html>""").format(url=self.auth_url, headers=HEADERS)

    def exit_app(self):
      time.sleep(2)
      cherrypy.engine.exit()

def hide_access_logs():
    """Hide file access logging for cleaner logs"""
    access_log = cherrypy.log.access_log
    for handler in tuple(access_log.handlers):
        access_log.removeHandler(handler)

if __name__ == '__main__':
    oauth_json = Path(sys.argv[1])
    cred_json = Path(sys.argv[2])

    with oauth_json.open('r') as data:
        user_data = json.load(data)['installed']

    hide_access_logs()
    cherrypy.config.update({'server.socket_port': 9324, 'server.socket_host': '0.0.0.0'})
    cherrypy.quickstart(oauth2Site(user_data, cred_json), config={
        '/static': { 
            'tools.staticdir.on': True,
            'tools.staticdir.dir': '/usr/share/public'
        }
    })
