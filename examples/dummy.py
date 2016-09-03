import h2o

if __name__ == '__main__':
    global_conf = h2o.GlobalConf()
    host_conf = global_conf.register_host(b'default', 65535)
    host_conf.register_path(b'/')
    #loop = h2o.H2OEvLoop()
    #loop.run()
