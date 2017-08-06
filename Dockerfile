FROM heroku/heroku:16-build
# There is no need to be the Heroku image as it doesn't run the buildpakc anymore

RUN apt-get update && apt-get install -y openssh-server git
RUN mkdir /var/run/sshd
# grab this password from docker --build-arg
RUN echo 'root:jdkas21312doium23901m012u03' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Install docker for building images to update deployment
ENV DOCKER_API_VERSION 1.23
RUN apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
RUN apt-get update
RUN apt-get -y install docker-ce

# Install gcloud commnand line utility
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-163.0.0-linux-x86_64.tar.gz
RUN tar -zxvf google-cloud-sdk-163.0.0-linux-x86_64.tar.gz
RUN ./google-cloud-sdk/install.sh --quiet

# Install kubectl for updating the application deployment
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin/kubectl

ADD bin /buildpack/bin

RUN mkdir ~/.ssh

ADD config-parser.rb /config-parser.rb
ADD save_secrets.sh /save_secrets.sh

# Should actually init a repositoy, as there is no need to begin from a existing one. It makes the image way more generic
WORKDIR /
RUN git init --bare app.git
COPY hooks app.git/hooks
WORKDIR /app.git

# TODO: create script to add local ssh public key to builder authorized_keys with kubectl run
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
