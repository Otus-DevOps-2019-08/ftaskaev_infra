#!/bin/bash
set -e

# Install reddit server
git clone -b monolith https://github.com/express42/reddit.git /opt/puma-server
cd /opt/puma-server && bundle install

# Add systemd unit file
tee /lib/systemd/system/reddit.service << EOF
[Unit]
Description=Reddit service

[Service]
WorkingDirectory=/opt/puma-server
ExecStart=/usr/local/bin/puma

[Install]
WantedBy=multi-user.target
EOF

# Enable reddit server
systemctl start reddit
systemctl enable reddit

