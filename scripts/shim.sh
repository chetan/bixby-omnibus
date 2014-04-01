#!/bin/bash -e

rm -f go.sh
echo "cd bixby-omnibus && git pull -q && scripts/build.sh 2>&1 | tee $HOME/bixby-omnibus.log" > go.sh

nohup /bin/bash go.sh >/dev/null 2>nohup.err </dev/null &
