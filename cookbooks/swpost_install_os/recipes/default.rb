#
# Cookbook Name:: swpost_install_os
# Recipe:: default
#
# Copyright 2018, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package 'apache2' do
  action :install
end

service 'apache2' do
  supports :status => true, :restart => true, :reload => true
  action [:stop, :enable]
end
