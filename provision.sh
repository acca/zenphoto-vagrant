#!/usr/bin/env bash

WS='/var/www/html'
APP_NAME='zenphoto'
WEB_USER='www-data'
APP_VERSION='1.4.13'

echo "----> Setup..."
sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost zenphoto/" /etc/hosts
# mkdir $WS
ln -s $WS ws
# This makes debconf use a frontend that expects no interactive input at all, preventing it from even trying to access stdin.
export DEBIAN_FRONTEND=noninteractive

echo "----> Upgrading..."
sudo apt-get update
sudo apt-get dist-upgrade -y --force-yes

echo "----> Installing packages..."
sudo apt-get install -y --force-yes git
sudo apt-get install bash-completion -y
apt-get install emacs23-nox -y
apt-get install htop -y
apt-get install lamp-server^ -y
apt-get install php5-gd -y
apt-get install sendmail -y

echo "----> Install ZenPhoto"
wget -nc --progress=bar:force https://github.com/zenphoto/zenphoto/archive/$APP_NAME-$APP_VERSION.tar.gz -O /tmp/$APP_NAME-$APP_VERSION.tar.gz
tar -zxvf /tmp/zenphoto-1.4.13.tar.gz -C $WS/
cd $WS
mv $APP_NAME-$APP_NAME-$APP_VERSION $APP_NAME

echo "----> Configure ZenPhoto"
chown -R $WEB_USER.$WEB_USER $APP_NAME
cd $APP_NAME
cp zp-core/zenphoto_cfg.txt zp-data/zenphoto.cfg.php
sudo mysqladmin create $APP_NAME
sed -i "s/\$conf\['mysql_user'\] = ''/\$conf['mysql_user'] = 'root'/" zp-data/zenphoto.cfg.php
sed -i "s/\$conf\['mysql_database'\] = ''/\$conf['mysql_database'] = '$APP_NAME'/" zp-data/zenphoto.cfg.php

a2enmod rewrite
sleep 3
service apache2 restart