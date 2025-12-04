
# python UBServer.py -ip xxx.xx.xx -ssl 1

from http.server import *
from urllib.parse import urlparse, parse_qs
import socket
import json
import argparse
import time
import ssl

CERT_FILE = 'example_cert.pem'
KEY_FILE = 'example_key.pem'

welcome_msg = '''
<style>
body {background:#444; color:#fff; font-size:120%;}
h1 {text-align:center; margin-top:1em;
 font-family:Stencil; font-weight:normal;}
p {text-align:center;}
</style>
<body>
<h1>Welcome!</h1>
<p>Connection success. You can close this tab and return to the game.</p>
</body>
'''

class UnionServer(HTTPServer):
    def __init__(self, address, handler, use_ssl=False):
        super().__init__(address, handler)

        # Holds all player data
        self.players = {}

        self.seed = int(time.time())

        if use_ssl:
            ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
            ssl_context.load_cert_chain(CERT_FILE, KEY_FILE)
            self.socket = ssl_context.wrap_socket(self.socket, server_side=True)


class UnionHandler(BaseHTTPRequestHandler):

    # Godot requires a Content-Length
    # https://github.com/godotengine/godot/issues/20272
    def send_response(self, code, payload):
        self.send_response_only(code, '')
        if type(payload) is str:
            body = payload.encode()
        else:
            body = json.dumps(payload).encode()
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        #print('get', self.path)

        path = urlparse(self.path).path
        if path == '/join':
            self.addPlayer()
        elif path == '/fetch':
            self.sendUpdates()
        else:
            self.send_response(200, welcome_msg)

    def do_POST(self):
        print('post', self.path)

        path = urlparse(self.path).path

        n = int(self.headers.get("Content-Length"))
        raw = self.rfile.read(n).decode("utf-8")
        print('  data', raw)
        jdata = json.loads(raw)

        if path == '/update':
            self.recvUpdates(jdata)
        elif path == '/action':
            self.action(jdata)

    def addPlayer(self):
        data = parse_qs(urlparse(self.path).query)

        # Add new player
        if 'user' not in data:
            self.send_response(400, 'Please input a username!')
            return

        username = data['user'][0]

        if username in {p['user'] for p in self.server.players.values()}:
            self.send_response(400, 'Username is already taken!')
            return

        if len(self.server.players) >= 4:
            self.server.players = {}

        player_id = len(self.server.players)
        self.server.players[player_id] = {'user':username, 'actions':[]}

        msg = {'msg': 'Success', 'id':player_id, 'seed': self.server.seed}

        print('sending', msg)
        self.send_response(200, msg)

    def sendUpdates(self):
        data = parse_qs(urlparse(self.path).query)

        self.send_response(200, self.server.players)

    def recvUpdates(self, jdata):
        data = parse_qs(urlparse(self.path).query)
        player_id = int(data['id'][0])

        if 'endTurn' in data:
            self.server.players[player_id]['endTurn'] = data['endTurn'][0]

        self.server.players[player_id]['data'] = jdata

        self.send_response(200, 'Received update')

    def action(self, jdata):
        data = parse_qs(urlparse(self.path).query)
        player_id = int(data['id'][0])

        if 'card' in jdata or 'vote' in jdata:
            self.server.players[player_id]['actions'] = [jdata]

        self.send_response(200, 'Received action')


def run(ip, use_ssl=False):
    addr = (ip, 6400)
    print("Hosting server on", addr)
    httpd = UnionServer(addr, UnionHandler, use_ssl)
    httpd.serve_forever()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-ip', type=str, default='', 
                        help='IP address to bind')
    parser.add_argument('-ssl', type=int, default=0,
                        help='Whether to use SSL')
    args = parser.parse_args()
    run(args.ip, args.ssl)
