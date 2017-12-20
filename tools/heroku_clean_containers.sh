#!/usr/bin/env bash

# Stop and Remove all containers
sudo sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)