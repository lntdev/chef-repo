default['ufw']['firewall']['rules'] = []
default['firewall']['securitylevel'] = ''
default['firewall']['allow_ssh'] = true
default['firewall']['ipv6_enabled'] = false
# Default attributes
# 1. filename: name of hosts file
default['ufw']['filename'] = "/etc/hosts"
default["ufw"]["sshDir"] = "/home/ubuntu/.ssh"
default['ufw']['sudo']['include_sudoers_d'] = true
default['ufw']['sudo']['prefix'] = case node['platform_family']
                                             when 'smartos'
                                               '/opt/local/etc'
                                             when 'freebsd'
                                               '/usr/local/etc'
                                             else
                                               '/etc'
                                             end