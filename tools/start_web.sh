#!/bin/sh

vendor/bin/heroku-php-nginx -F config/php/php-fpm.conf -C config/nginx.conf htdocs/