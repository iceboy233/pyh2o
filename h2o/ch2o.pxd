from libc.stdint cimport uint16_t


cdef extern from "h2o.h":

    ctypedef struct h2o_iovec_t:
        pass

    h2o_iovec_t h2o_iovec_init(const void* base, size_t len)

    ctypedef struct h2o_globalconf_t:
        pass

    ctypedef struct h2o_hostconf_t:
        pass

    ctypedef struct h2o_pathconf_t:
        pass

    void h2o_config_init(h2o_globalconf_t* config)
    h2o_hostconf_t* h2o_config_register_host(h2o_globalconf_t* config, h2o_iovec_t host, uint16_t port)
    h2o_pathconf_t* h2o_config_register_path(h2o_hostconf_t* hostconf, const char* path)
    void h2o_config_dispose(h2o_globalconf_t* config)

    ctypedef struct h2o_evloop_t:
        pass

    h2o_evloop_t* h2o_evloop_create()
    int h2o_evloop_run(h2o_evloop_t* loop)
