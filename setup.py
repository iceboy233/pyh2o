import os, os.path
from Cython.Build import cythonize
from setuptools import setup
from setuptools.command.build_ext import build_ext as _build_ext
from setuptools.extension import Extension
from subprocess import Popen


def spawn(args, cwd):
    p = Popen(args, cwd=cwd)
    p.wait()
    if p.returncode != 0:
        raise Exception('command {} failed with exit status {}'.format(
            args[0], p.returncode))


class build_ext(_build_ext):
    def get_temp_dir(self, name):
        path = os.path.join(self.build_temp, name)
        if not os.path.exists(path):
            os.makedirs(path)
        return os.path.abspath(path)

    def run(self):
        os.environ['CFLAGS'] = os.environ.get('CFLAGS', '') + ' -fPIC'
        wslay_build_dir = self.get_temp_dir('wslay_build')
        h2o_build_dir = self.get_temp_dir('h2o_build')
        install_dir = self.get_temp_dir('install')

        # Build libwslay
        spawn(['cmake', os.path.abspath('deps/wslay'),
               '-DCMAKE_INSTALL_PREFIX=' + install_dir], wslay_build_dir)
        spawn(['make', 'install'], wslay_build_dir)

        # Build libh2o-evloop
        spawn(['cmake', os.path.abspath('deps/h2o'),
               '-DCMAKE_INSTALL_PREFIX=' + install_dir], h2o_build_dir)
        spawn(['make', 'libh2o-evloop'], h2o_build_dir)

        self.include_dirs.append('deps/h2o/include')
        self.include_dirs.append(os.path.join(install_dir, 'include'))
        self.library_dirs.append(h2o_build_dir)
        self.library_dirs.append(os.path.join(install_dir, 'lib'))
        return _build_ext.run(self)


setup(
    name = 'pyh2o',
    version = '0.0.1',
    description = 'H2O HTTP server library',
    url = 'https://github.com/iceb0y/pyh2o',
    author = 'iceboy',
    author_email = 'me\x40iceboy.org',
    license = 'MIT',
    classifiers = [
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Developers',
        'Topic :: Internet :: WWW/HTTP :: HTTP Servers',
        'Topic :: Software Development :: Libraries',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.2',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
    ],
    keywords = 'h2o http server library',
    packages = ['h2o'],
    include_package_data = True,
    ext_modules = cythonize([
        Extension(
            'h2o.h2o',
            ['h2o/h2o.pyx'],
            libraries=['h2o-evloop', 'ssl', 'wslay'],
            define_macros=[('H2O_USE_LIBUV', 0)],
        ),
    ]),
    test_suite = 'test',
    cmdclass = {'build_ext': build_ext},
)
