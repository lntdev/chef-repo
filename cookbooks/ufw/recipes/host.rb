###################################################################################
# This recipe updates the hosts file of the system with its ip,fqdn,hostname values
###################################################################################
file = node['ufw']['filename']

# Get current date value
date1 = Mixlib::ShellOut.new("date +%Y%m%d").run_command.stdout

# backup hosts file before modifying it
cp = Mixlib::ShellOut.new("cp #{file} #{file}.#{date1}").run_command
cp1 = cp.exitstatus

# get ipaddress,fqdn,hostname values from system
ip = node['ipaddress']

puts ip
puts "========================================================================================"
fqdn1 = node['fqdn']
#host = date1 = Mixlib::ShellOut.new("cat /etch/hostname").run_command.stdout
host = node['hostname']
puts host
puts "========================================================================================="

# Modify hosts file if backup of it is created successfully
if cp1 == 0
  execute 'Remove entry of a line starting with machine ip from /etc/hosts' do
    command "grep -v \"^#{ip}\" #{file}.#{date1.chomp} > #{file}"
  end

  execute 'Append ip,fqdn,hostname values in /etc/hosts file' do
    command "echo '#{ip}\t#{fqdn1}\t#{host}' >> #{file}"
  end
else
  return;
end



=begin
puts "SYSTEM TAKING REBOOT TO INCORPORATE HOSTNAME CHANGE"
execute 'reboot after hostname change' do
  command 'cat /etc/hostname'
  action :nothing
  notifies :reboot_now, 'reboot[now]', :immediately
end
=end
