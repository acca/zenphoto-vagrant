#!/bin/bash

function ubu_setup() {
	echo "----> Setup..."
	sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost zenphoto/" /etc/hosts
	ln -s $WS ws
	# This makes debconf use a frontend that expects no interactive input at all, preventing it from even trying to access stdin.
}

function ubu_upgrade() {
	echo "----> Upgrading..."
	export DEBIAN_FRONTEND=noninteractive
	sudo apt-get update
	sudo apt-get dist-upgrade -y --force-yes
}

function ubu_add_packages() {
	echo "----> Installing packages..."
	sudo apt-get install -y --force-yes git
	sudo apt-get install bash-completion -y
	apt-get install emacs23-nox -y
	apt-get install htop -y
	apt-get install lamp-server^ -y
	apt-get install php5-gd -y
	apt-get install sendmail -y
}

function zenphoto_configure() {
	echo "----> Configure ZenPhoto"
	cd $WS
	chown -R $WEB_USER.$WEB_USER $APP_NAME
	cd $APP_NAME
	cp zp-core/zenphoto_cfg.txt zp-data/zenphoto.cfg.php
	sudo mysqladmin create $APP_NAME
	sed -i "s/\$conf\['mysql_user'\] = ''/\$conf['mysql_user'] = 'root'/" zp-data/zenphoto.cfg.php
	sed -i "s/\$conf\['mysql_database'\] = ''/\$conf['mysql_database'] = '$APP_NAME'/" zp-data/zenphoto.cfg.php
}

function zenphoto_install() {
	echo "----> Install ZenPhoto"
	wget -nc --progress=bar:force https://github.com/zenphoto/zenphoto/archive/$APP_NAME-$APP_VERSION.tar.gz -O /tmp/$APP_NAME-$APP_VERSION.tar.gz
	tar -zxvf /tmp/zenphoto-1.4.13.tar.gz -C $WS/
	cd $WS
	mv $APP_NAME-$APP_NAME-$APP_VERSION $APP_NAME
}