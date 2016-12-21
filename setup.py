from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
    name = 'h2o',
    version = '0.0.1',
    packages = ['h2o'],
    ext_modules = cythonize([
        Extension(
            'h2o.h2o',
            ['h2o/h2o.pyx'],
            libraries=['h2o-evloop'],
            define_macros=[('H2O_USE_LIBUV', 0)],
        ),
    ]),
)
