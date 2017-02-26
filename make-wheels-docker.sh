#!/bin/bash
yum install -y zlib-devel

for PYBIN in /opt/python/*/bin; do
    "${PYBIN}/pip" install -r /io/requirements.txt
    "${PYBIN}/pip" wheel /io/ -w /wheelhouse/
done

AUDITWHEEL=$(which auditwheel)
REAL_AUDITWHEEL=$(readlink -f "$AUDITWHEEL")
AUDITWHEEL_PYBIN=$(dirname "$REAL_AUDITWHEEL")
"$AUDITWHEEL_PYBIN/pip" install auditwheel --upgrade

for whl in /wheelhouse/*.whl; do
    auditwheel repair "$whl" -w /io/wheelhouse
done
