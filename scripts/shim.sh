#!/bin/bash -e

\wget -q --no-check-certificate https://raw.github.com/chetan/bixby-omnibus/master/scripts/bootstrap.sh -O - | /bin/bash | tee $HOME/bixby-omnibus.log
