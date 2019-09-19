#!/bin/bash
source /opt/rh/rh-ruby24/enable
export X_SCLS="`scl enable rh-ruby24 'echo $X_SCLS'`"

git clone -b monolith https://github.com/express42/reddit.git /opt/puma-server
cd /opt/puma-server && bundle install

puma -d

