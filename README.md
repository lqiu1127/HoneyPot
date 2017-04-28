# Project 10 - Honeypot

Time spent: **10** hours spent in total

> Objective: Setup a honeypot and provide a working demonstration of its features.

### Required: Overview & Setup

- [x] A basic writeup (250-500 words) on the `README.md` desribing the overall approach, resources/tools used, findings
	See below.
- [x] A specific, reproducible honeypot setup, ideally automated. There are several possibilities for this:
	- A Vagrantfile or Dockerfile which provisions the honeypot as a VM or container
	- A bash script that installs and configures the honeypot for a specific OS
	- Alternatively, **detailed** notes added to the `README.md` regarding the setup, requirements, features, etc.

### Required: Demonstration

- [x] A basic writeup of the attack (what offensive tools were used, what specifically was detected by the honeypot)
- [x] An example of the data captured by the honeypot (example: IDS logs including IP, request paths, alerts triggered)
- [x] A screen-cap of the attack being conducted
    
### Optional: Features
- Honeypot
	- [ ] HTTPS enabled (self-signed SSL cert)
	- [ ] A web application with both authenticated and unauthenticated footprint
	- [ ] Database back-end
	- [ ] Custom exploits (example: intentionally added SQLI vulnerabilities)
	- [ ] Custom traps (example: modified version of known vulnerability to prevent full exploitation)
	- [ ] Custom IDS alert (example: email sent when footprinting detected)
	- [ ] Custom incident response (example: IDS alert triggers added firewall rule to block an IP)
- Demonstration
	- [ ] Additional attack demos/writeups
	- [ ] Captured malicious payload
	- [ ] Enhanced logging of exploit post-exploit activity (example: attacker-initiated commands captured and logged)


Starting the walkthrough gif.

<img src='http://i.imgur.com/2dRGhJV.gif' title='General App Overview' width='' alt='Video Walkthrough' />

<img src='http://i.imgur.com/Nw6Zib2.gif' title='General App Overview' width='' alt='Video Walkthrough' />


Create a docker image with the lines

```
FROM ubuntu:14.04

RUN apt-get update && \
    apt-get upgrade -y \
    apt-get install -y openssh-server && \
    mkdir /var/run/sshd

RUN echo root:root | chpasswd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```

Then we just need to build the docker image:

```
$ docker build -t honeypot .
```

In order to make docker-based honeypot more effective, we'd need to change SSH server setting on the host system so that honeypot could run on port 22. You can do that by editing /etc/ssh/sshd_server file and change the default port to something like 2222. Make sure to restart SSH service with /etc/init.d/ssh restart.

Now, set up ssh with docker:

```
$ docker run -d -p 22:22 honeypot
```

After properly setting up file, we can see the affect of attacks or unwanted accesses to our server. This is extremely simple as there are simply displays instead of logging. 

Based on example code provided by Dan Sosedoff: http://sosedoff.com/2015/12/19/docker-ssh-honeypot.html

The following version contains logging, however is incompetiable with windows, I did get it working on a friend's mac though. 

### HONEYPOT

Deployed sensors with intrusion detection software installed: Snort, Kippo, Conpot, and Dionaea. 

### MANAGEMENT SERVER

Flask application that exposes an HTTP API that honeypots can use to:
- Download a deploy script
- Connect and register
- Download snort rules
- Send intrusion detection logs

It also allows systems administrators to:
- View a list of new attacks
- Manage snort rules: enable, disable, download


### INSTALLING SERVER (tested Ubuntu 12.0.4.3 x86_64 and Centos 6.7)

- The MHN server is supported on Ubuntu 12, Ubuntu 14, and Centos 6.7.  
- Ubuntu 16 is not supported at this time.  
- Other flavors/versions of Linux may work, but are generally not tested or supported.

Note: if you run into trouble during the install, please checkout the [troubleshooting guide](https://github.com/threatstream/MHN/wiki/MHN-Troubleshooting-Guide) on the wiki.  If you only want to experiment with MHN on some virtual machines, please check out the [Getting up and Running with Vagrant](https://github.com/threatstream/mhn/wiki/Getting-up-and-running-using-Vagrant) guide on the wiki.

Install Git

    # on Debian or Ubuntu
    $ sudo apt-get install git -y
    
    # on Centos or RHEL
    $ sudo yum install -y git

Install MHN
    
    $ cd /opt/
    $ sudo git clone https://github.com/threatstream/mhn.git
    $ cd mhn/

Run the following script to complete the installation.  While this script runs, you will
be prompted for some configuration options.  See below for how this looks.

    $ sudo ./install.sh


### Configuration:
    
    ===========================================================
    MHN Configuration
    ===========================================================
    Do you wish to run in Debug mode?: y/n n
    Superuser email: YOUR_EMAIL@YOURSITE.COM
    Superuser password: 
    Server base url ["http://1.2.3.4"]: 
    Honeymap url ["http://1.2.3.4:3000"]:
    Mail server address ["localhost"]: 
    Mail server port [25]: 
    Use TLS for email?: y/n n
    Use SSL for email?: y/n n
    Mail server username [""]: 
    Mail server password [""]: 
    Mail default sender [""]: 
    Path for log file ["mhn.log"]: 


### Running

If the installation scripts ran successfully, you should have a number of services running on your MHN server.  See below for checking these.

    user@precise64:/opt/mhn/scripts$ sudo /etc/init.d/nginx status
     * nginx is running
    user@precise64:/opt/mhn/scripts$ sudo /etc/init.d/supervisor status
     is running
    user@precise64:/opt/mhn/scripts$ sudo supervisorctl status
    geoloc                           RUNNING    pid 31443, uptime 0:00:12
    honeymap                         RUNNING    pid 30826, uptime 0:08:54
    hpfeeds-broker                   RUNNING    pid 10089, uptime 0:36:42
    mhn-celery-beat                  RUNNING    pid 29909, uptime 0:18:41
    mhn-celery-worker                RUNNING    pid 29910, uptime 0:18:41
    mhn-collector                    RUNNING    pid 7872,  uptime 0:18:41
    mhn-uwsgi                        RUNNING    pid 29911, uptime 0:18:41
    mnemosyne                        RUNNING    pid 28173, uptime 0:30:08

### Running MHN Behind a Proxy

For each of the files below, make sure the proxy settings are added (and obviously change the user/pass/domain/port)

These need to be set for both the MHN server and the honey systems you intend to deploy on (assuming the honeypots are behind the firewall).

## /etc/environment

```
ALL_PROXY=http://user:password@your.corporate.proxy.hostname.com:8080
HTTP_PROXY=http://user:password@your.corporate.proxy.hostname.com:8080
HTTPS_PROXY=http://user:password@your.corporate.proxy.hostname.com:8080
http_proxy=http://user:password@your.corporate.proxy.hostname.com:8080
https_proxy=http://user:password@your.corporate.proxy.hostname.com:8080
```

## /etc/apt/apt.conf.d/95proxies

```
Acquire::http::proxy "http://user:password@your.corporate.proxy.hostname.com:8080";
Acquire::https::proxy "http://user:password@your.corporate.proxy.hostname.com:8080";
Acquire::ftp::proxy "http://user:password@your.corporate.proxy.hostname.com:8080";
```


## ~/.gitconfig

```
[http]
	proxy = http://user:password@your.corporate.proxy.hostname.com:8080
```

# Commands:

These commands will make the above changes. 

```
PROXY='http://user:password@your.corporate.proxy.hostname.com:8080'

grep -F "$PROXY" /etc/environment || cat >> /etc/environment <<EOF
ALL_PROXY=$PROXY
http_proxy=$PROXY
HTTP_PROXY=$PROXY
https_proxy=$PROXY
HTTPS_PROXY=$PROXY
EOF

cat > /etc/apt/apt.conf.d/95proxies << EOF
Acquire::http::proxy "$PROXY";
Acquire::https::proxy "$PROXY";
Acquire::ftp::proxy "$PROXY";
EOF

git config --global --add http.proxy "$PROXY"

```

If done immediately before installing MHN or a honeypot, be sure to run this right after the above commands:

```
source /etc/environment
```


### Manual Password Reset

If email based password resets are not working for you, here is another method.

    $ cd $MHN_HOME
    $ source env/bin/activate
    $ cd server
    $ python manual_password_reset.py 
    Enter email address: YOUR_USER@YOUR_SITE.com
    Enter new password: 
    Enter new password (again): 
    user found, updating password

### Deploying honeypots with MHN

MHN was designed to make scalable deployment of honeypots easier.  Here are the steps for deploying a honeypot with MHN:

1. Login to your MHN server web app.
2. Click the "Deploy" link in the upper left hand corner.
3. Select a type of honeypot from the drop down menu (e.g. "Ubuntu 12.04 Dionaea").
4. Copy the deployment command.
5. Login to a honeypot server and run this command as root.
6. That's it!

### Integration with Splunk and ArcSight

hpfeeds-logger can be used to integrate MHN with Splunk and ArcSight.  Installation below.

#### Splunk


    cd /opt/mhn/scripts/
    sudo ./install_hpfeeds-logger-splunk.sh

This will log the events as key/value pairs to /var/log/mhn-splunk.log.  This log should be monitored by the SplunkUniveralForwarder.

#### Arcsight


    cd /opt/mhn/scripts/
    sudo ./install_hpfeeds-logger-arcsight.sh

This will log the events as CEF to /var/log/mhn-arcsight.log


### Data

The MHN server reports anonymized attack data back to Anomali, Inc. (formerly known as ThreatStream).  If you are interested in this data please contact: <modern-honey-network@googlegroups.com>.  This data reporting can be disabled by running the following command from the MHN server after completing the initial installation steps outlined above: `/opt/mhn/scripts/disable_collector.sh`

### Support or Contact
MHN is an open source project brought to you by the passionate folks at Anomali, Inc. Please check out our troubleshooting guide on the wiki. We will also lend a hand, if needed. Find us at: <modern-honey-network@googlegroups.com>.

### Credit and Thanks
MHN leverages and extends upon several awesome projects by the Honeynet project. Please show them your support by way of donation.


## LICENSE

Modern Honeypot Network

Copyright (C) 2017 - Anomali, Inc.

This program free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
