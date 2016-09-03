from libc.stdint cimport uint16_t
cimport ch2o


cdef class GlobalConf:
    cdef:
        ch2o.h2o_globalconf_t config

    def __cinit__(self):
        ch2o.h2o_config_init(&self.config)

    def __dealloc__(self):
        ch2o.h2o_config_dispose(&self.config)

    def register_host(self, bytes host, uint16_t port):
        return HostConf(self, host, port)


cdef class HostConf:
    cdef:
        GlobalConf config  # keeps reference for hostconf
        ch2o.h2o_hostconf_t* hostconf

    def __cinit__(self, GlobalConf config, bytes host, uint16_t port):
        self.config = config
        self.hostconf = ch2o.h2o_config_register_host(
            &config.config,
            ch2o.h2o_iovec_init(<char*>host, len(host)),
            port)

    def register_path(self, bytes path):
        ch2o.h2o_config_register_path(self.hostconf, path)


cdef class EvLoop:
    cdef:
        ch2o.h2o_evloop_t* loop

    def __cinit__(self):
        self.loop = ch2o.h2o_evloop_create()

    def __dealloc__(self):
        pass  # FIXME(iceboy): leak

    def run(self):
        return ch2o.h2o_evloop_run(self.loop)
