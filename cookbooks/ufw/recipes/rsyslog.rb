
package 'rysyslog' do
  action :install
  ignore_failure true
end

template '/etc/rsyslog.d/10-rsyslog.conf' do
  source '10-rsyslog.conf.erb'
  owner 'root'
  group 'root'
  mode '0755'
end
