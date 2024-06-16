#!/usr/bin/sh
rg --color=always --line-number --no-heading --smart-case "${@:1:$#-1}" ${*: -1}


