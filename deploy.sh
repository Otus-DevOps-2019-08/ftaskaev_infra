#!/bin/bash
git clone -b monolith https://github.com/express42/reddit.git /opt/puma-server
cd /opt/puma-server && bundle install

/opt/puma-server/puma -d

