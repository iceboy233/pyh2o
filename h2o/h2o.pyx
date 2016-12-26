from cpython cimport Py_INCREF
from libc.stdint cimport uint16_t, INT32_MAX
cimport ch2o


cdef class Config:
    cdef ch2o.h2o_globalconf_t conf
    cdef list handler_refs

    def __cinit__(self):
        ch2o.h2o_config_init(&self.conf)
        self.handler_refs = list()

    def __dealloc__(self):
        ch2o.h2o_config_dispose(&self.conf)

    def add_host(self, bytes host, uint16_t port):
        hostconf = ch2o.h2o_config_register_host(
            &self.conf, ch2o.h2o_iovec_init(<char*>host, len(host)), port)
        result = Host()
        result.config = self
        result.hostconf = hostconf
        return result


cdef class Host:
    cdef Config config  # keeps reference for hostconf
    cdef ch2o.h2o_hostconf_t* hostconf

    def add_path(self, bytes path, int flags=0):
        pathconf = ch2o.h2o_config_register_path(self.hostconf, path, flags)
        result = Path()
        result.config = self.config
        result.pathconf = pathconf
        return result


cdef class Path:
    cdef Config config  # keeps reference for pathconf
    cdef ch2o.h2o_pathconf_t* pathconf

    def add_handler(self, handler_func):
        handler = <ch2o.pyh2o_handler_t*>ch2o.h2o_create_handler(
            self.pathconf, sizeof(ch2o.pyh2o_handler_t))
        handler.base.on_req = _handler_on_req
        handler.data = <void*>handler_func
        self.config.handler_refs.append(handler_func)


cdef int _handler_on_req(ch2o.h2o_handler_t* handler, ch2o.h2o_req_t* req) nogil:
    data = (<ch2o.pyh2o_handler_t*>handler).data
    with gil:
        request = Request()
        request.req = req
        body = (<object>data)(request)

        # TODO(iceboy): header, streaming, etc.
        req.res.status = 200
        ch2o.h2o_send_inline(req, body, len(body))


cdef class Request:
    cdef ch2o.h2o_req_t* req

    @property
    def authority(self):
        return _iovec_to_bytes(&self.req.authority)

    @property
    def method(self):
        return _iovec_to_bytes(&self.req.method)

    @property
    def path(self):
        return _iovec_to_bytes(&self.req.path)

    @property
    def version(self):
        return self.req.version


cdef bytes _iovec_to_bytes(ch2o.h2o_iovec_t* iovec):
    return iovec.base[:iovec.len]


H2O_SOCKET_FLAG_DONT_READ = 0x20


cdef class Loop:
    cdef ch2o.h2o_loop_t* loop

    def __cinit__(self):
        self.loop = ch2o.h2o_evloop_create()

    def __dealloc__(self):
        pass  # FIXME(iceboy): leak

    def start_accept(self, int sockfd, Config config,
                     int flags=H2O_SOCKET_FLAG_DONT_READ):
        sock = ch2o.h2o_evloop_socket_create(self.loop, sockfd, flags)
        accept_context = _AcceptContext()
        accept_context.config = config
        ch2o.h2o_context_init(&accept_context.context, self.loop, &config.conf)
        accept_context.accept_ctx.ctx = &accept_context.context
        accept_context.accept_ctx.hosts = config.conf.hosts
        Py_INCREF(accept_context)
        sock.data = <void*>accept_context
        ch2o.h2o_socket_read_start(sock, _socket_on_read)
        # FIXME(iceboy): leak

    def run(self):
        cdef ch2o.h2o_loop_t* loop = self.loop
        with nogil:
            result = ch2o.h2o_evloop_run(loop, INT32_MAX)
        return result


cdef class _AcceptContext:
    cdef Config config  # keeps reference for context and accept_ctx
    cdef ch2o.h2o_context_t context
    cdef ch2o.h2o_accept_ctx_t accept_ctx


cdef void _socket_on_read(ch2o.h2o_socket_t* sock, const char* err):
    if err:
        return  # TODO(iceboy): error handling.
    accept_sock = ch2o.h2o_evloop_socket_accept(sock)
    if not accept_sock:
        return  # TODO(iceboy): ???
    ch2o.h2o_accept(&(<_AcceptContext>sock.data).accept_ctx, accept_sock)
