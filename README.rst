The pyh2o module provides Python binding for the `H2O HTTP server
<https://github.com/h2o/h2o>`_.

Currently this is a toy project, PRs are welcome to make it useful.
Think of high performance, interaction with ``asyncio``, etc.

Build
-----

1. Use :code:`cmake -DBUILD_SHARED_LIBS=ON` to configure, :code:`make` and :code:`make install` libh2o-evloop.
2. :code:`make` pyh2o, if missing python imports, use :code:`pip` to install them.
