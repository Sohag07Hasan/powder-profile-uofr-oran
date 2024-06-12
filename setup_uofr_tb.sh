#!/bin/bash

set -x

#Pull the files from github
git pull

#Install open5GS
export SRC=`dirname $0`
cd $SRC
. $SRC/uofr/setup-open5gs.sh

#allow routing for open5GS
. $SRC/uofr/setup-routing-for-open5gs.sh

##setup gnu_radio for zmq
. $SRC/uofr/setup-gnu-radio.sh

# Creating 2 dummy interface for 2 gNB 
# these interfaces will be used at E2 termination for the gNB
. $SRC/uofr/dummy_interfaces.sh

#update the config files at open5GS and SRSLTE
. $SRC/uofr/configure_tb.sh


