#!/bin/bash
# Start 2 containers as FreeIPA server to provide LDAP services to other containers

docker ps |awk '{print $NF}' |grep -q datafreeipa 
if [ $? -ne 0 ]; then
    echo "Start a data container to hold ipa configuration data."
    docker run -d --name datafreeipa datafreeipa tail -f /dev/null
else
    echo "container datafreeipa is running: "
    docker ps |grep datafreeipa
fi

docker ps |awk '{print $NF}' |grep -q ipa01
if [ $? -ne 0 ]; then
    echo "Start a freeipa instance to provide LDAP service for other containers in this project..."
    docker run -d --name ipa01 -h ipa01.cicdlab.example.com -e PASSWORD=adminpass123 -p 389:389 -p 636:636 --volumes-from datafreeipa myfreeipa
    echo "This will take about 5 minutes,  please check the status by running:  docker logs -f ipa01 , when it is up, then last message should say Go loop."
else
    echo "container ipa01 is running: "
    docker ps |grep ipa01
fi
