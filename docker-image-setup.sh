#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo docker run -d -p 8080:8080 thomaspoignant/hello-world-rest-json