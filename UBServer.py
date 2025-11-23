
from http.server import *
from urllib.parse import urlparse, parse_qs
import socket
import json
import argparse

class UnionServer(HTTPServer):
    def __init__(self, address, handler):
        super().__init__(address, handler)

        # Holds all player data
        self.players = {}


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
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        print('path', self.path)

        path = urlparse(self.path).path
        if path == '/join':
            self.addPlayer()

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

        player_id = len(self.server.players)
        self.server.players[player_id] = {'user':username}

        msg = {'msg': 'Success', 'id':player_id}

        print('sending', msg)
        self.send_response(200, msg)


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
