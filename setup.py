import pkgconfig
from setuptools import setup, Extension

setup(
    name = 'h2o',
    version = '0.0.1',
    packages = ['h2o'],
    ext_modules = [
        Extension(
            'h2o.h2o',
            sources = [
                'h2o/h2o.c',
            ],
            **dict((key, list(value))
                   for key, value in pkgconfig.parse('libssl libh2o-evloop').items())
        )
    ],
)
