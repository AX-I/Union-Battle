
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
    def send_response(self, code, response, body=''):
        self.send_response_only(code, response)
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        print('path', self.path)
        data = parse_qs(urlparse(self.path).query)

        # Add new player
        username = data['user'][0]
        self.server.players[username] = {}

        message = {'msg': 'Success', 'id':len(self.server.players)}

        msg = json.dumps(message).encode()
        print('sending', msg)
        self.send_response(200, 'Hello!', msg)


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
