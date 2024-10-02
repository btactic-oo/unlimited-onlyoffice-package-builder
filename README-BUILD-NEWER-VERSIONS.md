# Build OnlyOffice on newer OnlyOffice versions (with no limits)

## Introduction

- Did the btactic-oo repos stalled at an old date in the past?
- Do you need to build a newer onlyoffice version than the one that btactic-oo `unlimited-onlyoffice-package-builder` repo released ?
- Do you want to have an unlimited onlyoffice repos instead of the default one limited to 20 connections?
- Do you want to use Github Actions so that you know you have the resources to build everything?

Well, in this case this document is for you.

Please [create a new issue of your experience](https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/issues) (with your applied workarounds for an specific onlyoffice version) so that we can all learn from your experience.

You will be able to produce a Debian 11 DEB package that might also work on other Debian/Ubuntu systems.

If you have already followed these instructions and you are reusing your DESKTOPM machine and you want to build a newer Onlyoffice version you can skip to the: [Update and Fetch newest tags (DESKTOPM)](#update-and-fetch-newest-tags-desktopm) section.

## About development logs

This specific documentation won't be updated so much.
It will be based on the current latest simplified documentation which it's *2024 09*.
Please check [development_logs/ directory](development_logs/). You might want to cherry-pick some commits from there instead of the *2024 09* ones which will be used here.

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

## Github - Fork time

First of all you need to create a Github account/user, a Github organisation, or reuse your existant Github account/user.

Please notice that this new/reused account/user/organisation will be called `acmeoo` in this document.
Feel free to download this document locally and find `acmeoo` in it and **replace it to your own new/reused account/user/organisation**.

### Login onto your Github account

You should know how to login onto your Github account. Go ahead and login there.

### Fork btactic's unlimited-onlyoffice-package-builder

- Visit [btactic-oo's unlimited-onlyoffice-package-builder repo](https://github.com/btactic-oo/unlimited-onlyoffice-package-builder).
- Click on **Fork** button.
- Select `acmeoo` as the Owner.
- Uncheck 'Copy the main branch only'
- **Do not modify** Repository name
- Click on **Create fork** button

### Fork ONLYOFFICE's build_tools

- Visit [ONLYOFFICE's build_tools repo](https://github.com/ONLYOFFICE/build_tools).
- Click on **Fork** button.
- Select `acmeoo` as the Owner.
- Uncheck 'Copy the main branch only'
- **Do not modify** Repository name
- Click on **Create fork** button

### Fork ONLYOFFICE's server

- Visit [ONLYOFFICE's server repo](https://github.com/ONLYOFFICE/server).
- Click on **Fork** button.
- Select `acmeoo` as the Owner.
- Uncheck 'Copy the main branch only'
- **Do not modify** Repository name
- Click on **Create fork** button

### Fork ONLYOFFICE's web-apps

- Visit [ONLYOFFICE's web-apps repo](https://github.com/ONLYOFFICE/web-apps).
- Click on **Fork** button.
- Select `acmeoo` as the Owner.
- Uncheck 'Copy the main branch only'
- **Do not modify** Repository name
- Click on **Create fork** button

## Prepare new local repos (DESKTOPM)

### Warning

You might have a custom directory where you build everything onlyoffice related. I recommend you to use what it's given to you here instead. Otherwise you will have to find `onlyoffice_repos` and replace it to your own directory and making sure that you use the same directory structure.

### Github ssh keys

Make sure that your user has had its own [ssh keys associated to your Github user](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account). You will need it in order to push onto Github repos later.

### Main directory

```
mkdir ~/onlyoffice_repos
```

### Clone your own unlimited-onlyoffice-package-builder repo

You can actuall skip this step but it's nice to have actual repos in your computer just in case they disappear.

```
cd ~/onlyoffice_repos
git clone git@github.com:acmeoo/unlimited-onlyoffice-package-builder.git
```

### Clone your own build_tools repo

```
cd ~/onlyoffice_repos
git clone git@github.com:acmeoo/build_tools.git
```

### Clone your own server repo

```
cd ~/onlyoffice_repos
git clone git@github.com:acmeoo/server.git
```

### Clone your own web-apps repo

```
cd ~/onlyoffice_repos
git clone git@github.com:acmeoo/web-apps.git
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

## Requisites (ONLYM)

This **ONLYM** machine needs to have installed the [limited onlyoffice deb package from the official repos](https://helpcenter.onlyoffice.com/installation/docs-community-install-ubuntu.aspx).

## Identify tag to build (ONLYM)

OnlyOffice guys never update the default one so no bother to update it or any of the directories it's using.

```
sudo apt update
sudo apt-cache show onlyoffice-documentserver | less
```
The most recent 8.1.3 version is:

8.1.3-4

so that's the version that we will be using.
Well, we will be using **8.1.3.3** instead because 8.1.3.4 is not available.

## Apply no-limits to our repos (DESKTOPM)

### Tag naming

This document assumes that your tag naming is `tacme`.
Feel free to download this document locally and find `tacme` in it and **replace it to your own tag name**.

### build_tools repo update

Old stuff that we already have from btactic repos:

- commit (owner changes in ssh): 7ce465ecb177fd20ebf2b459a69f98312f7a8d3d
- commit (Custom repos and tags): 7da607da885285fe3cfc9feaf37b1608666039eb

We create a new branch based on the recently fetched tag.

```
cd ~/onlyoffice_repos/build_tools
git checkout tags/v8.1.3.3 -b 8.1.3.3-tacme
```

Cherry-pick what we already had:

```
git cherry-pick 7ce465ecb177fd20ebf2b459a69f98312f7a8d3d
git cherry-pick 7da607da885285fe3cfc9feaf37b1608666039eb
```
.

Find and replace btactic organisation and its suffix with our own:
```
sed -i 's/unlimited_organization = "btactic-oo"/unlimited_organization = "acmeoo"/g' scripts/base.py
sed -i 's/unlimited_tag_suffix = "-btactic"/unlimited_tag_suffix = "-tacme"/g' scripts/base.py
```
.

Amend the last commit to use our own tags.
```
git add scripts/base.py
git commit --amend --no-edit
```

Let's push and create appropiate tags:

```
git push origin 8.1.3.3-tacme
git tag -a 'v8.1.3.3-tacme' -m '8.1.3.3-tacme'
git push origin v8.1.3.3-tacme
```

### server repo update

Old stuff that we already have from btactic repos:

- commit (connection limit): cb6100664657bc91a8bae82d005f00dcc0092a9c

We create a new branch based on the recently fetched tag.

```
cd ~/onlyoffice_repos/server
git checkout tags/v8.1.3.3 -b 8.1.3.3-tacme
```
.

Cherry-pick what we already had:

```
git cherry-pick cb6100664657bc91a8bae82d005f00dcc0092a9c
```

Let's push and create appropiate tags:

```
git push origin 8.1.3.3-tacme
git tag -a 'v8.1.3.3-tacme' -m '8.1.3.3-tacme'
git push origin v8.1.3.3-tacme
```

### web-apps repo update

Old stuff that we already have from btactic repos:

- commit (mobile edit): 2d186b887bd1f445ec038bd9586ba7da3471ba05

We create a new branch based on the recently fetched tag.

```
cd ~/onlyoffice_repos/web-apps
git checkout tags/v8.1.3.3 -b 8.1.3.3-tacme
```
.

Cherry-pick what we already had:

```
git cherry-pick 2d186b887bd1f445ec038bd9586ba7da3471ba05
```

Let's push and create appropiate tags:

```
git push origin 8.1.3.3-tacme
git tag -a 'v8.1.3.3-tacme' -m '8.1.3.3-tacme'
git push origin v8.1.3.3-tacme
```

## Introduction
This is a simplified log of how we managed to bring out the 'No limits' version of OnlyOffice for those of you that like technical articles.

- It's 2024 September and we need to build OnlyOffice 8.1.3.3.

- Please remember: **This is not a Docker build that you can use in production. This is a Docker system that let's you build a Debian package binary.**

You are also advised to check: [README-BUILD-DEBIAN-PACKAGE-NO-LIMITS.md](README-BUILD-DEBIAN-PACKAGE-NO-LIMITS.md) which are more straight-forward build and **use** instructions.

## Initial tasks TODO

- Internal build system is already there. No need to build it again.
  - Debian 11 Netinst was choosen (Any other Debian based distro which supports docker should also be fine).
  - Required RAM: 16 GB RAM (Minimum) or 8 GB RAM with 8 GB SWAP.
  - Recommended: 50 GB Hard disk space

- As we did before we should be able to build stuff thanks to `document-server-package` repo without almost no changes.

- Create custom `build_tools` tag so that it uses our `server` and `web-apps` repo with our patch.

- Create custom `server` branch with our patches (connection limits increase).

- Create custom `web-apps` branch with our patches (mobile edit).

- Check what packages are available in the official Debian/Ubuntu repository so that we use that exact version.

- Update github documentation.

- Update Nextcloud forum post.

- Update www.btactic.com post or create a new one.

- Update Bibliography if needed.

## Development log

### VM Snapshot

Snapshot our build virtual machine so that we can revert to initial state when needed.

### Official OnlyOffice package version

Our onlyoffice virtual machine for tests already has a repo.
OnlyOffice guys never update the default one so no bother to update it or any of the directories it's using.

```
sudo apt update
sudo apt-cache show onlyoffice-documentserver | less
```
The most recent 8.1.3 version is:

8.1.3-4

so that's the version that we will be using.
Well, we will be using 8.1.3.3 instead because 8.1.3.4 is not available.

## Decide where to build

If you want to build in your own VPS please check the following sections:

- [Build machine setup (BUILDM)](#build-machine-setup-buildm)
- **TODO**

If you want to build in Github please check the following sections:

- **TODO**
- **TODO**

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
sudo usermod -a -G docker oobuilder
```

### Docker user - Re-login

In order to be able to use Docker properly from `oobuilder` user you might need to logout and then login to your user.
You might find how to enforce the user Docker group rights without logging out if you search enough but most of the times it's easier to just logout and login.

### Docker user - Hello world

Also make sure to run the usual 'Hello world' docker examples under the `oobuilder` user.
These 'Hello world' docker examples are usually explained in most of the docker installation manuals.
If 'Hello world' docker example does not work as expected then building thanks to our Dockerfiles will definitely not work.

### Git ssh keys

*Note: The commands below need to be run as the `oobuilder` user.*

You need to run the command below in order to create a key.

```
ssh-keygen -t rsa -b 4096 -C "zimbra-builder@domain.com"
```

the email address needs to be the one used for your GitHub account.

Then upload the `id_rsa.pub` key to your GitHub profile: [https://github.com/settings/keys](https://github.com/settings/keys).

Note: I personally only use an additional Github account because you cannot set this SSH key as a read-only one. You are supposed to use a deploy key but those are attached to a single repo or organisation.

### Git software

```
apt install git
```
should do it in most of the Debian/Ubuntu systems so that you can later use Git.

## Build (BUILDM)

### Build everything

As the `oobuilder` user run:

```
mkdir ~/build-oo
cd ~/build-oo
git clone https://github.com/acmeoo/unlimited-onlyoffice-package-builder
cd unlimited-onlyoffice-package-builder
git checkout v0.0.1
# Ignore detached HEAD message
./onlyoffice-package-builder.sh --product-version=8.1.3 --build-number=3 --unlimited-organization=acmeoo --tag-suffix=-tacme --debian-package-suffix=-tacme
```

### Final deb package

The final `onlyoffice-documentserver_8.1.3-3-tacme_amd64.deb` deb package can be found at: `~/build-oo/unlimited-onlyoffice-package-builder/document-server-package/deb/` directory.

## Release based on Github Actions (DESKTOPM)

### Enable Github Actions

Visit [https://github.com/acmeoo/unlimited-onlyoffice-package-builder/actions](https://github.com/acmeoo/unlimited-onlyoffice-package-builder/actions) and click on the **I understand my workflows, go ahead and enable them** button.

### Use your repos when running Github Actions

```
cd ~/onlyoffice_repos/unlimited-onlyoffice-package-builder
git checkout main
sed -i 's/DEBIAN_PACKAGE_SUFFIX: -btactic/DEBIAN_PACKAGE_SUFFIX: -tacme/g' .github/workflows/build-release-debian-11.yml
sed -i 's/TAG_SUFFIX: -btactic/TAG_SUFFIX: -tacme/g' .github/workflows/build-release-debian-11.yml
git add .github/workflows/build-release-debian-11.yml
git commit -m 'Use tacme as a suffix in Github Actions'
git push origin main
```

### Push to build

```
cd ~/onlyoffice_repos/unlimited-onlyoffice-package-builder
git checkout main
git push origin main # Just to be safe
git tag -a 'builds-debian-11/8.1.3.3' -m 'builds-debian-11/8.1.3.3'
git push origin 'builds-debian-11/8.1.3.3'
```
.

Release based on Github Actions which you can check in: [https://github.com/acmeoo/unlimited-onlyoffice-package-builder/actions](https://github.com/acmeoo/unlimited-onlyoffice-package-builder/actions) should end succesfully after about 2h30m build time.

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
- [https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/releases/tag/onlyoffice-unlimited-build-debian-11%2F8.1.3.3](https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/releases/tag/onlyoffice-unlimited-build-debian-11%2F8.1.3.3)
- [https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/tree/main/development_logs](https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/tree/main/development_logs)

## Feedback

You can give feedback on how to improve this document at: [https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/issues/3](https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/issues/3).
