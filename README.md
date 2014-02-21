# Bixby Omnibus

This project creates full-stack platform-specific packages for **bixby**!

It uses [omnibus](https://github.com/chetan/omnibus-ruby), [fpm](https://github.com/jordansissel/fpm) and [vagrant](http://www.vagrantup.com/).


## Overview

The build process involves spinning up several boxes using Vagrant, running the build via omnibus, and uploading the resulting packages to Amazon S3.

In addition, the 'latest' or 'latest-beta' version file should also be updated on S3.

Currently Ubuntu builds are done on Amazon EC2 while CentOS builds are done on Digital Ocean.


## Building

When logged in to the target platform, the following command will run the build:

``bash
\wget -q --no-check-certificate \
  https://raw.github.com/chetan/bixby-omnibus/master/scripts/shim.sh \
  -O - | CLEAN=1 /bin/bash
``

**Note:** It is advisable to run the build inside a screen to avoid issues due to disconnection.

### Multiple Platforms

Vagrant is used to run builds on each target platform. There are several scripts to assist in the process, located in the ``bin`` folder:

* ``build``: runs ``vagrant ssh`` on multiple boxes at once via forked subprocesses
* ``ubuntu`` and ``centos``: helpers for running vagrant up/halt/destroy commands on only those distributions
* ``list_packages``: list the package dir on each vagrant box
* ``upload_packages``: upload the package artifacts on each box to S3
* ``ssh-n``: simple utility to quickly ssh to a box by number (as opposed to name)
