#!/bin/bash
# make home dir
export HOME=/home/$(whoami)/
[ -d "/home/$(whoami)/" ] || mkdir -p "/home/$(whoami)/"
# start vtb
vtb "$@"