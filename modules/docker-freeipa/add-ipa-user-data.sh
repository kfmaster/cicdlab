#!/bin/bash

# 
# Create initial users after setup freeipa server
#

USER_DATA="/data/ipa-user-data"

echo
echo "Executing /usr/sbin/add-ipa-user-data.sh ..."
echo

if [ ! -f ${USER_DATA} ]; then
    echo
    echo "Please create a /data/ipa-user-data file to provide some ipa users,groups and/or roles, then run /usr/sbin/add-ipa-user-data.sh ."
    echo
fi

userlist=`cat ${USER_DATA} |shyaml get-value users |awk '{print $2}'`
grouplist=`cat  ${USER_DATA} |shyaml get-value groups |awk '{print $2}'`
rolelist=`cat  ${USER_DATA} |shyaml get-value roles |awk '{print $2}'`

echo $PASSWORD | kinit admin

function add_users () {
for myuser in $userlist
do
    ipa user-find ${myuser} 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Creating IPA User: $myuser..."
        pass=`cat  ${USER_DATA} |shyaml get-value ${myuser}.password`
        first=`cat  ${USER_DATA} |shyaml get-value ${myuser}.first`
        last=`cat  ${USER_DATA} |shyaml get-value ${myuser}.last`
        ipa user-add ${myuser} --first=${first} --last=${last} 1>/dev/null 
        echo "${pass}
        ${pass}" | ipa passwd ${myuser}
    else
        echo "IPA user ${myuser} already exists."
    fi
done
}
    
function add_groups () {
for mygroup in ${grouplist}
do
    ipa group-find ${mygroup} 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Creating IPA Group: ${mygroup} ..."
        ipa  group-add ${mygroup} --desc="${mygroup} group"
    else
        echo "IPA group ${mygroup} already exsists."
    fi

    echo "Updating group membership for ${mygroup}..."
    memberlist=$(cat  ${USER_DATA} |shyaml get-value groups | awk -v pattern="${mygroup}" '$2 ~ pattern {print $4}'|sed 's/,/ /g')
    myfield1=`echo ${memberlist}|cut -d " " -f1`

    ipa user-find ${myfield1} 1>/dev/null 2>&1
    if [ $? -eq 0 ]; then
        for mymember in ${memberlist}
        do
            ipa group-add-member ${mygroup} --users=${mymember} 1>/dev/null 
        done
    else 
        ipa group-find ${myfield1} 1>/dev/null 2>&1
        if [ $? -eq 0 ]; then
            for mymember in ${memberlist}
            do
                ipa group-add-member ${mygroup} --groups=${mymember} 1>/dev/null 
            done
        else
            echo "Trying to config ${mygroup} memberlist, can't determine if ${myfield1} is a user or a group, please troubleshoot."
        fi
    fi
done
}
    
function add_roles () {
for myrole in ${rolelist}
do
    ipa role-find ${myrole} 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Creating IPA Role: ${myrole} ..."
        ipa  role-add ${myrole} --desc="${myrole} role"
    else
        echo "IPA role ${myrole} already exsists."
    fi

    echo "Updating role membership for ${myrole}..."
    memberlist=$(cat  ${USER_DATA} |shyaml get-value roles | awk '{print $4}' | sed 's/,/ /g')
    for mymember in ${memberlist}
    do
        ipa role-add-member ${myrole} --groups=${mymember} 1>/dev/null
    done
done
}

if [ ! -z "${userlist}" ]; then
    add_users
fi

if [ ! -z "${grouplist}" ]; then
    add_groups
fi

if [ ! -z "${rolelist}" ]; then
    add_roles
fi

kdestroy
