# Wordpress Theme Deploy


## Local Dependencies

Install **Docker**

Install **Node.js**

## Local Development

Clone the project
```
git clone https://github.com/Clarkom/wp-theme-deploy.git
```

Rename the project folder
```
mv wp-theme-deploy projectname
```

Run shell docker service
```
npm run shell
```

Install PHP Dependencies
```
composer install && exit
```

Run web docker service
```
npm start
```

Rename theme folder
```
mv base-theme projectname-theme
```

Install Javascript Dependencies
```
cd htdocs/wp-content/themes/projectname-theme
yarn install
yarn build
```

Open `htdtocs/wp-content/themes/projectname-theme` and set `devUrl: http://projectname.test`

Open `docker-compose.yml` and set `VIRTUAL_HOST=projectname.test`

Add `192.168.1.3 projectname.test` to `/etc/hosts` 

# Deploying with Terraform

You can get your Heroku API key from the Heroku dashboard

### Heroku

```
export HEROKU_API_KEY=
export HEROKU_EMAIL=
```

Add the Heroku remote:
```
heroku git:remote -a projectname
```

### AWS

For AWS, create an IAM user with Administrator rights

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

Add a new S3 bucket with the name `projectname`

### Terraform

Clone this repo and source set up your environment inside the project root.

```
cp .env.sample .env
```
I also recommend installing **autoenv**, so you don't have to run the source command all the time.

Open `.env` and set `TF_VAR_project_name=projectname`

```
source .env
```

Edit `terraform.tf`
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

```
terraform init
terraform apply
```
