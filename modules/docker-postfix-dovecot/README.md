# Postfix Mail Server & Dovecot POP/IMAP Server

Run postfix with **smtp auth**, a **submission port** and **spamassassin**,
and run dovecot pop/imap server in a container.

## Summary

Ubuntu Vivid/Trusty Mail Server and POP/IMAP Server images with :

+ postfix with smtp authentication and a submission port
+ spamassassin
+ dovecot
+ supervisord
+ sshd

built on the top of the formal Ubuntu images.

## Maintainer

[ClassCat Co.,Ltd.](http://www.classcat.com/) (This website is written in Japanese.)

## TAGS

+ latest - vivid
+ vivid
+ trusty

## Pull Image

```
$ sudo docker pull classcat/postfix-dovecot
```

## Usage

```
$ sudo docker run -d --name (container name) \  
-p 2022:22 -p 25:25 -p 587:587 -p 110:110 -p 143:143 \  
-v (dir on host):/var/mail \  
-e ROOT_PASSWORD=(root password) \  
-e SSH_PUBLIC_KEY="ssh-rsa xxx" \   
-e HOSTNAME=(FQDN of host) -e DOMAINNAME=(domain name) \  
-e USERS=(usr0:pwd0,usr1:pwd1) \  
classcat/postfix-dovecot
```

### example)  

```
$ sudo docker run -d --name postfix-dovecot \  
-p 2022:22 -p 25:25 -p 587:587 -p 110:110 -p 143:143 \  
-v /mail:/var/mail \  
-e ROOT_PASSWORD=mypassword \  
-e HOSTNAME=mailsvr.classcat.com -e DOMAINNAME=classcat.com \  
-e USERS=foo:passwd,foo2:passwd2 \  
classcat/postfix-dovecot

$ sudo docker run -d --name postfix-dovecot \  
-p 2022:22 -p 25:25 -p 587:587 -p 110:110 -p 143:143 \  
-v /mail:/var/mail \  
-e ROOT_PASSWORD=mypassword \  
-e HOSTNAME=mailsvr.classcat.com -e DOMAINNAME=classcat.com \  
-e USERS=foo:passwd,foo2:passwd2 \  
classcat/postfix-dovecot:trusty
```

## Variables

## Known Issues

## Reference

+ [classcat/postfix](http://registry.hub.docker.com/u/classcat/postfix/)
+ [classcat/dovecot](http://registry.hub.docker.com/u/classcat/dovecot/)

