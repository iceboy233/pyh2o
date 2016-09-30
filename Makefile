.PHONY: compile

compile:
	cython3 h2o/h2o.pyx
	python3 setup.py build_ext --inplace
