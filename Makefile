.PHONY: build test

build:
	python3 setup.py build_ext --inplace

test:
	python3 -m unittest
