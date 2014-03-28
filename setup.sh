#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Usage: ./setup.sh [abs path to minicom log] , e.g. './setup.sh /home/access/openaccess_log.txt'"
    exit 1
fi

echo "Chosen absolute path to OpenAccess log is $1"
chmod 777 $1
# screen -dmS OA_MINICOM minicom -C $1

chmod +x parse_openaccess_log_in_db.pl
$PWD = $(pwd)

###################################################

echo "Adding job to crontab : \n"
echo "* * * * * root perl $PWD/parse_openaccess_log_in_db.pl $1"
crontab -l > mycron
echo "* * * * * root perl $PWD/parse_openaccess_log_in_db.pl $1" >> mycron
crontab mycron
rm mycron

CRON_LOG=$(grep -R "log" config.pl | grep -o -E "(\w+\.[A-Za-z]{3}\.[A-Za-z]{3})")
touch $CRON_LOG
chmod 777 $CRON_LOG

echo "Absolute path path to cron log is $PWD/$CRON_LOG"

chmod +x "select.pl"