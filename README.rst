pyh2o
=====
.. image:: https://travis-ci.org/iceb0y/pyh2o.svg?branch=master
    :target: https://travis-ci.org/iceb0y/pyh2o

The pyh2o module provides Python binding for the `H2O HTTP server
<https://github.com/h2o/h2o>`_.

Currently this is a toy project, PRs are welcome to make it useful.
Think of high performance, interaction with ``asyncio``, etc.

Prerequisites
-------------
* Python 2.6+ or 3.2+
* cmake 2.8.12+
* openssl 1.0.2+

Development
-----------
Initialize submodules by :code:`git submodule update --init`.

Use :code:`make` to build, :code:`make clean` to clean, and :code:`make test` to run tests.

End to end test brings up a real server and make requests to it.
