#!/bin/bash

# Docker push
docker login --username=$1 --password=$2
docker push guismo/front-end:0.3.12 .
