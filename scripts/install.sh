#!/bin/sh

apt-get update
apt-get install -y  open-vm-tools
apt-get install -y  sqlite3 git
apt-get install -y  bc jq

mv /tmp/setup_dispatch /usr/local/bin/setup_dispatch
