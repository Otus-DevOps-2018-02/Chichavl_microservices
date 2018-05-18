#!/bin/bash
export GOOGLE_PROJECT=docker-202221

docker-machine create --driver google \
--google-machine-image  https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
--google-tags gitlab \
docker-host

eval $(docker-machine env docker-host)

docker run --detach \
    --hostname gitlab.example.com \
    --publish 443:443 --publish 80:80 --publish 2222:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest
