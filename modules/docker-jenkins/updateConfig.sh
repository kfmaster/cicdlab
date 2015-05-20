#!/bin/bash

# Set ldap server ip to ${ldap_internal_ip} ...
ldap_internal_ip=$(docker inspect ipa01 |grep IPAddress | awk '{print $2}' |sed -e 's/"//g' -e 's/,//') 

# Set ldap account search base ${ldap_acct_base} ...
ldap_acct_base=$(etcdctl get /services/gerrit/ldap_accountbase |sed 's/cn=users,cn=accounts,//')

# Set current running jenkins docker container's id
jenkins_docker_id=`docker ps |grep jenkins |grep -v datajenkins |awk '{print $1}'`

# Copy over a config.xml template 
docker exec ${jenkins_docker_id} cp /usr/local/etc/config.xml.template /var/jenkins_home/config.xml

# Update jenkins ldap configuration 
docker exec ${jenkins_docker_id} sed  -i.template -e 's/dc=example,dc=com/'"${ldap_acct_base}"'/' \
-e 's/192.168.0.250/'"${ldap_internal_ip}"'/' \
/var/jenkins_home/config.xml
