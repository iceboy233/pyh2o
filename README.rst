pyh2o
=====
.. image:: https://travis-ci.org/iceb0y/pyh2o.svg?branch=master
    :target: https://travis-ci.org/iceb0y/pyh2o

The pyh2o module provides Python binding for the `H2O HTTP server
<https://github.com/h2o/h2o>`_. Specifically, it provides high performance
HTTP 1/2 and websocket server for Python.

Prerequisites
-------------
* Python 2.6+ or 3.2+
* cmake 2.8.12+
* openssl 1.0.2+

Getting Started
---------------
Initialize submodules by :code:`git submodule update --init --recursive`.

* Build: :code:`python setup.py build`
* Test: :code:`python setup.py test`
* Clean: :code:`python setup.py clean`

End to end test brings up a real server and make requests to it.

Example
-------
Below is an example of serving static content.

.. code:: python

    import h2o
    import socket

    class Handler(h2o.Handler):
        def on_req(self):
            self.res_status = 200
            self.send_inline(b'Hello, world!')
            return 0

    config = h2o.Config()
    host = config.add_host(b'default', 65535)
    host.add_path(b'/plaintext').add_handler(Handler)

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, True)
    sock.bind(('127.0.0.1', 8888))
    sock.listen(0)

    loop = h2o.Loop()
    loop.start_accept(sock.fileno(), config)
    while loop.run() == 0:
        pass
