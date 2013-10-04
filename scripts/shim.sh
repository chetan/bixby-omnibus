#!/bin/bash -e

\wget -q --no-check-certificate https://raw.github.com/chetan/bixby-omnibus/master/scripts/bootstrap.sh -O - | /bin/bash 2>&1 | tee $HOME/bixby-omnibus.log
