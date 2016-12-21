The pyh2o module provides Python binding for the `H2O HTTP server
<https://github.com/h2o/h2o>`_.

Currently this is a toy project, PRs are welcome to make it useful.
Think of high performance, interaction with ``asyncio``, etc.

Prerequisites
-------------
* Python 3+
* h2o 2.1+

Build
-----
1. Use :code:`cmake -DBUILD_SHARED_LIBS=ON` to configure, :code:`make`
   libh2o-evloop.
2. (Optional) :code:`make install` libh2o-evloop.
3. :code:`make` pyh2o. If libh2o-evloop is not installed, :code:`CFLAGS` and
   :code:`LDFLAGS` need to be modified.

Test
----
Use :code:`python3 -m unittest` to run tests.

End to end test brings up a real server and make requests to it.
