#!/usr/bin/env bash

git clone https://github.com/Clarkom/wp-theme-deploy.git
mv wp-theme-deploy $1
cd $1
cp .env.sample .env
mv htdocs/wp-content/themes/projectname-theme htdocs/wp-content/themes/$1-theme
for file in $(grep -R 'projectname' -l --exclude-dir=htdocs/wp-content/themes/$1-theme); do $(sed -i s/projectname/$1/g "$file"); done
sudo npm run shell
