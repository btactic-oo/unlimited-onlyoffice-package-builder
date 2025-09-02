# Build OnlyOffice on newer OnlyOffice versions (with no limits)

## Introduction

- Did the btactic-oo repos stalled at an old date in the past?
- Do you need to build a newer onlyoffice version than the one that btactic-oo `unlimited-onlyoffice-package-builder` repo released ?
- Do you want to have an unlimited onlyoffice repos instead of the default one limited to 20 connections?
- Do you want to use Github Actions so that you know you have the resources to build everything?

Well, in this case this document is for you.

You will be able to produce a Debian 11 DEB package that might also work on other Debian/Ubuntu systems.

## About failed commits

If you ever encounter an error similar to:
```
Error: cherry-pick of commit abc123 failed in reponame
```
you might need to fix the commits yourself. Taking a look at the [README-BUILD-NEWER-VERSIONS-DEPRECATED.md from v0.0.4](https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/blob/v0.0.4/README-BUILD-NEWER-VERSIONS-DEPRECATED.md) document might be useful on learning how to push your changes to Github but you do not have to follow everything there because it's based on an old method.

## Requisites

Despite what we suppose just below you could actually do everything in the same machine, either an actual machine or a virtual machine thanks to Docker.

In this document we will suppose that you have:

- A desktop GNU/Linux machine where you will have your Github keys
- A blank virtual machine with Debian 11 in it which will be only be used to build OnlyOffice
- A virtual machine with onlyoffice installed in it from the official repo packages

or in another words (with their own alias):

- A desktop GNU/Linux machine (**DESKTOPM**)
- An onlyoffice build GNU/Linux machine (**BUILDM**)
- An onlyoffice installed machine thanks to official repo packages (**ONLYM**)

## Find and replace

Make sure to download this document, make a copy of it and edit it.

Now you can find and replace the following:

- Find all the `@@ACMEOO@@` strings and replace them to your Github organisation/user. Example: `acmeoo`.
- Find all the `@@ACME@@` strings and replace them to your branding (no spaces or fancy characters). Example: `acme`. This will be used for both Git tags and Debian package suffix.
- Find all the `@@OOBUILDER@@` strings and replace them to your docker enabled user. Example: `oobuilder`.
- Given a **x.y.z.t** version that you want to build: ( Example: `8.1.2.3` )
  - Find all the `@@VERSION-X.Y.Z@@` strings and replace them to **x.y.z**. Example: `8.1.2`
  - Find all the `@@VERSION-T@@` strings and replace them to **t**. Example: `3`

### Main directory

```
mkdir ~/onlyoffice_repos
```

## Requisites (ONLYM)

This **ONLYM** machine needs to have installed the [limited onlyoffice deb package from the official repos](https://helpcenter.onlyoffice.com/installation/docs-community-install-ubuntu.aspx).

## Identify tag to build (ONLYM)

Our onlyoffice virtual machine should already have installed Debian package in it.
OnlyOffice guys never update the default one so no bother to update it or any of the directories it's using.

```
sudo apt update
sudo apt-cache show onlyoffice-documentserver | less
```
The most recent @@VERSION-X.Y.Z@@ version is:

@@VERSION-X.Y.Z@@-@@VERSION-T@@

so that's the version that we will be using.
We just replace the hyphen with a dot. @@VERSION-X.Y.Z@@-@@VERSION-T@@ is now: @@VERSION-X.Y.Z@@.@@VERSION-T@@.

## Decide where to build

If you want to build in your own VPS please check:

- [Build machine setup (BUILDM)](#build-machine-setup-buildm)

If you want to build in Github please check:

- [Release based on Github Actions (DESKTOPM)](#release-based-on-github-actions-desktopm)

## Build machine setup (BUILDM)

### About the build machine setup section

Please notice that if you decide to build directly from Github Actions this build machine won't be needed at all so you can skip this section altogether.

### Requisites

- Debian 11 Netinst was choosen (Any other Debian based distro which supports docker should also be fine).
- Required RAM: 16 GB RAM (Minimum) or 8 GB RAM with 8 GB SWAP.
- Recommended: 50 GB Hard disk space

### Docker-CE Requisite

This build method uses Docker under the hood. You will find instructions on how to setup your build user to use Docker. This only needs to be done once. These Docker instructions are meant for Ubuntu 20.04 but any other generic Docker setup instructions for your OS should be ok.

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

### Docker user - Creation

```
sudo usermod -a -G docker @@OOBUILDER@@
```

### Docker user - Re-login

In order to be able to use Docker properly from `@@OOBUILDER@@` user you might need to logout and then login to your user.
You might find how to enforce the user Docker group rights without logging out if you search enough but most of the times it's easier to just logout and login.

### Docker user - Hello world

Also make sure to run the usual 'Hello world' docker examples under the `@@OOBUILDER@@` user.
These 'Hello world' docker examples are usually explained in most of the docker installation manuals.
If 'Hello world' docker example does not work as expected then building thanks to our Dockerfiles will definitely not work.

### Git software

```
apt install git
```
should do it in most of the Debian/Ubuntu systems so that you can later use Git.

## Build (BUILDM)

### Build everything

As the `@@OOBUILDER@@` user run:

```
mkdir ~/build-oo
cd ~/build-oo
git clone https://github.com/btactic-oo/unlimited-onlyoffice-package-builder
cd unlimited-onlyoffice-package-builder
git checkout v0.0.5
# Ignore detached HEAD message
./onlyoffice-package-builder.sh --product-version=@@VERSION-X.Y.Z@@ --build-number=@@VERSION-T@@ --unlimited-organization=btactic-oo --tag-suffix=-@@ACME@@ --debian-package-suffix=-@@ACME@@
```

### Final deb package

The final `onlyoffice-documentserver_@@VERSION-X.Y.Z@@-@@VERSION-T@@-@@ACME@@_amd64.deb` deb package can be found at: `~/build-oo/unlimited-onlyoffice-package-builder/document-server-package/deb/` directory.

If you wanted to build in your own VPS **you are done.**

## Release based on Github Actions (DESKTOPM)

### Github - Create organisation or user

First of all you need to create a Github account/user, a Github organisation, or reuse your existant Github account/user.

### Git ssh keys

*Note: The commands below need to be run as the `@@OOBUILDER@@` user.*

You need to run the command below in order to create a key.

```
ssh-keygen -t rsa -b 4096 -C "@@OOBUILDER@@@domain.com"
```

the email address needs to be the one used for your GitHub account.

Then upload the `id_rsa.pub` key to your GitHub profile: [https://github.com/settings/keys](https://github.com/settings/keys).

Note: I personally only use an additional Github account because you cannot set this SSH key as a read-only one. You are supposed to use a deploy key but those are attached to a single repo or organisation.

### Login onto your Github account

You should know how to login onto your Github account. Go ahead and login there.

### Fork btactic's unlimited-onlyoffice-package-builder

- Visit [btactic-oo's unlimited-onlyoffice-package-builder repo](https://github.com/btactic-oo/unlimited-onlyoffice-package-builder).
- Click on **Fork** button.
- Select `@@ACMEOO@@` as the Owner.
- Uncheck 'Copy the main branch only'
- **Do not modify** Repository name
- Click on **Create fork** button

### Fork ONLYOFFICE's build_tools

- Visit [ONLYOFFICE's build_tools repo](https://github.com/ONLYOFFICE/build_tools).
- Click on **Fork** button.
- Select `@@ACMEOO@@` as the Owner.
- Uncheck 'Copy the main branch only'
- **Do not modify** Repository name
- Click on **Create fork** button

### Fork ONLYOFFICE's server

- Visit [ONLYOFFICE's server repo](https://github.com/ONLYOFFICE/server).
- Click on **Fork** button.
- Select `@@ACMEOO@@` as the Owner.
- Uncheck 'Copy the main branch only'
- **Do not modify** Repository name
- Click on **Create fork** button

### Fork ONLYOFFICE's web-apps

- Visit [ONLYOFFICE's web-apps repo](https://github.com/ONLYOFFICE/web-apps).
- Click on **Fork** button.
- Select `@@ACMEOO@@` as the Owner.
- Uncheck 'Copy the main branch only'
- **Do not modify** Repository name
- Click on **Create fork** button

### Main directory

```
mkdir ~/onlyoffice_repos
```

### Clone your own unlimited-onlyoffice-package-builder repo

You can actuall skip this step but it's nice to have actual repos in your computer just in case they disappear.

```
cd ~/onlyoffice_repos
git clone git@github.com:@@ACMEOO@@/unlimited-onlyoffice-package-builder.git
```

### Clone your own build_tools repo

```
cd ~/onlyoffice_repos
git clone git@github.com:@@ACMEOO@@/build_tools.git
```

### Clone your own server repo

```
cd ~/onlyoffice_repos
git clone git@github.com:@@ACMEOO@@/server.git
```

### Clone your own web-apps repo

```
cd ~/onlyoffice_repos
git clone git@github.com:@@ACMEOO@@/web-apps.git
```

## Add upstream and btactic repos as remotes (DESKTOPM)

We will need to be able to fetch from both upstream (ONLYOFFICE) and btactic repos.
From upstream we will get the latest tags (useful if you repeat this process in the future).
And from btactic repos you will get the no-limits commits just in case you don't want to recreate them manually.

We will do this step in one go for all of the needed repos so that it does not take too much space in the document.

```
cd ~/onlyoffice_repos/build_tools
git remote add upstream-origin git@github.com:ONLYOFFICE/build_tools.git
git remote add btactic-origin git@github.com:btactic-oo/build_tools.git

cd ~/onlyoffice_repos/server
git remote add upstream-origin git@github.com:ONLYOFFICE/server.git
git remote add btactic-origin git@github.com:btactic-oo/server.git

cd ~/onlyoffice_repos/web-apps
git remote add upstream-origin git@github.com:ONLYOFFICE/web-apps.git
git remote add btactic-origin git@github.com:btactic-oo/web-apps.git
```

## Update and Fetch newest tags (DESKTOPM)

Once again we do it in one go.

```
cd ~/onlyoffice_repos/build_tools
git checkout master
git pull upstream-origin master
git fetch --all --tags

cd ~/onlyoffice_repos/server
git checkout master
git pull upstream-origin master
git fetch --all --tags

cd ~/onlyoffice_repos/web-apps
git checkout master
git pull upstream-origin master
git fetch --all --tags
```

### Enable Github Actions

Visit [https://github.com/@@ACMEOO@@/unlimited-onlyoffice-package-builder/actions](https://github.com/@@ACMEOO@@/unlimited-onlyoffice-package-builder/actions) and click on the **I understand my workflows, go ahead and enable them** button.

### Use your repos when running Github Actions

```
cd ~/onlyoffice_repos/unlimited-onlyoffice-package-builder
git checkout main
sed -i 's/DEBIAN_PACKAGE_SUFFIX: -btactic/DEBIAN_PACKAGE_SUFFIX: -@@ACME@@/g' .github/workflows/build-release-debian-11.yml
sed -i 's/TAG_SUFFIX: -btactic/TAG_SUFFIX: -@@ACME@@/g' .github/workflows/build-release-debian-11.yml
git add .github/workflows/build-release-debian-11.yml
git commit -m 'Use @@ACME@@ as a suffix in Github Actions'
git push origin main
```

### Push to build

```
cd ~/onlyoffice_repos/unlimited-onlyoffice-package-builder
git checkout main
git push origin main # Just to be safe
git tag -a 'builds-debian-11/@@VERSION-X.Y.Z@@.@@VERSION-T@@' -m 'builds-debian-11/@@VERSION-X.Y.Z@@.@@VERSION-T@@'
git push origin 'builds-debian-11/@@VERSION-X.Y.Z@@.@@VERSION-T@@'
```
.

Release based on Github Actions which you can check in: [https://github.com/@@ACMEOO@@/unlimited-onlyoffice-package-builder/actions](https://github.com/@@ACMEOO@@/unlimited-onlyoffice-package-builder/actions) should end succesfully after about 2h30m build time.

Check the new release at: [https://github.com/@@ACMEOO@@/unlimited-onlyoffice-package-builder/releases](https://github.com/@@ACMEOO@@/unlimited-onlyoffice-package-builder/releases).

If you wanted to build in Github **you are done.**

## Words of wisdom

- If you want feedback please make sure to describe:
  - How docker is installed on your VPS
  - What are the exact commands that you run
- OnlyOffice guys are not using the public tools published here to build their binaries, they use another set of tools which, in theory, should work quite similar.
- You are advised somewhere in the build documentation to use the master branch but you should stick to a tag so that you always get the same results.
- Unfortunately a lot of external dependencies of OnlyOffice are based not on tags (specific versions) but on master branches. **That's a big bug on their part.**
- So, even if you manage to build OnlyOffice one day without OnlyOffice repos being changed it might fail the next day because of some external dependency having changed a lot or being temporarily down.
- If you live in countries similar to Russia or China you might not have to access to some of those external dependencies because of geo-blocking issues.
- The same might happen if you don't have an stable internet connection. The build system does not allow to easily re-run just the latest step which failed because of an Internet timeout.
- You also have to know that when a build step has failed it's much better for you to start from scratch than try to resume the build. That failure might avoid you to build everything ok again. Well, at least try it once more from an empty folder.
- You need enough RAM. This is known to fail with only 4 GB RAM. It works for me with 16 GB RAM.

## Warning

This is not an official onlyoffice build. Do not seek for help on OnlyOffice issues/forums unless you replicate it on original source code or original binaries from them.

## Useful links

- [https://www.btactic.com/build-onlyoffice-from-source-code-2023/?lang=en](https://www.btactic.com/build-onlyoffice-from-source-code-2023/?lang=en)
- [https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/tree/main/development_logs](https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/tree/main/development_logs)

## Feedback

Please [create a new issue of your experience](https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/issues) (with your applied workarounds for an specific onlyoffice version) so that we can all learn from your experience.
