#!/bin/bash
docker run --rm -v `pwd`:/io numenta/manylinux1_x86_64_centos6 /io/make-wheels-docker.sh
