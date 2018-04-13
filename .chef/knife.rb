log_level                :info
log_location             STDOUT
node_name                'manu'
client_key               '/home/manu/chef-repo/.chef/manu.pem'
validation_client_name   'chef-validator'
validation_key           '/home/manu/chef-repo/.chef/chef-validator.pem'
chef_server_url          'https://chef-server-sw.iind.intel.com:443'
syntax_check_cache_path  '/home/manu/chef-repo/.chef/syntax_check_cache'
cookbook_path [ '/home/manu/chef-repo/cookbooks' ]
ssl_verify_mode      :verify_none
verify_api_cert false
