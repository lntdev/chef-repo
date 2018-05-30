#
# Cookbook Name:: ufw
# Recipe:: default
#
# Copyright 2018, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

node.default['firewall']['ipv6_enabled'] = false

#
firewall 'default' do
  action :install
end


service 'ufw' do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end


# leave this on by default
firewall_rule 'ssh' do
  port 60240
  action :create
  only_if { node['firewall']['allow_ssh'] }
end


firewall_rule 'allow world to ssh' do
  port      8800
  source    '192.168.1.0/24'
  direction :in
  command    :allow
end


execute 'logging on ' do
  command 'sudo ufw logging on'
  action :run
end
execute 'deny incoming' do
  command 'sudo ufw default deny incoming'
  action :run
end
execute 'deny outgoing' do
  command 'sudo ufw default allow outgoing'
  action :run
end
#execute 'add port for rsylog' do
#  command 'sudo ufw allow 514/tcp'
# action :run
#end

service 'ufw' do
  supports :status => true, :restart => true, :reload => true
  action [:restart, :enable]
end
