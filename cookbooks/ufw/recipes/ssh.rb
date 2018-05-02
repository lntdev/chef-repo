package 'openssh-server' do
  action :install
end
package 'vim' do
  action :install
end

service 'sshd' do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end


execute 'copy' do
  command 'cp /etc/ssh/sshd_config /etc/ssh/sshd_config_old'
  only_if { ::File.exist?('/etc/ssh/sshd_config')}
  action :run
end


template '/etc/ssh/sshd_config' do
  source 'sshd_config.erb'
  owner 'root'
  group 'root'
  mode '0640'
end

service 'sshd' do
  supports :status => true, :restart => true, :reload => true
  action [:restart]
end



