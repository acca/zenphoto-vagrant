#!/usr/bin/env bash

WS='/var/www/html'
APP_NAME='zenphoto'
WEB_USER='www-data'
APP_VERSION='1.4.13'

source /vagrant/functions.sh

ubu_setup

ubu_upgrade

ubu_add_packages

zenphoto_install

zenphoto_configure

a2enmod rewrite

sleep 3

service apache2 restart