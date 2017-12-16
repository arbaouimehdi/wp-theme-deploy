#!/usr/bin/env bash
heroku login
heroku apps:create $1
heroku git:remote -a $1
heroku addons:create cleardb:ignite
DATABASE_URL=$(heroku config | grep CLEARDB_DATABASE_URL)
ORIGINAL_NAME="CLEARDB_DATABASE_URL: mysql"
NEW_NAME="mysql2"
DATABASE_NEW_URL=${DATABASE_URL//$ORIGINAL_NAME/$NEW_NAME}
heroku config:set DATABASE_URL=$DATABASE_NEW_URL