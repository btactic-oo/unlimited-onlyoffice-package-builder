# unlimited-onlyoffice-package-builder

Unlimited OnlyOffice Package Builder let's you build OnlyOffice with no limits and package it (currently only deb packages are supported).

## Requisites

### Introduction

In order to ease the OnlyOffice deb build this build method uses Docker under the hood. You will find instructions on how to setup your build user to use Docker. This only needs to be done once. These Docker instructions are meant for Ubuntu 20.04 but any other generic Docker setup instructions for your OS should be ok.

Be aware of RHEL 8 based distributions. Search for a [docker-ce howto](https://computingforgeeks.com/install-docker-and-docker-compose-on-rhel-8-centos-8/). Trying to install docker package directly installs *podman* and *buildah* which **do not work exactly as docker-ce** although they seem to be advertised as such.

### Docker setup

*Note: The commands for this Docker setup need to be run as either root user or a user that it's part of the sudo group, usually the admin user.*

#### Install docker prerequisites

```
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
```
#### Set up docker's apt repository

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo tee /etc/apt/sources.list.d/docker.list <<EOM
deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
EOM

sudo apt-get update
```

#### Install docker

```
sudo apt-get install docker-ce
```

## How to build example

```
mkdir ~/build-onlyoffice-test-01
cd ~/build-onlyoffice-test-01
git clone https://github.com/btactic-oo/unlimited-onlyoffice-package-builder
cd unlimited-onlyoffice-package-builder
./onlyoffice-package-builder.sh --product-version=8.0.1 --build-number=31 --unlimited-organization=btactic-oo --tag-suffix=-btactic --debian-package-suffix=-btactic
```

## More technical docs

- [README-BUILD-NEWER-VERSIONS.md](README-BUILD-NEWER-VERSIONS.md)
- [development_logs](development_logs/)
