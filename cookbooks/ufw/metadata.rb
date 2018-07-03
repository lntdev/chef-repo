name             'ufw'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures ufw'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'
depends          'firewall', '>= 2.0'
supports 'ubuntu'
source_url 'https://github.com/chef-cookbooks/firewall'