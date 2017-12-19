# Wordpress Theme Deploy

## Local Development

Clone the project
```
git clone https://github.com/Clarkom/wp-theme-deploy.git
```

Rename the project folder
```
mv wp-theme project-name
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

Install Javascript Dependencies
```
cd htdocs/wp-content/themes/theme-name
yarn install
yarn build
```

# Deploying with Terraform

You can get your Heroku API key from the Heroku dashboard

```
export HEROKU_API_KEY=
export HEROKU_EMAIL=
```

For AWS, create an IAM user with Administrator rights

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```
The state of Terraform is managed in S3, so it should automatically sync any changes from the remote backend. For this you'll need to manually set up an S3 bucket in the eu-west-1 region with the name wp-terraform-backend

```
terraform init
terraform apply
```
