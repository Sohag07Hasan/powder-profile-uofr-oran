#!/bin/bash

# Adding the GNU Radio PPA
sudo add-apt-repository ppa:gnuradio/gnuradio-releases -y

# Updating the package list
sudo apt-get update

# Installing GNU Radio and python3-packaging
sudo apt-get install gnuradio python3-packaging -y

