#!/bin/bash
# make home dir
printf "Executing $@\n\n"
[ -d "/home/$(whoami)/" ] || mkdir -p "/home/$(whoami)/"
# exec whatever cmd is passed
if [ "$1" == "exec" ]; then
  shift  # Remove "exec" from arguments
  exec sh -c "$1" -- "$@"
else
  sh -c "$1" -- "$@"
fi
