#!/bin/bash
sudo yum -y install centos-release-scl-rh centos-release-scl
sudo yum -y install rh-ruby24-ruby rh-ruby24-ruby-devel rh-ruby24-rubygem-bundler
sudo yum -y groupinstall "Development Tools"

