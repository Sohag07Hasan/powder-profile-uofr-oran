#!/bin/bash

#Import the public key used by the package management system.
sudo apt update
sudo apt install -y gnupg
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor

#Create the list file /etc/apt/sources.list.d/mongodb-org-6.0.list for your version of Ubuntu.
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

#Install the MongoDB packages.
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod #(if '/usr/bin/mongod' is not running)
sudo systemctl enable mongod #(ensure to automatically start it on system boot)

#Ubuntu makes it easy to install Open5GS as shown below
sudo add-apt-repository ppa:open5gs/latest
sudo apt update
sudo apt install -y open5gs

#Install the WebUI of Open5GS
#Debian and Ubuntu based Linux distributions can install Node.js as follows:
# Download and import the Nodesource GPG key
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

# Create deb repository
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

 # Run Update and Install
sudo apt update
sudo apt install nodejs -y

#You can now install WebUI of Open5GS.
curl -fsSL https://open5gs.org/open5gs/assets/webui/install | sudo -E bash -

 ##Now follow guideline mentioned here https://open5gs.org/open5gs/docs/guide/01-quickstart/