
from http.server import *
from urllib.parse import urlparse, parse_qs
import socket
import json
import argparse
import time

class UnionServer(HTTPServer):
    def __init__(self, address, handler):
        super().__init__(address, handler)

        # Holds all player data
        self.players = {}

        self.seed = int(time.time())


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
        print('get', self.path)

        path = urlparse(self.path).path
        if path == '/join':
            self.addPlayer()
        elif path == '/fetch':
            self.sendUpdates()

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

    def action(self, jdata):
        data = parse_qs(urlparse(self.path).query)
        player_id = int(data['id'][0])

        if 'card' in jdata:
            self.server.players[player_id]['actions'] = [jdata]


def run(ip):
    addr = (ip, 6400)
    print("Hosting server on", addr)
    httpd = UnionServer(addr, UnionHandler)
    httpd.serve_forever()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-ip', type=str, default='', 
                        help='IP address to bind')
    args = parser.parse_args()
    run(args.ip)
