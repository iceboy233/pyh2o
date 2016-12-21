import h2o
import socket
import threading
import unittest
import urllib.request

SIMPLE_URL = b'/simple'
SIMPLE_BODY = b'<h1>It works!</h1>'


class E2eTest(unittest.TestCase):
    def setUp(self):
        config = h2o.Config()
        host = config.add_host(b'default', 65535)
        host.add_path(SIMPLE_URL).add_handler(lambda: SIMPLE_BODY)

        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, True)
        self.sock.bind(('127.0.0.1', 0))
        self.sock.listen()
        self.http_prefix = b'http://127.0.0.1:%d' % self.sock.getsockname()[1]

        self.loop = h2o.Loop()
        self.loop.start_accept(self.sock.fileno(), config)
        threading.Thread(target=self.run_loop, daemon=True).start()
    
    def run_loop(self):
        while self.loop.run() == 0:
            pass

    def get(self, url):
        return urllib.request.urlopen((self.http_prefix + url).decode()).read()

    def test_simple(self):
        self.assertEqual(self.get(SIMPLE_URL), SIMPLE_BODY)

if __name__ == '__main__':
    unittest.main()
