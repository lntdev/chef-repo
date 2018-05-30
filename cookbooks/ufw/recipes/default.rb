#include_recipe 'ufw::usermod'
#include_recipe 'ufw::ssh'
#include_recipe 'ufw::ssh_key'
#include_recipe 'ufw::rsyslog'
#include_recipe 'ufw::ufw'
include_recipe "ufw::host"
#include_recipe 'ufw::reboot'


package 'vim' do
  action :install
end



