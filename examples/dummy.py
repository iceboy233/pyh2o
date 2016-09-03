import h2o

if __name__ == '__main__':
    conf = h2o.GlobalConf()
    hostconf = h2o.HostConf(conf, b'default', 65535)
    pathconf = h2o.PathConf(hostconf, b'/')
    handler = h2o.Handler(pathconf)
    loop = h2o.EvLoop()
    context = h2o.Context(loop, conf)

    loop.run()
