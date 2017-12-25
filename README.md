# Wordpress Theme Deploy

This project presente the complete workflow to deploy a wordpress website using [Heroku](https://www.heroku.com/) and [AWS](https://aws.amazon.com).

## How to Install

### Requirements

##### Local Server
* **[Docker](https://www.docker.com/)**
* **[Docker Compose](https://docs.docker.com/compose/install/)**
* **[Node.js](https://nodejs.org/en/)**

##### Wordpress Plugins
* **[Wordfence Security](https://www.wordfence.com/)**
* **[WP Rocket](https://wp-rocket.me/)**
* **[Advanced Custom Fields PRO](https://www.advancedcustomfields.com/pro/)**
* **[S3 Uploads](https://github.com/humanmade/S3-Uploads)**
* **[Redis Object Cache](https://wordpress.org/plugins/redis-cache/)**


In the whole process `Project Name` and `projectname` has to be replaced with your project name.

### Local Development

Clone the project
```
git clone https://github.com/Clarkom/wp-theme-deploy.git
```

Rename the project folder
```
mv wp-theme-deploy projectname
cd projectname
```

```
cp .env.sample .env
```
I also recommend installing **autoenv**, so you don't have to run the source command all the time.


Run shell docker service
```
sudo npm run shell
```

Install PHP Dependencies
```
composer install
exit
```

Run web docker service
```
sudo npm start
```

Rename theme folder
```
cd htdocs/wp-content/themes/
mv base-theme projectname-theme
```

Change `Base Theme` by the name of your theme `ProjectName Theme` on these files
* `htdocs/wp-content/themes/base-theme/config/assets.php`

Update `Theme Name`, `Theme URI`, `Description`, `Version`, `Author`, `Author URI`, `Text Domain` on
* `htdocs/wp-content/themes/base-theme/resources/style.css`

Change `base-theme` by the name of your theme `projectname-theme` on these files
* `htdocs/wp-content/themes/base-theme/composer.json`
* `htdocs/wp-content/themes/base-theme/package.json`


In a separate terminal run
```
sudo docker exec -it projectname_web_1 /bin/bash
```

Rerun this command to remove unused themes
```
composer install
```

Install Theme Dependencies
```
cd htdocs/wp-content/themes/projectname-theme
composer install
yarn install
yarn build
```

Open `htdtocs/wp-content/themes/projectname-theme/resources/assets/config.json` and edit these two lines

```
"publicPath": "/app/themes/projectname",
"devUrl": "http://projectname.test",
``` 

Open `docker-compose.yml` and set `VIRTUAL_HOST=projectname.test`

Edit `/etc/hosts` on your local machine and add `192.168.1.3 projectname.test`


### End

* Access to the you project from [projectname.test](http://projectname.test), and Follow the steps to install wordpress
* Log in into the admin dashboard and enable your `projectname-theme` from [http://projectname.test/wp-admin/themes.php](http://projectname.test/wp-admin/themes.php)
* Enter to `cd /app/user/htdocs/wp-content/uploads` and change the folder permission from `777` to `755` using `chmod 755 uploads` 

# Deploying with Terraform

You can get your Heroku API key from the Heroku dashboard

Open `.env` and set `TF_VAR_project_name=projectname`

#### Heroku

```
export HEROKU_API_KEY=
export HEROKU_EMAIL=
```

Add the Heroku remote:
```
heroku git:remote -a projectname
```

#### AWS

For AWS, create an IAM user with Administrator rights

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

```
source .env
```

Connect to your AWS console and add a new S3 bucket with the name `projectname`

#### Terraform

Edit `terraform.tf` and update `projectname`
```
# Store Terraform state in S3 (this must be prepared in advance)
terraform {
  backend "s3" {
    bucket = "projectname"
    key = "wp/terraform.tfstate"
    region = "eu-west-1"
  }
}

# AWS security group for public database access
resource "aws_security_group" "projectname" {
  name = "projectname"
  description = "public RDS security group"
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

Set up your environment
```
source .env
```

The state of Terraform is managed in S3, so it should automatically sync any changes from the remote backend. For this you'll need to manually set up an S3 bucket in the eu-west-1 region with the name wp-terraform-backend
* `terraform init`
* `terraform apply`

Add and Commit your changes
* `git add -A`
* `git commit -m "First Commit"`



Deploy using Heroku Git:

Before pushing to heroku, open `.gitignore` replace `projectname-theme`, and replace:
```
#######################
# ignored theme files #
#######################
/htdocs/wp-content/themes/base-theme/node_modules/
/htdocs/wp-content/themes/base-theme/vendor/
/htdocs/wp-content/themes/base-theme/.cache-loader/
/htdocs/wp-content/themes/base-theme/dist/
/htdocs/wp-content/uploads/
```

By

```
#######################
# ignored theme files #
#######################
/htdocs/wp-content/themes/projectname-theme/node_modules/
/htdocs/wp-content/themes/projectname-theme/dist/scripts
/htdocs/wp-content/themes/projectname-theme/dist/styles
/htdocs/wp-content/uploads/
```

* `heroku login`
* `heroku git:remote -a projectname-dev` add the heroku remote
* `git push heroku master` commit your code to the repository and deploy it using git


#### End
* Access to your project online on [https://projectname.heroku.com](https://projectname.heroku.com)

## Theme structure

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

### Build commands

* `yarn run start` — Compile assets when file changes are made, start Browsersync session
* `yarn run build` — Compile and optimize the files in your assets directory
* `yarn run build:production` — Compile assets for production


## Project Structure
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
│   └── start-web.sh         # →
```

### Docker commands
* `sudo docker-compose up web`
* `sudo docker-compose up adminer`
* `sudo docker exec -it wpthemedeploy_web_1 /bin/bash`
