import h2o
import socket
import threading
import unittest
from six.moves import urllib

SIMPLE_PATH = b'/simple'
SIMPLE_BODY = b'<h1>It works!</h1>'
STREAM_PATH = b'/stream'
STREAM_BODIES = [b'<h1>', b'Stream', b'</h1>']


class SimpleHandler(h2o.Handler):
    def on_req(self):
        self.res_status = 200
        self.send_inline(SIMPLE_BODY)
        return 0


class StreamHandler(h2o.StreamHandler):
    def __init__(self):
        self.iterator = iter(STREAM_BODIES)

    def on_req(self):
        self.res_status = 200
        self.start_response()
        self.on_proceed()
        return 0

    def on_proceed(self):
        try:
            self.send([next(self.iterator)], h2o.H2O_SEND_STATE_IN_PROGRESS)
        except StopIteration:
            self.send([], h2o.H2O_SEND_STATE_FINAL)


class E2eTest(unittest.TestCase):
    def setUp(self):
        config = h2o.Config()
        host = config.add_host(b'default', 65535)
        host.add_path(SIMPLE_PATH).add_handler(SimpleHandler)
        host.add_path(STREAM_PATH).add_handler(StreamHandler)

        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, True)
        self.sock.bind(('127.0.0.1', 0))
        self.sock.listen(0)

        self.loop = h2o.Loop()
        self.loop.start_accept(self.sock.fileno(), config)
        thread = threading.Thread(target=self.run_loop)
        thread.daemon = True
        thread.start()

    def run_loop(self):
        while self.loop.run() == 0:
            pass

    def get(self, path):
        return urllib.request.urlopen('http://127.0.0.1:{}{}'.format(
            self.sock.getsockname()[1], path.decode()))

    def test_simple(self):
        get_result = self.get(SIMPLE_PATH)
        self.assertEqual(get_result.read(), SIMPLE_BODY)

    def test_stream(self):
        get_result = self.get(STREAM_PATH)
        self.assertEqual(get_result.read(), b''.join(STREAM_BODIES))

if __name__ == '__main__':
    unittest.main()
