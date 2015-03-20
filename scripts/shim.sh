#!/bin/bash -e

# kicks off the build process, normally from bin/build util
#
# usage:
# \wget -q --no-check-certificate https://raw.github.com/chetan/bixby-omnibus/master/scripts/shim.sh -O - | /bin/bash -s
#
# optional ENV vars to pass to bash:
# BIXBY_GIT_REV=<sha>         build a specific revision
# CLEAN=1                     tell omnibus to do a clean build

rm -f go.sh
echo "cd bixby-omnibus && git pull -q && scripts/build.sh 2>&1 | tee $HOME/build.log" > go.sh

nohup /bin/bash go.sh >/dev/null 2>nohup.err </dev/null &
