FROM jenkins/jenkins:latest 
MAINTAINER JG <jhnworks@gmail.com>

#docker pull jenkins/jenkins:2.263.4-lts-centos7
#docker pull jenkins/jenkins

# root user for Jenkins, need to get access to /var/run/docker.sock (fix this in the future!)
USER root

# Environment
ENV HOME /root
ENV JENKINS_HOME /root/jenkins
ENV JENKINS_VERSION 2.263.4

# GitHub repository to store _Jenkins_ configuration
ENV GITHUB_USERNAME jhnworks
ENV GITHUB_CONFIG_REPOSITORY my-jenkins-config

# Make _Jenkins_ home directory
RUN mkdir -p $JENKINS_HOME

# Install _Jenkins_ plugins
RUN /usr/local/bin/install-plugins.sh \
    scm-sync-configuration:0.0.10 \
    workflow-aggregator:2.6 \
    docker-workflow:1.25

# Set timezone
RUN echo "America/Los_Angeles" > /etc/timezone &&\
    dpkg-reconfigure --frontend noninteractive tzdata &&\
    date

# Copy RSA keys for _Jenkins_ config repository (default keys).
# This public key should be added to:
# https://github.com/%YOUR_JENKINS_CONFIG_REPOSITORY%/settings/keys
COPY keys/jenkins.config.id_rsa     $HOME/.ssh/id_rsa
COPY keys/jenkins.config.id_rsa.pub $HOME/.ssh/id_rsa.pub
RUN chmod 600 $HOME/.ssh/id_rsa &&\
    chmod 600 $HOME/.ssh/id_rsa.pub
RUN echo "    IdentityFile $HOME/.ssh/id_rsa" >> /etc/ssh/ssh_config &&\
    echo "    StrictHostKeyChecking no      " >> /etc/ssh/ssh_config
RUN /bin/bash -c "eval '$(ssh-agent -s)'; ssh-add $HOME/.ssh/id_rsa;"


# Configure git
RUN git config --global user.email "jenkins@container" &&\
    git config --global user.name  "jenkins"

# Clone _Jenkins_ config
RUN cd /tmp &&\
    git clone git@github.com:$GITHUB_USERNAME/$GITHUB_CONFIG_REPOSITORY.git &&\
    cp -r $GITHUB_CONFIG_REPOSITORY/. $JENKINS_HOME &&\
    rm -r /tmp/$GITHUB_CONFIG_REPOSITORY

# _Jenkins_ workspace for sharing between containers
VOLUME $JENKINS_HOME/workspace

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
COPY plugins.sh /usr/local/bin/plugins.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh

# Run init.sh script after container start
COPY src/init.sh /usr/local/bin/init.sh
ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/init.sh"]
