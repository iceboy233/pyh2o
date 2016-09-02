cimport ch2o


cdef class H2OConfig:
    cdef:
        ch2o.h2o_globalconf_t config

    def __cinit__(self):
        ch2o.h2o_config_init(&self.config)

    def __dealloc__(self):
        ch2o.h2o_config_dispose(&self.config)


cdef class H2OEvloop:
    cdef:
        ch2o.h2o_evloop_t* loop

    def __cinit__(self):
        self.loop = ch2o.h2o_evloop_create()

    def __dealloc__(self):
        pass  # leak

    def run(self):
        return ch2o.h2o_evloop_run(self.loop)
