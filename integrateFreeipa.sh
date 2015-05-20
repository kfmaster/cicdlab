#!/bin/bash

function setup_jenkins_redmine_ldap () {
# Set ldap server ip to ${ldap_internal_ip} ...
ldap_internal_ip=$(docker inspect ipa01 |grep IPAddress | awk '{print $2}' |sed -e 's/"//g' -e 's/,//')

# Set ldap account search base ${ldap_acct_base} ...
ldap_basedn=$(etcdctl get /services/gerrit/ldap_accountbase)
ldap_acct_base=$(echo ${ldap_basedn} |sed 's/cn=users,cn=accounts,//')

# Set current running jenkins docker container's id
jenkins_docker_id=`docker ps |grep jenkins |grep -v datajenkins |awk '{print $1}'`

# Copy over a config.xml template 
if [ ! -z "${jenkins_docker_id}" ]; then
    docker exec ${jenkins_docker_id} cp /usr/local/etc/config.xml.template /var/jenkins_home/config.xml
else
    echo "Jenkins container is not running, please use docker-compose to bringup all containers."
fi

# Update jenkins ldap configuration 
echo
echo "Integrating Jenkins with freeipa ..."
docker exec ${jenkins_docker_id} sed  -i.template -e 's/dc=example,dc=com/'"${ldap_acct_base}"'/' \
-e 's/192.168.0.250/'"${ldap_internal_ip}"'/' \
/var/jenkins_home/config.xml

# Restart jenkins and nginx container after above changes
jenkins_url=$(etcdctl get /services/jenkins/weburl)
echo
echo "Restarting Jenkins to make the ldap config take effect ..."
docker-compose -f ${project_config_dir}/docker-compose.yml restart jenkins
docker-compose -f ${project_config_dir}/docker-compose.yml restart nginxproxy
echo
echo "You may got to ${jenkins_url} and test login using predefined IPA ldap users ..."

# Sow instructions of setup ldap in redmine
redmine_url=$(etcdctl get /services/redmine/weburl)

echo
echo "*********************************************************************************"
echo "Logon to ${redmine_url} as admin, password is: admin"
echo
echo "Go to Administration - LDAP authentication - New authentication mode "
echo
echo "Type following information: "
echo "Name:  freeipa   (whatever name you would like to call this auth mode)"
echo "Host:  ${ldap_internal_ip}"
echo "Port:  636  and LDAPS checked"
echo "Base DN: ${ldap_basedn} "
echo "On-the-fly user creation    checked"
echo "Login attribute:  uid "
echo 
echo "You may leave everything else unfilled, then click save."
echo
echo "You may got to ${redmine_url} and test login using predefined IPA ldap users ..."
echo "LDAP users will be registered on the fly in Redmine, you can manage those users using the default admin user."
echo
echo "*********************************************************************************"
}

setup_jenkins_redmine_ldap

