.PHONY: compile

compile:
	cython h2o/h2o.pyx
	python3 setup.py build_ext --inplace
