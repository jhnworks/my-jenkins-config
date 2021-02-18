#!/usr/bin/env bash

exit_code=0;

#mkdir -p keys;
#cp ../../../keys/jenkins.* ./keys &&\
docker build --no-cache -t jenkins-master .;
if [[ "${?}" != 0 ]]; then
    exit_code=1;
fi;
docker tag $(docker image ls | grep "none" | awk '{print $3}') jenkins-master
#rm -r ./keys;

exit $((exit_code));
