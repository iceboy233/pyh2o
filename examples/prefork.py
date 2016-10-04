import atexit
import h2o
import os
import signal
import socket

PREFORK = 4


class MySocket(h2o.Socket):
    def __init__(self, loop, sock, accept_ctx):
        super().create(loop, sock.fileno(), 0x20)
        self.sock = sock
        self.accept_ctx = accept_ctx

    def on_read(self):
        self.accept(self.accept_ctx)


class MyHandler(h2o.Handler):
    def on_req(self):
        return b'<h1>It works!</h1>'


if __name__ == '__main__':
    conf = h2o.GlobalConf()
    hostconf = h2o.HostConf(conf, b'default', 65535)
    my_handler = MyHandler(h2o.PathConf(hostconf, b'/test'))

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
    ctx = h2o.Context(loop, conf)
    sock_obj = MySocket(loop, sock, h2o.AcceptCtx(ctx, conf))
    sock_obj.read_start()

    while loop.run() == 0:
        pass
