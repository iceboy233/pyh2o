import os, os.path
from Cython.Build import cythonize
from distutils.command.build_ext import build_ext as _build_ext
from distutils.core import setup
from distutils.errors import DistutilsExecError
from distutils.extension import Extension
from subprocess import Popen


def spawn(args, cwd, env):
    combined_env = os.environ.copy()
    for name, value in env:
        combined_env[name] = value
    p = Popen(args, cwd=cwd, env=combined_env)
    p.wait()
    if p.returncode != 0:
        raise DistutilsExecError('command {} failed with exit status {}'.format(
            args[0], p.returncode))


class build_ext(_build_ext):
    def run(self):
        h2o_repo_dir = os.path.abspath(
            os.path.join(os.path.dirname(__file__), 'deps', 'h2o'))
        h2o_build_dir = os.path.join(self.build_temp, 'h2o')
        try:
            os.makedirs(h2o_build_dir)
        except OSError:
            pass
        spawn(['cmake', h2o_repo_dir], h2o_build_dir, [('CFLAGS', '-fPIC')])
        spawn(['make', 'libh2o-evloop'], h2o_build_dir, [])
        self.include_dirs.append(os.path.join(h2o_repo_dir, 'include'))
        self.library_dirs.append(h2o_build_dir)
        return _build_ext.run(self)


setup(
    name = 'h2o',
    version = '0.0.1',
    packages = ['h2o'],
    ext_modules = cythonize([
        Extension(
            'h2o.h2o',
            ['h2o/h2o.pyx'],
            libraries=['h2o-evloop', 'ssl'],
            define_macros=[('H2O_USE_LIBUV', 0)],
        ),
    ]),
    cmdclass = {'build_ext': build_ext},
)
