#!/bin/bash
rm -rf dist
python setup.py sdist
python setup.py bdist_wheel
python3 setup.py bdist_wheel
for wheel in dist/*-linux*.whl; do
    python3 -m auditwheel repair $wheel -w dist/
    rm $wheel
done
