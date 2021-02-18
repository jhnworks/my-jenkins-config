#!/usr/bin/env bash

docker run \
    -u 0 \
    --privileged \
    -d \
    --name jenkins-master \
    -p 8088:8080 \
    -p 50000:50000 \
    -v $(which docker):/usr/bin/docker \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /mnt/c/Spring:/var/jenkins_home \
    jenkins/jenkins:latest &&\
    docker logs -f jenkins-master &&;
