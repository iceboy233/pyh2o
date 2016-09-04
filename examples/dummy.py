import h2o
import os
import socket


class MySocket(h2o.Socket):
    def __init__(self, loop):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, True)
        self.sock.bind(('127.0.0.1', 8888))
        self.sock.listen()
        super().__init__(loop, self.sock.fileno(), 0x20)
        self.read_start()

    def on_read(self, status):
        print('on_read:', status)
        os.abort()


if __name__ == '__main__':
    conf = h2o.GlobalConf()
    hostconf = h2o.HostConf(conf, b'default', 65535)
    pathconf = h2o.PathConf(hostconf, b'/')
    handler = h2o.Handler(pathconf)
    loop = h2o.EvLoop()
    ctx = h2o.Context(loop, conf)
    sock = MySocket(loop)
    while loop.run() == 0:
        pass
