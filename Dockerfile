FROM ubuntu:15.10

RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir /var/run/sshd

RUN echo root:password | chpasswd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
