#!/bin/sh

smcp/bootstrap.sh

mips32-gcc-docker/run-in-docker.sh -i make
