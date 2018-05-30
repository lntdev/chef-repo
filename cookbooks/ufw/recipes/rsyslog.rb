
apt_package 'rsyslog' do
  action :install
end

template '/etc/rsyslog.d/10-rsyslog.conf' do
  source '10-rsyslog.conf.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

service 'rsyslog' do
  supports :status => true, :restart => true, :reload => true
  action [:restart]
end


