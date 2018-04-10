#!/bin/bash
#################################################
# This script tries to intelligently run either
# chef-client or chef-solo based on exsitence
# of client.rb file and if the server is reachable
#################################################
usage ()
{
  echo 'Usage : run_chef_command.sh <role> <json_file> '
  exit
}
if [ "$#" -ne 2 ]
then
  usage
fi

CLIENT_RB_PATH=/etc/chef/client.rb
RUN_CHEF_CLIENT=true
if [ ! -f "$CLIENT_RB_PATH" ]
then
        echo "$CLIENT_RB_PATH not found, can't run chef-client. Trying chef-solo ..."
        RUN_CHEF_CLIENT=false
fi

#if [ ! -f /home/deployer/$2.json ]
#then
#	echo "Json file missing"
#	exit 1
#fi
	
while read LINE
do
      if [[ $LINE =~ .*chef_server_url.* ]]
      then
          URL=`echo $LINE | cut -d " " -f 2 | cut -d "\"" -f 2 `
          sudo /usr/bin/curl --insecure $URL
          if [ $? -eq 0 ];then
             echo "Found chef-server. trying chef-client ..."
          else
             echo "Cannot connect to chef-server. Trying chef-solo ..."
             RUN_CHEF_CLIENT=false
          fi
      fi
done < $CLIENT_RB_PATH
   if [ "$RUN_CHEF_CLIENT" = true ];
    then
       sudo chef-client 
    else
       PRODUCT_NAME=`echo $2 | awk -F'_' '{print $2}'` 
       SOLO_FILE=/automation/$2/hcm-chef-automation/$PRODUCT_NAME/solo/partial-solo.rb
       cp $SOLO_FILE /home/deployer/solo.rb
       echo "cookbook_path ['/chef-repo/cookbooks','/automation/$2/hcm-chef-automation/platform/cookbooks','/automation/$2/hcm-chef-automation/third_party/cookbooks']" >>  /home/deployer/solo.rb
      # echo "data_bag_path '/automation/$2/hcm-chef-automation/$PRODUCT_NAME/databags'" >> /home/deployer/solo.rb
       #echo "role_path     ['/automation/$2/hcm-chef-automation/$PRODUCT_NAME/roles']" >> /home/deployer/solo.rb
       sudo chef-solo -c /home/deployer/solo.rb -j /home/deployer/$2.json -o $1
    fi

