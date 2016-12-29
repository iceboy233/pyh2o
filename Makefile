.PHONY: build test clean

build:
	python3 setup.py build_ext --inplace

test: build
	python3 -m unittest

clean:
	python3 setup.py clean
