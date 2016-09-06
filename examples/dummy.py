import h2o
import os
import socket


class MySocket(h2o.Socket):
    def __init__(self, loop, accept_ctx):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, True)
        self.sock.bind(('127.0.0.1', 8888))
        self.sock.listen()
        super().create(loop, self.sock.fileno(), 0x20)
        self.accept_ctx = accept_ctx

    def on_read(self, status):
        self.accept(self.accept_ctx)


class MyHandler(h2o.Handler):
    def on_req(self):
        print('on_req called')
        os.abort()



if __name__ == '__main__':
    conf = h2o.GlobalConf()
    hostconf = h2o.HostConf(conf, b'default', 65535)
    my_handler = MyHandler(h2o.PathConf(hostconf, b'/test'))

    loop = h2o.EvLoop()
    ctx = h2o.Context(loop, conf)
    sock = MySocket(loop, h2o.AcceptCtx(ctx, conf))
    sock.read_start()

    while loop.run() == 0:
        pass
