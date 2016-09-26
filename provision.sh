#!/usr/bin/env bash

source /vagrant/functions.sh

ubu_setup

ubu_upgrade

ubu_add_packages

zenphoto_install

zenphoto_configure

a2enmod rewrite

sleep 3

customize_php_ini

service apache2 restart