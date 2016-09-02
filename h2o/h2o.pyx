cimport ch2o


cdef class H2OConfig:
    cdef:
        ch2o.h2o_globalconf_t config

    def __cinit__(self):
        ch2o.h2o_config_init(&self.config)

    def __dealloc__(self):
        ch2o.h2o_config_dispose(&self.config)
