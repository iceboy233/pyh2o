.PHONY: build test clean

PYTHON ?= python

build:
	${PYTHON} setup.py build_ext --inplace

test: build
	${PYTHON} -m unittest

clean:
	${PYTHON} setup.py clean
