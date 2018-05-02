#include_recipe 'ufw::ufw'
#include_recipe 'ufw::ssh'
include_recipe "ufw::host"
include_recipe 'ufw::rsyslog'


package 'vim' do
  action :install
end



