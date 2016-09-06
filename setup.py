import pkgconfig
from setuptools import setup, Extension

extension_args = pkgconfig.parse('libssl libh2o-evloop')
extension_args['define_macros'].add(('H2O_USE_LIBUV', 0))
extension_args['sources'].add('h2o/h2o.c')

setup(
    name = 'h2o',
    version = '0.0.1',
    packages = ['h2o'],
    ext_modules = [
        Extension(
            'h2o.h2o',
            **dict((key, list(value)) for key, value in extension_args.items())
        ),
    ],
)
