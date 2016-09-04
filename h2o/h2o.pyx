from libc.stdint cimport uint16_t
cimport ch2o


cdef class GlobalConf:
    cdef:
        ch2o.h2o_globalconf_t conf

    def __cinit__(self):
        ch2o.h2o_config_init(&self.conf)

    def __dealloc__(self):
        ch2o.h2o_config_dispose(&self.conf)


cdef class HostConf:
    cdef:
        GlobalConf conf  # keeps reference for hostconf
        ch2o.h2o_hostconf_t* hostconf

    def __cinit__(self, GlobalConf conf, bytes host, uint16_t port):
        self.conf = conf
        self.hostconf = ch2o.h2o_config_register_host(
            &conf.conf,
            ch2o.h2o_iovec_init(<char*>host, len(host)),
            port)


cdef class PathConf:
    cdef:
        HostConf hostconf  # keeps reference for pathconf
        ch2o.h2o_pathconf_t* pathconf

    def __cinit__(self, HostConf hostconf, bytes path):
        self.hostconf = hostconf
        self.pathconf = ch2o.h2o_config_register_path(self.hostconf.hostconf, path)


cdef class Handler:
    cdef:
        PathConf pathconf  # keeps reference for handler
        ch2o.h2o_handler_t* handler

    def __cinit__(self, PathConf pathconf):
        self.pathconf = pathconf
        self.handler = ch2o.h2o_create_handler(self.pathconf.pathconf, sizeof(ch2o.h2o_handler_t))


cdef class EvLoop:
    cdef:
        ch2o.h2o_evloop_t* loop

    def __cinit__(self):
        self.loop = ch2o.h2o_evloop_create()

    def __dealloc__(self):
        pass  # FIXME(iceboy): leak

    def run(self):
        return ch2o.h2o_evloop_run(self.loop)


cdef class Socket:
    cdef:
        EvLoop loop
        ch2o.h2o_socket_t* sock

    def __init__(self, EvLoop loop, int sockfd, int flags):
        self.loop = loop
        self.sock = ch2o.h2o_evloop_socket_create(loop.loop, sockfd, flags)
        self.sock.data = <void*>self

    def __dealloc__(self):
        if self.sock:
            ch2o.h2o_socket_close(self.sock)

    def read_start(self):
        ch2o.h2o_socket_read_start(self.sock, on_socket_read)

    def on_read(self, status):
        pass


cdef void on_socket_read(ch2o.h2o_socket_t* sock, int status):
    (<Socket>sock.data).on_read(status)


cdef class Context:
    cdef:
        EvLoop loop  # keeps reference for ctx
        GlobalConf conf  # keeps reference for ctx
        ch2o.h2o_context_t ctx

    def __cinit__(self, EvLoop loop, GlobalConf conf):
        self.loop = loop
        self.conf = conf
        ch2o.h2o_context_init(&self.ctx, loop.loop, &conf.conf)
