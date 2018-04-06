log_level                :info
log_location             STDOUT
node_name                'manu'
client_key               'Z:/chef-repo/.chef/manu.pem'
validation_client_name   'chef-validator'
validation_key           'Z:/z/chef-repo/.chef/chef-validator.pem'
chef_server_url          'https://chef-server-sw.iind.intel.com:443'
syntax_check_cache_path  'Z:/chef-repo/.chef/syntax_check_cache'
cookbook_path [ 'Z:/chef-repo/cookbooks' ]
ssl_verify_mode      :verify_none
verify_api_cert false
