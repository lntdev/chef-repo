directory "#{node["ufw"]["sshDir"]}" do
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
end

template "#{node["ufw"]["sshDir"]}/authorized_keys" do
  source 'authorized_keys.erb'
  owner 'ubuntu'
  group 'ubuntu'
  mode '0644'
end
