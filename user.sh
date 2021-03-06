#!/bin/bash

uid=`getent passwd debian-tor | cut -d ":" -f 3` 
home=`getent passwd debian-tor | cut -d ":" -f 6` 
# if there is the uid the account is there and we can do # the sanit(ar)y checks otherwise we can safely create it. 
if [ "$uid" ]; then 
    if [ "$home" = "/var/lib/tor" ]; then : 
    #echo "debian-tor homedir check: ok" 
    else 
        echo "ERROR: debian-tor account has an unexpected home directory!" 
        echo "It should be '/var/lib/tor', but it is '$home'." 
        echo "Removing the debian-tor user might fix this, but the question" 
        echo "remains how you got into this mess to begin with." 
        exit 1 
    fi 
else 
    adduser --quiet \ 
        --system \ 
        --disabled-password \ 
        --home /var/lib/tor \ 
        --no-create-home \ 
        --shell /bin/false \ 
        --group \ 
        debian-tor 
fi 

for i in lib log; do 
    if ! [ -d "/var/$i/tor" ]; then 
        echo "Something or somebody made /var/$i/tor disappear." 
        echo "Creating one for you again." 
        mkdir "/var/$i/tor" 
    fi 
done 
which restorecon >/dev/null 2>&1 && restorecon /var/lib/tor 
chown debian-tor:debian-tor /var/lib/tor 
chmod 02700 /var/lib/tor 
which restorecon >/dev/null 2>&1 && restorecon /var/log/tor 
chown debian-tor:adm /var/log/tor 
chmod 02750 /var/log/tor

