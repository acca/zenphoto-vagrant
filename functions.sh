#!/bin/bash

WS='/var/www/html'
APP_NAME='zenphoto'
WEB_USER='www-data'
APP_VERSION='1.4.13'
PHP_INI_FILE='/etc/php5/apache2/php.ini'

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
	apt-get autoremove -y
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
	# Alternate method single packages --> Same error on apache seg fault
	#apt-get install apache2 php5 libapache2-mod-php5 php5-mcrypt php5-mysql php5-gd mysql-server -y
}

function zenphoto_configure() {
	echo "----> Configure ZenPhoto"
	cd $WS
	chown -R $WEB_USER:$WEB_USER $APP_NAME
	cd $APP_NAME
	cp zp-core/zenphoto_cfg.txt zp-data/zenphoto.cfg.php
	sudo mysqladmin create $APP_NAME
	sed -i "s/\$conf\['mysql_user'\] = ''/\$conf['mysql_user'] = 'root'/" zp-data/zenphoto.cfg.php
	sed -i "s/\$conf\['mysql_database'\] = ''/\$conf['mysql_database'] = '$APP_NAME'/" zp-data/zenphoto.cfg.php
}

function zenphoto_install() {
	echo "----> Install ZenPhoto"
	wget -nc --progress=bar:force https://github.com/zenphoto/zenphoto/archive/$APP_NAME-$APP_VERSION.tar.gz -O /tmp/$APP_NAME-$APP_VERSION.tar.gz
	tar -zxvf /tmp/zenphoto-$APP_VERSION.tar.gz -C $WS/
	cd $WS
	mv $APP_NAME-$APP_NAME-$APP_VERSION $APP_NAME
}

function customize_php_ini() {
	echo "----> Customizing php.ini"
	cp $PHP_INI_FILE $PHP_INI_FILE.bck
	sed -i "s/memory_limit = .*/memory_limit = 128M/" $PHP_INI_FILE
	sed -i "s/post_max_size = .*/post_max_size = 1G/" $PHP_INI_FILE
	sed -i "s/file_uploads = .*/file_uploads = On/" $PHP_INI_FILE
	sed -i "s/upload_max_filesize = .*/upload_max_filesize = 1G/" $PHP_INI_FILE
	sed -i "s/max_file_uploads = .*/max_file_uploads = 20/" $PHP_INI_FILE
}

function upgrade_php() {
	# http://askubuntu.com/questions/565784/how-do-i-upgrade-php-version-to-the-latest-stable-released-version
	apt-get remove php5-common -y
	apt-add-repository ppa:ondrej/php -y
	apt-get update -y
	apt-get install php5.6 php5.6-gd php5.6-mysql -y
	PHP_INI_FILE='/etc/php/5.6/apache2/php.ini'
	customize_php_ini
	service apache2 restart
}
