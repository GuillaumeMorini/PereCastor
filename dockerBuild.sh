#!/bin/bash

# Docker build
apt-get update
apt-get install -y docker.io
cd front-end
docker build -t guismo/front-end:0.3.12 .
