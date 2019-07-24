#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer


class S(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.end_headers()
            self.wfile.write('Home Page'.encode('utf-8'))
        elif self.path == '/about':
            self.send_response(200)
            self.end_headers()
            self.wfile.write('Test Server'.encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write('Error 404'.encode('utf-8'))


def run(server_class=HTTPServer, handler_class=S, port=80):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    httpd.serve_forever()


if __name__ == "__main__":
    run()
