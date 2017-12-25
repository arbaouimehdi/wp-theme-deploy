#!/usr/bin/env bash

git clone https://github.com/Clarkom/wp-theme-deploy.git
mv wp-theme-deploy $1
cd $1
cp .env.sample .env
sudo npm run shell
