from libc.stdint cimport uint16_t
cimport ch2o


if H2O_USE_LIBUV: print('haha')


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
        self.pathconf = ch2o.h2o_config_register_path(self.hostconf.hostconf, path, 0)


cdef class Handler:
    cdef:
        PathConf pathconf  # keeps reference for handler
        ch2o.pyh2o_handler_t* handler

    def __init__(self, PathConf pathconf):
        self.pathconf = pathconf
        self.handler = <ch2o.pyh2o_handler_t*>ch2o.h2o_create_handler(
            self.pathconf.pathconf, sizeof(ch2o.pyh2o_handler_t))
        self.handler.base.on_req = on_handler_req
        self.handler.data = <void*>self

    def on_req(self):
        pass


cdef int on_handler_req(ch2o.h2o_handler_t* handler, ch2o.h2o_req_t* req):
    data = (<ch2o.pyh2o_handler_t*>handler).data
    body = (<Handler>data).on_req()

    # TODO(iceboy): header, streaming, etc.
    ch2o.h2o_send_inline(req, body, len(body))


cdef class Loop:
    cdef:
        ch2o.h2o_loop_t* loop

    def __cinit__(self):
        self.loop = ch2o.h2o_evloop_create()

    def __dealloc__(self):
        pass  # FIXME(iceboy): leak

    def run(self):
        return ch2o.h2o_evloop_run(self.loop)


cdef class Socket:
    cdef:
        ch2o.h2o_socket_t* sock
        Loop loop

    def __dealloc__(self):
        if self.sock:
            ch2o.h2o_socket_close(self.sock)

    def create(self, Loop loop, int sockfd, int flags):
        self.sock = ch2o.h2o_evloop_socket_create(loop.loop, sockfd, flags)
        self.sock.data = <void*>self

    def accept(self, AcceptCtx accept_ctx):
        sock = ch2o.h2o_evloop_socket_accept(self.sock)
        if not sock:
            return
        ch2o.h2o_accept(&accept_ctx.accept_ctx, sock)

    def read_start(self):
        ch2o.h2o_socket_read_start(self.sock, on_socket_read)

    def on_read(self):
        pass


cdef void on_socket_read(ch2o.h2o_socket_t* sock, const char* err):
    if err != NULL:
        return  # TODO(iceboy): error handling.
    (<Socket>sock.data).on_read()


cdef class Context:
    cdef:
        Loop loop  # keeps reference for ctx
        GlobalConf conf  # keeps reference for ctx
        ch2o.h2o_context_t ctx

    def __cinit__(self, Loop loop, GlobalConf conf):
        self.loop = loop
        self.conf = conf
        ch2o.h2o_context_init(&self.ctx, loop.loop, &conf.conf)


cdef class AcceptCtx:
    cdef:
        Context ctx
        GlobalConf conf
        ch2o.h2o_accept_ctx_t accept_ctx

    def __cinit__(self, Context ctx, GlobalConf conf):
        self.ctx = ctx
        self.conf = conf
        self.accept_ctx.ctx = &ctx.ctx
        self.accept_ctx.hosts = conf.conf.hosts
