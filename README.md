# Wordpress Theme Deploy

This Project aims to present a complete workflow to start a new Wordpress Project.

> - In the whole process **projectname** has to be replaced with you project name.
> - Example: **clarkom**, **clarkominsight**.

## Environment:
Local Server and Heroku environment
- PHP `7.2.0`
- REDIS `3.1.4`
- Nginx `1.8.1`
- Composer `1.5.2`
- Node Engine `8.8.1`

### Access Links
- http://projectname.test `(docker web service)`
- http://projectname.test:8082 `(docker phpmyadmin service)`
- http://projectname-dev.herokuapp.com `(heroku app)`


# Local Deployment

***
To create a new project, you've first to download the shell script using `wget`, or your can copy the content from this [gist](https://goo.gl/1BWa9k):
```
wget https://goo.gl/1BWa9k
mv 1BWa9k new_project
chmod u+x new_project
./new_project projectname
```
***
### From the Docker Container
```
composer install
composer update
chown -R www-data:www-data htdocs/wp-content/
chown -R www-data:www-data htdocs/wordpress/
chown -R 1000:1000 htdocs/wp-content/themes/projectname-theme
```
***
### From your Local Machine
Add `projectname.test` to your `/etc/hosts`
```
sudo vi /etc/hosts
```
Start the docker `web` service
```
sudo npm start
```
- Open http://projectname.test and install Wordpress.
- Enable Installed theme from http://projectname.test/wp-admin/themes.php

### phpMyAdmin
To access to phpMyAdmin through http://projectname.test:8082 you have to start the docker `phpmyadmin` service:
```
sudo docker-compose up phpmyadmin
```
#### Phpmyadmin credentials
```
username: root
password: password
```

# Deploying with Terraform

***
### Add AWS & Heroku Credentials
- Access to you AWS console and [Create a bucket](https://s3.console.aws.amazon.com/s3/home?region=eu-west-1#) with the name of your project `projectname`, and use as a Region **EU (ireland)**
- Edit `.env` file and Add Heroku & AWS credentials, and validate the modifications.
```
source .env
```
***
### Terraform
The state of Terraform is managed in S3, so it should automatically sync any changes from the remote backend.
```
terraform init
terraform apply
```
***
### Git & Heroku 
If you're not logged to heroku:
```
heroku login
```
Last steps are used to push the project into Heroku, but before that, you've to initialize a new git repository.
```
git init
heroku git:remote -a projectname-dev
git add -A
git commit -m “Hello World“
git push heroku master
```
- Now you can access to your app from [https://projectname-dev.herokuapp.com/](https://projectname-dev.herokuapp.com/)
- Go to your wordpress admin dashboard [https://projectname-dev.herokuapp.com/wp-admin](https://projectname-dev.herokuapp.com/wp-admin) and enable `Redis Object Cache` and `S3 Uploads` plugins
***
### Generated Static Files
On each `yarn build` or `yarn build:production` from the docker `web` service you have to upload the generated `dist` folder to `projectname-dev-uploads` on your **AWS S3** bucket, and don't forget to make the bucket **public**.
 

# Essential Plugins

This is a consistent list of Wordpress Plugins to install, some plugins **(Free)** already exist on `composer.json`, and some others **(Premium)** are not set as default plugins, you've to install them manually. 

### Essential (14 plugins)

**Security**
- [Wordfence Security](https://www.wordfence.com/wordfence-signup/) **`(Premium)`**

**Content** 
- [S3 Uploads](https://github.com/humanmade/S3-Uploads) `(Free)`
- [Advanced Custom Fields PRO](https://www.advancedcustomfields.com/pro/) **`(Premium)`**
- [WP Real Media Library](https://codecanyon.net/item/wordpress-real-media-library-media-categories-folders/13155134) **`(Premium)`**

**Forms**
- [Gravity Forms](https://www.gravityforms.com/) **`(Premium)`**
- [Gravity Forms MailChimp Add-On](https://www.gravityforms.com/add-ons/mailchimp/) **`(Premium)`**
- [Real Time Validation for Gravity Forms](https://wordpress.org/plugins/real-time-validation-for-gravity-forms/) `(Free)`

**SEO**
- [Yoast SEO Premium](https://yoast.com/wordpress/plugins/seo/) **`(Premium)`**
- [ACF Content Analysis for Yoast SEO](https://wordpress.org/plugins/acf-content-analysis-for-yoast-seo/) `(Free)`

**Performance**
- [Imagify](https://wordpress.org/plugins/imagify/) `(Free)`
- [WP Rocket](https://wp-rocket.me/) **`(Premium)`**
- [Redis Object Cache](https://wordpress.org/plugins/redis-cache/) `(Free)`

**Miscellaneous**
- [User Role Editor]() `(Free)`

**Debugging**
- [Query Monitor](https://wordpress.org/plugins/user-role-editor/) `(Free)`

### Multilingual (6 plugins)
In case of a multilingual website, these are some extra plugins to install manually:

**Multilingual**
- [Advanced Custom Fields Multilingual](https://wpml.org/account/downloads/) **`(Premium)`**
- [Gravity Forms Multilingual](https://wpml.org/account/downloads/) **`(Premium)`**
- [WPML Media](https://wpml.org/account/downloads/) **`(Premium)`**
- [WPML Multilingual CMS](https://wpml.org/account/downloads/) **`(Premium)`**
- [WPML String Translation](https://wpml.org/account/downloads/) **`(Premium)`**
- [WPML Translation Management](https://wpml.org/account/downloads/)  **`(Premium)`**


# Project Structure
```shell
wp-theme-deploy              # → Root of the Project
├── bin                      # →
│   └── wp                   # →
├── composer.json            # → Heroku Autoloading and Server config
├── composer.lock            # → Composer lock file (never edit)
├── config                   # →
│   ├── env                  # →
        ├── development.php  # → Development environment config
        ├── local.php        # → Local environment config
        ├── production.php   # → Production environment config
        ├── qa.php           # → QA(Quality Assurance) environment config
│   ├── nginx.conf           # → nginx server config
│   └── wp-config.php        # → This file contains WordPress config and replaces the usual wp-config.php
├── docker                   # → This folder will include db-data (database folder) and nginx logs
├── docker-compose.yml       # → Local server docker services
├── Dockerfile               # → Docker build images
├── htdocs                   # → 
│   ├── index.php            # → 
│   ├── wp-config.php        # →
│   ├── wp-content           # →
│   └── wp-load.php          # →
├── package.json             # → Heroku Javascript Dependencies
├── phpcs.xml                # → PHP Codesniffer rules
├── Procfile                 # →
├── terraform.tf             # → Deployment infrastructure plan
├── tools                    # →
│   └── new_project.sh       # → Creating a new project steps
│   └── star_web.sh          # →
```

# Theme structure

```shell
themes/your-theme-name/   # → Root of your Sage based theme
├── app/                  # → Theme PHP
│   ├── controllers/      # → Controller files
│   ├── admin.php         # → Theme customizer setup
│   ├── filters.php       # → Theme filters
│   ├── helpers.php       # → Helper functions
│   └── setup.php         # → Theme setup
├── composer.json         # → Autoloading for `app/` files
├── composer.lock         # → Composer lock file (never edit)
├── dist/                 # → Built theme assets (never edit)
├── node_modules/         # → Node.js packages (never edit)
├── package.json          # → Node.js dependencies and scripts
├── resources/            # → Theme assets and templates
│   ├── assets/           # → Front-end assets
│   │   ├── config.json   # → Settings for compiled assets
│   │   ├── build/        # → Webpack and ESLint config
│   │   ├── fonts/        # → Theme fonts
│   │   ├── images/       # → Theme images
│   │   ├── scripts/      # → Theme JS
│   │   └── styles/       # → Theme stylesheets
│   ├── functions.php     # → Composer autoloader, theme includes
│   ├── index.php         # → Never manually edit
│   ├── screenshot.png    # → Theme screenshot for WP admin
│   ├── style.css         # → Theme meta information
│   └── views/            # → Theme templates
│       ├── layouts/      # → Base templates
│       └── partials/     # → Partial templates
└── vendor/               # → Composer packages (never edit)
```

# Most used commands

### Docker
* `sudo docker-compose up web`
* `sudo docker-compose up adminer`
* `sudo docker exec -it wpthemedeploy_web_1 /bin/bash`

### Yarn
* `yarn run start` — Compile assets when file changes are made, start Browsersync session
* `yarn run build` — Compile and optimize the files in your assets directory
* `yarn run build:production` — Compile assets for production


