import atexit
import h2o
import os
import signal
import socket

PREFORK = 4

config = h2o.Config()
host = config.add_host(b'default', 65535)
host.add_path(b'/test').add_handler(lambda request: b'<h1>It works!</h1>')

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, True)
sock.bind(('127.0.0.1', 8888))
sock.listen()

for i in range(1, PREFORK):
    pid = os.fork()
    if not pid:
        break
    else:
        atexit.register(lambda: os.kill(pid, signal.SIGTERM))

loop = h2o.Loop()
loop.start_accept(sock.fileno(), config)

while loop.run() == 0:
    pass
