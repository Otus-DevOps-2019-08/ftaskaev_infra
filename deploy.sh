#!/bin/bash
sudo git clone -b monolith https://github.com/express42/reddit.git /opt/puma-server
cd /opt/puma-server && bundle install

puma -d

