from libc.stdint cimport uint16_t


cdef extern from "h2o.h":

    ctypedef struct h2o_iovec_t:
        pass

    h2o_iovec_t h2o_iovec_init(const void* base, size_t len)

    ctypedef struct h2o_globalconf_t:
        h2o_hostconf_t** hosts

    ctypedef struct h2o_hostconf_t:
        pass

    ctypedef struct h2o_pathconf_t:
        pass

    void h2o_config_init(h2o_globalconf_t* conf)
    h2o_hostconf_t* h2o_config_register_host(h2o_globalconf_t* conf, h2o_iovec_t host, uint16_t port)
    h2o_pathconf_t* h2o_config_register_path(h2o_hostconf_t* hostconf, const char* path)
    void h2o_config_dispose(h2o_globalconf_t* conf)

    ctypedef struct h2o_handler_t:
        int (*on_req)(h2o_handler_t* self, h2o_req_t* req)

    h2o_handler_t* h2o_create_handler(h2o_pathconf_t* pathconf, size_t sz)

    ctypedef struct h2o_evloop_t:
        pass

    h2o_evloop_t* h2o_evloop_create()
    int h2o_evloop_run(h2o_evloop_t* loop)

    ctypedef struct h2o_context_t:
        pass

    void h2o_context_init(h2o_context_t* ctx, h2o_evloop_t* loop, h2o_globalconf_t* conf)

    ctypedef struct h2o_socket_t:
        void* data

    ctypedef void (*h2o_socket_cb)(h2o_socket_t* sock, int status)

    h2o_socket_t* h2o_evloop_socket_create(h2o_evloop_t* loop, int fd, int flags)
    h2o_socket_t* h2o_evloop_socket_accept(h2o_socket_t* listener)
    void h2o_socket_read_start(h2o_socket_t* sock, h2o_socket_cb cb)
    void h2o_socket_close(h2o_socket_t* sock)

    ctypedef struct h2o_accept_ctx_t:
        h2o_context_t* ctx
        h2o_hostconf_t** hosts

    void h2o_accept(h2o_accept_ctx_t* ctx, h2o_socket_t* sock)

    ctypedef struct h2o_req_t:
        pass


ctypedef struct pyh2o_handler_t:
    h2o_handler_t base
    void* data
