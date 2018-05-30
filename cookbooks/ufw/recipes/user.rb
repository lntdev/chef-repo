user 'rundeck' do
  action :create
  comment 'rundeck User'
  home '/home/rundeck'
  shell '/bin/bash'
  password 'intel123'
  manage_home true
  end
prefix = node['ufw']['sudo']['prefix']

package 'sudo' do
  not_if 'which sudo'
end

if node['ufw']['sudo']['include_sudoers_d']
  directory "#{prefix}/sudoers.d" do
    mode '0755'
    owner 'root'
    group node['root_group']
  end
  cookbook_file "#{prefix}/sudoers.d/rundeck" do
    source 'rundeck'
    mode '0440'
    owner 'root'
    group node['root_group']
  end
end



 execute 'password change for rundeck' do
  command 'yes intel123 | passwd rundeck'
  action :run
  ignore_failure true
end


