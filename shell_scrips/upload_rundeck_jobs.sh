upload_rundeck_jobs.sh#######################################################
# This script will upload jobs to rundeck
#  from git based on:
#      1)Product Name
#      2) Git branch
#      3) Rundeck project name
# in addition the script will also copy all the
# job options jsons required for a product
#
#####################################################
usage ()
{
  echo 'Usage : upload_rundeck_jobs.sh <branch_name> <rundeck_environment_name>  e.g: branch_name = master|qa|b1508, rundeck_environment_name=dc4_bizx_dr'
  exit
}
if [ "$#" -ne 2 ]
then
  usage
fi

RUNDECK_PROJECT_NAME=$2
GIT_BRANCH=$1
echo $RUNDECK_PROJECT_NAME | awk -F'_' '{print $2}'
PRODUCT_NAME=`echo $RUNDECK_PROJECT_NAME | awk -F'_' '{print $2}'`
echo $PRODUCT_NAME
GIT_BASE=/automation/git/$1
REPO_NAME=hcm-chef-automation
GIT_USER_NAME=readonly
GIT_USER_PASSWORD=readonly
GIT_CLONE_URL=http://$GIT_USER_NAME:$GIT_USER_PASSWORD@64.95.110.156//root/$REPO_NAME.git
IGNORE=/automation/git/$GIT_BRANCH/hcm-chef-automation/$PRODUCT_NAME/rundeck-jobs/ignore-jobs.txt

platform_jobs ()
{
	# Check if an ignore file exists. If it does use it to check platform jobs to be uploaded. Else upload all.
	if [ -f  "$IGNORE" ]
	then
		filename=$(basename $1)
		if grep -q "$filename" /automation/git/$GIT_BRANCH/hcm-chef-automation/$PRODUCT_NAME/rundeck-jobs/ignore-jobs.txt
		then
		    echo " -- ignoring $filename"
		else
			sed "1d" $1 >> /home/deployer/consolidated_jobs.xml
			echo "upload $1"
			sed -i '$ d' /home/deployer/consolidated_jobs.xml >> /home/deployer/consolidated_jobs.xml
		fi
	else
		sed "1d" $1 >> /home/deployer/consolidated_jobs.xml
		echo "upload $1"
		sed -i '$ d' /home/deployer/consolidated_jobs.xml >> /home/deployer/consolidated_jobs.xml
	fi

}


#############
#first copy and load all the rundeck jobs in platform folders (these jobs should be common for all products)
#############
touch /home/deployer/consolidated_jobs.xml
cp /dev/null /home/deployer/consolidated_jobs.xml
j=0
for one_job in `ls -a /automation/git/$GIT_BRANCH/hcm-chef-automation/platform/rundeck-jobs/*.xml`
do
	j=$(( $j+1 ))
        if (( $j <= 10 ))
        then
		platform_jobs $one_job
	else
		platform_jobs $one_job
		if (( $j > 10 ))
                then
                        sed -i '1s/^/<joblist>\n/' /home/deployer/consolidated_jobs.xml
                        echo "</joblist>" >> /home/deployer/consolidated_jobs.xml
                        /home/deployer/rundeck/tools/bin/rd-jobs load -p  $RUNDECK_PROJECT_NAME -f /home/deployer/consolidated_jobs.xml -F xml --remove-uuids
                        cp /dev/null /home/deployer/consolidated_jobs.xml
		fi
		j=0
	fi
done
sed -i '1s/^/<joblist>\n/' /home/deployer/consolidated_jobs.xml
echo "</joblist>" >> /home/deployer/consolidated_jobs.xml
/home/deployer/rundeck/tools/bin/rd-jobs load -p  $RUNDECK_PROJECT_NAME -f /home/deployer/consolidated_jobs.xml -F xml --remove-uuids
echo "============================ Uploaded platform jobs =============================="
##############
# now copy the and load all the product specific jobs
##############
cp /home/deployer/consolidated_jobs.xml /home/deployer/consolidated_jobs_platform.xml
cp /dev/null /home/deployer/consolidated_jobs.xml

if [ ! "$PRODUCT_NAME" == "platform" ]
then
	i=0
	for one_job in `ls -a /automation/git/$GIT_BRANCH/hcm-chef-automation/$PRODUCT_NAME/rundeck-jobs/*.xml`
	do
		i=$(( $i+1 ))
		if (( $i <= 10 ))
		then
			sed "1d" $one_job >> /home/deployer/consolidated_jobs.xml
			echo "upload $one_job"
			sed -i '$ d' /home/deployer/consolidated_jobs.xml >> /home/deployer/consolidated_jobs.xml
		else
			sed "1d" $one_job >> /home/deployer/consolidated_jobs.xml
			echo "upload $one_job"
			sed -i '$ d' /home/deployer/consolidated_jobs.xml >> /home/deployer/consolidated_jobs.xml
			if (( $i > 10 ))
			then
				sed -i '1s/^/<joblist>\n/' /home/deployer/consolidated_jobs.xml
				echo "</joblist>" >> /home/deployer/consolidated_jobs.xml
				/home/deployer/rundeck/tools/bin/rd-jobs load -p  $RUNDECK_PROJECT_NAME -f /home/deployer/consolidated_jobs.xml -F xml --remove-uuids
				cp /dev/null /home/deployer/consolidated_jobs.xml
			fi
			i=0
		fi
	done
	sed -i '1s/^/<joblist>\n/' /home/deployer/consolidated_jobs.xml
	echo "</joblist>" >> /home/deployer/consolidated_jobs.xml
	/home/deployer/rundeck/tools/bin/rd-jobs load -p  $RUNDECK_PROJECT_NAME -f /home/deployer/consolidated_jobs.xml -F xml --remove-uuids
	echo "============================ Uploaded $PRODUCT_NAME jobs =============================="
fi
#######################################
# Move the get_nodes_from_chef_server.rb script to populate the resources.xml
#######################################

cp /automation/git/$GIT_BRANCH/hcm-chef-automation/platform/ruby-scripts/get_nodes_from_chef_server.rb /home/deployer/rundeck/


#######################################
# Move the serverspec content to /automation
#######################################

if [ ! -d "/automation/serverspec" ]; then
 echo "/automation/serverspec does not exists. Creating it ..."
  sudo mkdir /automation/serverspec
  sudo chown -R deployer:deployer /automation/serverspec
fi


echo "Copy for serverspec source in progress.............."
cp -r /automation/git/$GIT_BRANCH/hcm-chef-automation/platform/serverspec /automation/
#sudo wget -qO- --timeout=60 -O /tmp/tmp.zip http://64.95.110.156/specuser/hcm_serverspec/repository/archive.zip && unzip -o /tmp/tmp.zip -d /tmp && sudo rm /tmp/tmp.zip
sudo wget -qO- --timeout=60 -O /tmp/tmp.zip http://10.8.198.71/specuser/hcm_serverspec/repository/archive.zip && unzip -o /tmp/tmp.zip -d /tmp && sudo rm /tmp/tmp.zip

sudo cp -r /tmp/hcm_serverspec.git/$PRODUCT_NAME /automation/serverspec/templates/
sudo cp -r /tmp/hcm_serverspec.git/platform /automation/serverspec/templates/
sudo chown -R deployer:deployer /automation/serverspec
echo "Copied $PRODUCT_NAME and platform serverspec templates to destination ..."



######################################
# For roles, we will list all the roles in the roles directory
# and create a json file, so that new roles are available dynamically
######################################
cp /dev/null /automation/rundeck/jobs_rundeck/${RUNDECK_PROJECT_NAME}_serverspec_template.json
sh /automation/git/$GIT_BRANCH/hcm-chef-automation/platform/shell-scripts/generate_rundeck_serverspec_template_options.sh $GIT_BRANCH $PRODUCT_NAME >> /automation/rundeck/jobs_rundeck/${RUNDECK_PROJECT_NAME}_serverspec_template.json
cp /dev/null /automation/rundeck/jobs_rundeck/${RUNDECK_PROJECT_NAME}_roles.json
sh /automation/git/$GIT_BRANCH/hcm-chef-automation/platform/shell-scripts/generate_rundeck_roles_options.sh $GIT_BRANCH $PRODUCT_NAME >> /automation/rundeck/jobs_rundeck/${RUNDECK_PROJECT_NAME}_roles.json
echo "copied roles and other options to rundeck job options ..."
if [ ! -d "/automation/$RUNDECK_PROJECT_NAME" ]; then
 echo "/automation/$RUNDECK_PROJECT_NAME does not exists. Creating it ..."
  sudo mkdir /automation/$RUNDECK_PROJECT_NAME
  sudo chown -R deployer:deployer /automation/$RUNDECK_PROJECT_NAME
fi

#####################################
# create symbolic links with the names of the environments linking it to the corresponding branch(so that we don't have to change this script whenever branch name changes)
#####################################
unlink /automation/$RUNDECK_PROJECT_NAME/hcm-chef-automation
ln -s /automation/git/$GIT_BRANCH/hcm-chef-automation /automation/$RUNDECK_PROJECT_NAME/hcm-chef-automation

#######################################
# copy the json file for environment
#######################################

if [ ! -f "/automation/git/$GIT_BRANCH/hcm-chef-automation/$PRODUCT_NAME/jsons/$RUNDECK_PROJECT_NAME.json" ]; then
 echo "/automation/git/$GIT_BRANCH/hcm-chef-automation/$PRODUCT_NAME/jsons/$RUNDECK_PROJECT_NAME.json does not exist. Please create this file,  chef runs may not be successful without this ..."
else
  cp /automation/git/$GIT_BRANCH/hcm-chef-automation/$PRODUCT_NAME/jsons/$RUNDECK_PROJECT_NAME.json /automation/$RUNDECK_PROJECT_NAME/
fi

