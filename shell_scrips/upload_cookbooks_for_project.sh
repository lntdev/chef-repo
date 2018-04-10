############################################
# This script will get the latest chef
# artifacts from  the git and uploads them
# to chef-server
###########################################
usage ()
{
  echo 'Usage : upload_cookbooks_for_project.sh <branch_name> <chef_server_environment_name>  e.g: branch_name = master|qa|b1508, chef_server_environment_name=dc4_bizx_dr'
  exit
}
if [ "$#" -ne 2 ]
then
  usage
fi

#MOUNT_POINT_NAME=/automation
#GIT_BASE=$MOUNT_POINT_NAME/git/$1
REPO_NAME=chef-repo
CHEF_HOME=/home/ubuntu/chef-repo
GIT_USER_NAME=lntdev
GIT_USER_PASSWORD=Intel2123
GIT_CLONE_URL=https://$GIT_USER_NAME:$GIT_USER_PASSWORD@github.com/lntdev/$REPO_NAME.git
PRODUCT_NAME=`echo $2 | awk -F'_' '{print $2}'`

################################
# read the list of cookbooks, roles & databags from 
# individual products txt file
################################
if [ ! -f "chef-repo/platform_cookbooks.txt" ]; then
 echo " $GIT_BASE/$REPO_NAME/$PRODUCT_NAME/cookbooks/${PRODUCT_NAME}_cookbooks.txt does not exists for this product. Please create this file with the list of cookbooks, roles and databags to upload "
  exit 1
fi
source $GIT_BASE/$REPO_NAME/$PRODUCT_NAME/cookbooks/${PRODUCT_NAME}_cookbooks.txt

##############################################
# create directories if not exists
##############################################


################################
#Step-1: Copy and upload cookbooks
###############################

cd $CHEF_HOME

for one_cookbook in ${COOKBOOKS[@]}
do
       echo "uploading ${one_cookbook##*/}"	
       #get the name and path of the cookbook
       cookbook_name=`echo $one_cookbook | rev | cut -d/ -f1 | rev`
       cookbook_path=`dirname  $one_cookbook`
       knife cookbook upload $cookbook_name --cookbook-path /$REPO_NAME/$cookbook_path --environment $2
done
echo "####################################"
echo "# Finished uploading cookbooks "
echo "####################################"


################################
#Step-2: Copy and upload roles
################################

cd $CHEF_HOME
for one_role in ${ROLES[@]}
do
    echo "uploading role $one_role "
    knife role from file  /$REPO_NAME/$one_role
done

echo "####################################"
echo "# Finished uploading roles"
echo "####################################"


###############################
#Step-3: Copy and upload databags
##############################

for one_databag in ${DATABAGS[@]}
do
       echo "uploading databag ${one_databag##*/}"
       databag_name=`echo $one_databag | rev | cut -d/ -f1 | rev`
       databag_path=`dirname  $one_databag`   
       knife data bag create $databag_name --environment $2
       knife data bag from file  $databag_name $REPO_NAME/$one_databag --environment $2 
done
echo "####################################"
echo "# Finished uploading databags "
echo "####################################"
