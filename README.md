# docker-honeypot
Create a docker image with the lines

'''
FROM ubuntu:14.04

RUN apt-get update && \
    apt-get upgrade -y \
    apt-get install -y openssh-server && \
    mkdir /var/run/sshd

RUN echo root:root | chpasswd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
'''

Then we just need to build the docker image:

'''
$ docker build -t honeypot .
'''

In order to make docker-based honeypot more effective, we'd need to change SSH server setting on the host system so that honeypot could run on port 22. You can do that by editing /etc/ssh/sshd_server file and change the default port to something like 2222. Make sure to restart SSH service with /etc/init.d/ssh restart.

Now, set up ssh with docker:

'''
$ docker run -d -p 22:22 honeypot
'''

Based on example code provided by Dan Sosedoff: http://sosedoff.com/2015/12/19/docker-ssh-honeypot.html
