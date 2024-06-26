#!/bin/bash

set -x

export SRC=`dirname $0`
cd $SRC

#define the directory of the srsLTE and opn5GS
srsLTE="/etc/srslte/"
open5GS="/etc/open5gs"

#Copy configuration files for srsLTE
sudo cp $SRC/uofr/etc_srslte/rr1.conf $srsLTE
sudo cp $SRC/uofr/etc_srslte/rr2.conf $srsLTE
sudo cp $SRC/uofr/etc_srslte/enb1.conf $srsLTE
sudo cp $SRC/uofr/etc_srslte/enb2.conf $srsLTE
sudo cp $SRC/uofr/etc_srslte/user_db.csv $srsLTE #for the time being it is not in use

#Copy configuration file of open5GS
sudo cp $open5GS/mme.yaml $open5GS/mme.yaml.bkp ##Keeping a backup
sudo cp $SRC/uofr/etc_open5gs/mme.yaml $open5GS #replace the mme config

#restart the mme to reflect the configurations
#https://docs.srsran.com/projects/4g/en/next/app_notes/source/handover/source/index.html
#https://open5gs.org/open5gs/docs/guide/01-quickstart/
sudo systemctl restart open5gs-mmed

##starting the gnb and ue
#check document /uofr/Command_4UE-2gNB.txt