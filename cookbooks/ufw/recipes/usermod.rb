case node[:platform]

when "ubuntu","debian"
#execute "usermod -s /bin/false -g sftp-users -p `mkpasswd bobsaget` bobdole && usermod -L bobdole" do
# execute 'change usermod' do
#   command 'usermod -l ubuntu test'
#   command 'groupmod -n ubuntu test'
#   command 'usermod -d /home/ubuntu -m ubuntu'
#   command 'usermod -c "ubuntu" ubuntu'
#   action :run
#   only_if "id test"
# end
#end

bash 'usermod ' do
     code <<-EOH
    usermod -l ubuntu test
   	groupmod -n ubuntu test
   	usermod -d /home/ubuntu -m ubuntu
   	usermod -c "ubuntu" ubuntu
	
	EOH
	only_if 'grep test /etc/passwd', :user => 'test'
end

end

execute 'password change' do
  command 'yes intel123 | passwd ubuntu'
  action :run
end
