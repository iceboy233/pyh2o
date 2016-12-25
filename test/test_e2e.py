import h2o
import socket
import threading
import unittest
import urllib.request

SIMPLE_PATH = b'/simple'
SIMPLE_BODY = b'<h1>It works!</h1>'


class E2eTest(unittest.TestCase):
    def setUp(self):
        config = h2o.Config()
        host = config.add_host(b'default', 65535)
        host.add_path(SIMPLE_PATH).add_handler(self.handle_simple)

        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, True)
        self.sock.bind(('127.0.0.1', 0))
        self.sock.listen(0)

        self.loop = h2o.Loop()
        self.loop.start_accept(self.sock.fileno(), config)
        threading.Thread(target=self.run_loop, daemon=True).start()

    def run_loop(self):
        while self.loop.run() == 0:
            pass

    def get(self, path):
        return urllib.request.urlopen('http://127.0.0.1:{}{}'.format(
            self.sock.getsockname()[1], path.decode()))

    def handle_simple(self, request):
        self.assertEqual(request.method, b'GET')
        self.assertEqual(request.path, SIMPLE_PATH)
        return SIMPLE_BODY

    def test_simple(self):
        get_result = self.get(SIMPLE_PATH)
        self.assertEqual(get_result.read(), SIMPLE_BODY)

if __name__ == '__main__':
    unittest.main()
