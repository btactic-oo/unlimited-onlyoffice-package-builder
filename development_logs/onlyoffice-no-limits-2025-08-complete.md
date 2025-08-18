# OnlyOffice - 2025 August - No limits - Complete log

## Introduction
This is a complete log of how we managed to bring out the 'No limits' version of OnlyOffice for those of you that like technical articles.

- It's 2025 August and we need to build OnlyOffice 9.0.4.50.

- Please remember: **This is not a Docker build that you can use in production. This is a Docker system that let's you build a Debian package binary.**

You are also advised to check: [README-BUILD-DEBIAN-PACKAGE-NO-LIMITS.md](README-BUILD-DEBIAN-PACKAGE-NO-LIMITS.md) which are more straight-forward build and **use** instructions.

## Initial tasks TODO

- Internal build system is already there. No need to build it again.
  - Debian 11 Netinst was choosen (Any other Debian based distro which supports docker should also be fine).
  - Required RAM: 16 GB RAM (Minimum) or 8 GB RAM with 8 GB SWAP.
  - Recommended: 50 GB Hard disk space

- Create custom `build_tools` tag so that it uses our `server` and `web-apps` repo with our patch.

- Create custom `server` branch with our patches (connection limits increase).

- Create custom `web-apps` branch with our patches (mobile edit).

- Check what packages are available in the official Debian/Ubuntu repository so that we use that exact version.

- Update github documentation.

- Update Nextcloud forum post.

- Update www.btactic.com post or create a new one.

- Update Bibliography if needed.

## Additional work after the build

- Complain on `document-server-package` repo because they do not fix bugs.

- Update new deb binary package.

## Development log

### VM Snapshot

Snapshot our build virtual machine so that we can revert to initial state when needed.

### Official OnlyOffice package version

Our build virtual machine already has a repo.
OnlyOffice guys never update the default one so no bother to update it or any of the directories it's using.

```
sudo apt update
sudo apt-cache show onlyoffice-documentserver | less
```
The most recent 9.0.4 version is:

9.0.4-50

so that's the version that we will be using.

### build_tools repo update

#### Introduction

Old stuff that we already had:
- tag: v8.1.3.3-btactic

- commit (owner changes in ssh): 2e42e83151bd11609c1d2fbaabcc3f0f7b587497
- commit (Custom repos and tags): 7da607da885285fe3cfc9feaf37b1608666039eb

Well, I am fed up to have to edit always this specific repo when they do any change in it regarding how they update git repos.

It's time to submit a pull request with some nice options which we can rely on in the future.

#### build_tools repo update ( New override pull request )

Repo and Repo branches override branch: [https://github.com/btactic-oo/build_tools/tree/9.0.4.50-new-override]

Let's try it with in such a way that:
```
'cd tools/linux && python3 ./automate.py --branch=tags/'"v9.0.4.50-btactic"
```
becomes:
```
'cd tools/linux && python3 ./automate.py \
  --branch=tags/'"v9.0.4.50" \
  --repo-overrides=server=https://github.com/btactic-oo/server.git,web-apps=https://github.com/btactic-oo/web-apps.git \
  --repo-branch-overrides=server=tags/'"v9.0.4.50-btactic",web-apps=tags/'"v9.0.4.50-btactic"
```

.

So in order to test all of this we need the actual server and web-apps repos done.

#### build_tools repo update ( Build manually)

```
# I already had it built.
# I just wanted to be able to interact with it
# without messing with the VM itself

docker run -it onlyoffice-document-editors-builder bash

apt update && apt install git

cd /
git clone https://github.com/btactic-oo/build_tools build_tools_override
cd build_tools_override
git checkout 9.0.4.50-new-override

cd tools/linux

python3 ./automate.py \
  --branch=tags/"v9.0.4.50" \
  --repo-overrides server=https://github.com/btactic-oo/server.git,web-apps=https://github.com/btactic-oo/web-apps.git \
  --repo-branch-overrides server=tags/"v9.0.4.50-btactic",web-apps=tags/"v9.0.4.50-btactic"
```

Ok, we are getting:
```
Traceback (most recent call last):
  File "./automate.py", line 5, in <module>
    import base
  File "../../scripts/base.py", line 540
    return f"https://{host}/"
                            ^
SyntaxError: invalid syntax
```
.

I saw an issue about this. [build_tools issue: ./automate.py server failed.](https://github.com/ONLYOFFICE/build_tools/issues/902) And there's also a related pull request which enforces using python3. [Update Dockerfile](https://github.com/ONLYOFFICE/build_tools/pull/900).

And this is another [pull request which doesn't nail it](Update base.py).

Well... I think I am going to fix that manually and, so, we will have an updated build_tools repo till they fix it properly in the repo.

Anyways I think this is related to the Docker being still Ubuntu 16.04 and not having a python version that supports that kind of syntax.

Let's take a look if we are supposed to build in something greater than Ubuntu 16.04 or if we are supposed to update our Docker image so that it uses its custom Python 3.x.

```
return f"https://{host}/"
```
gets translated onto:
```
return ("https://" + host + "/")
```
.

**Wait a moment.**

According to the latest changes this is building in Ubuntu 20.04. So... **let's create the docker image from scratch instead of reusing an old one**.

```
git clone https://github.com/btactic-oo/build_tools build_tools_override
cd build_tools_override
git checkout 9.0.4.50-new-override

docker build --tag onlyoffice-document-editors-builder .

docker run -it onlyoffice-document-editors-builder bash

apt update && apt install git

cd /
git clone https://github.com/btactic-oo/build_tools build_tools_override
cd build_tools_override
git checkout 9.0.4.50-new-override

cd tools/linux

python3 ./automate.py \
  --branch=tags/"v9.0.4.50" \
  --repo-overrides server=https://github.com/btactic-oo/server.git,web-apps=https://github.com/btactic-oo/web-apps.git \
  --repo-branch-overrides server=tags/"v9.0.4.50-btactic",web-apps=tags/"v9.0.4.50-btactic"
```

Well, even in Ubuntu 20.04 we are getting the same exact error:

```
Traceback (most recent call last):
  File "./make.py", line 12, in <module>
    import config
  File "/build_tools_override/scripts/config.py", line 3, in <module>
    import base
  File "/build_tools_override/scripts/base.py", line 540
    return f"https://{host}/"
                            ^
SyntaxError: invalid syntax
Error (./make.py): 1
```

so... again... I edit `../../scripts/base.py` so that `return f"https://{host}/"` gets translated onto: `return ("https://" + host + "/")`. Later on I will make a proper commit and a pull request.

Well... after reading the develop branch I have found v9.0.4.52 version which probably fixes this by enforcing their own python3 binaries.

**Well, let's start again, well, sort of.**

Let's prepare our own branch with v9.0.4.52 so that we can build with this and our own repos override commit.

```
cd onlyoffice_repos/build_tools
git checkout master
git pull upstream-origin master
git fetch --all --tags

git checkout tags/v9.0.4.52 -b 9.0.4.52-new-override
git cherry-pick 60bc2caf037755da8a7780b6fd57627ef63306c6
git push origin 9.0.4.52-new-override
```

At this point we create and push v9.0.4.52 tags for `server` and `web-apps` repos so that we do not mix versions later on.

**Let's try again to build in the build VM from scratch**

```
git clone https://github.com/btactic-oo/build_tools build_tools_override52
cd build_tools_override52
git checkout 9.0.4.52-new-override

docker build --tag onlyoffice-document-editors-builder .

docker run -it onlyoffice-document-editors-builder bash

apt update && apt install git

cd /
git clone https://github.com/btactic-oo/build_tools build_tools_override52
cd build_tools_override52
git checkout 9.0.4.52-new-override

cd tools/linux

python3 ./automate.py \
  --branch=tags/"v9.0.4.52" \
  --repo-overrides=server=https://github.com/btactic-oo/server.git,web-apps=https://github.com/btactic-oo/web-apps.git \
  --repo-branch-overrides=server=tags/"v9.0.4.52-btactic",web-apps=tags/"v9.0.4.52-btactic"
```

Let's see what happens now. It's detecting the `--repo-overrides` as something else. That's because I was missing an `=` while setting the arguments. This will need to written properly when implemented in the main script.

Ok, now this seems to work. The build has not finished but the repo and branches overrides have worked as expected.

## Build check

I'm not sure if it has worked ok or not. This is the latest output:
```
To address all issues, run:
  npm audit fix

Run `npm audit` for details.
> pkg@6.6.0
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11045  100 11045    0     0  93601      0 --:--:-- --:--:-- --:--:-- 93601
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 22832  100 22832    0     0   158k      0 --:--:-- --:--:-- --:--:--  158k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 16631  100 16631    0     0   106k      0 --:--:-- --:--:-- --:--:--  106k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11045  100 11045    0     0   371k      0 --:--:-- --:--:-- --:--:--  371k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 22832  100 22832    0     0   543k      0 --:--:-- --:--:-- --:--:--  543k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 16631  100 16631    0     0   451k      0 --:--:-- --:--:-- --:--:--  451k
delete warning [file not exist]: /build_tools_override52/scripts/../out/linux_64/onlyoffice/desktopeditors/editors/sdkjs/slide/sdk-all.cache
copy warning [file not exist]: /build_tools_override52/scripts/../../core/build/lib/linux_64/libdocbuilder.jni.so
patchelf: getting info about 'libdocbuilder.jni.so': No such file or directory
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11045  100 11045    0     0   326k      0 --:--:-- --:--:-- --:--:--  326k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 22832  100 22832    0     0   675k      0 --:--:-- --:--:-- --:--:--  675k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 16631  100 16631    0     0   464k      0 --:--:-- --:--:-- --:--:--  464k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11045  100 11045    0     0  72664      0 --:--:-- --:--:-- --:--:-- 72664
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 22832  100 22832    0     0   530k      0 --:--:-- --:--:-- --:--:--  518k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 16631  100 16631    0     0   142k      0 --:--:-- --:--:-- --:--:--  142k
delete warning [file not exist]: /build_tools_override52/scripts/../out/linux_64/onlyoffice/documentserver-snap/var/www/onlyoffice/documentserver/example/nodejs/example
```
which it's not what I'm used to.

After some folder renaming and moving I manage to run `make deb` manually and it does not seem to complain too much.

In the next step I'll jump on the unlimited script part so that it knows how to use this.

#### build_tools repo update ( Build Fallback)

Till the pull request is accepted we will fallback to this below:

Let's fetch recent information from official OnlyOffice repo.

```
cd onlyoffice_repos/build_tools
git checkout master
git pull upstream-origin master
git fetch --all --tags
```

We create a new branch based on the recently fetched tag.

```
git checkout tags/v9.0.4.52 -b 9.0.4.52-btactic
```

.

Cherry-pick what we already had:

```
git cherry-pick 60bc2caf037755da8a7780b6fd57627ef63306c6
```
.

Let's push and create appropiate tags:

```
git push origin 9.0.4.52-btactic
git tag -a 'v9.0.4.52-btactic' -m '9.0.4.52-btactic'
git push origin v9.0.4.52-btactic
```

### server repo update

Old stuff that we already had:
- tag: v8.1.3.3-btactic
- commit (connection limit): 81db34dee17f8a6a364669232a8c7c2f5d36d81f

Let's fetch recent information from official OnlyOffice repo.

```
cd onlyoffice_repos/server
git checkout master
git pull upstream-origin master
git fetch --all --tags
```
.

We create a new branch based on the recently fetched tag.

```
git checkout tags/v9.0.4.52 -b 9.0.4.52-btactic
```
.

Cherry-pick what we already had:

```
git cherry-pick 81db34dee17f8a6a364669232a8c7c2f5d36d81f
```

Let's push and create appropiate tags:

```
git push origin 9.0.4.52-btactic
git tag -a 'v9.0.4.52-btactic' -m 'v9.0.4.52-btactic'
git push origin v9.0.4.52-btactic
```

### web-apps repo update

Old stuff that we already had:
- tag: v8.1.3.3-btactic
- commit (mobile edit): 140ef6d1d687532dcb03b05912838b8b4cf161a3

Let's fetch recent information from official OnlyOffice repo.

```
cd onlyoffice_repos/web-apps
git checkout master
git pull upstream-origin master
git fetch --all --tags
```
.

We create a new branch based on the recently fetched tag.

```
git checkout tags/v9.0.4.52 -b 9.0.4.52-btactic
```
.

Cherry-pick what we already had:

```
git cherry-pick 140ef6d1d687532dcb03b05912838b8b4cf161a3
```

Let's push and create appropiate tags:

```
git push origin 9.0.4.52-btactic
git tag -a 'v9.0.4.52-btactic' -m 'v9.0.4.52-btactic'
git push origin v9.0.4.52-btactic
```

### Update unlimited-onlyoffice-package-builder with repo overrides

We work on it on a new `new-override-v001` branch.

We have done the commit, we just need to test it either on a VM or, even better, thanks to Github actions.

For now we test it in a VM to see what happens.

Not enough space. Let's repeat again after deleting some stuff.

```
git clone https://github.com/btactic-oo/unlimited-onlyoffice-package-builder.git 
cd unlimited-onlyoffice-package-builder/
git checkout new-override-v001
./onlyoffice-package-builder.sh --product-version=9.0.4 --build-number=52 --unlimited-organization=btactic-oo --tag-suffix=-btactic --debian-package-suffix=-btactic
```

Another fix and we try it again.

Ok, now this seems to work.

We would we done by now.

### Build from build virtual machine (Optional)

This virtual machine has Docker installed in it.
And its build user can run docker commands.

```
mkdir ~/build-oo
cd ~/build-oo
git clone https://github.com/btactic-oo/unlimited-onlyoffice-package-builder
cd unlimited-onlyoffice-package-builder
./onlyoffice-package-builder.sh --product-version=9.0.4 --build-number=52 --unlimited-organization=btactic-oo --tag-suffix=-btactic --debian-package-suffix=-btactic
```

### Final package (Optional)

The final `onlyoffice-documentserver_9.0.4-52-btactic_amd64.deb` deb package can be found at: `~/build-oo/unlimited-onlyoffice-package-builder/document-server-package/deb/` directory.

### Release (Based on Github Actions)

We should be able to build and publish a release in our `unlimited-onlyoffice-package-builder` repo thanks to:

```
cd onlyoffice_repos/unlimited-onlyoffice-package-builder
git checkout main
git push origin main # Just to be safe
git tag -a 'builds-debian-11/9.0.4.52' -m 'builds-debian-11/9.0.4.52'
git push origin 'builds-debian-11/9.0.4.52'
```
.

Release based on Github Actions seems to fail too hard.

```
onlyoffice-release (debian-11)
GitHub Actions has encountered an internal error when running your job.
```

Here's the problem:
```
Run docker rmi $(docker image ls -aq)
  docker rmi $(docker image ls -aq)
  df -h
  shell: /usr/bin/bash -e {0}
  env:
    DEBIAN_PACKAGE_SUFFIX: -btactic
    TAG_SUFFIX: -btactic
    DISTRO_FULLNAME: Debian 11
    DISTRO_TAG_PREFIX: debian-11
docker: 'docker rmi' requires at least 1 argument
Usage:  docker rmi [OPTIONS] IMAGE [IMAGE...]
See 'docker rmi --help' for more information
Error: Process completed with exit code 1.
```

So, apparently we should only remove those docker images if they are not there.

Let's see if any of our forks has fixed this (without just removing the step).

Although I'm not very sure why they would remove those docker images in the first place. Who put them there before?
Yeah, probably earlier builds.

Anyways, that was fixed. Let's hope the Github Actions builds ends ok right now.

## Useful links

- [https://www.btactic.com/build-onlyoffice-from-source-code-2023/?lang=en](https://www.btactic.com/build-onlyoffice-from-source-code-2023/?lang=en)
- [https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/releases/tag/onlyoffice-unlimited-build-debian-11%2F9.0.4.50](https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/releases/tag/onlyoffice-unlimited-build-debian-11%2F9.0.4.50)
- [https://github.com/btactic-oo/document-server-package/blob/btactic-documentation/README-BUILD-DEBIAN-PACKAGE-NO-LIMITS.md](https://github.com/btactic/document-server-package/blob/btactic-documentation/README-BUILD-DEBIAN-PACKAGE-NO-LIMITS.md)
- [https://github.com/btactic-oo/document-server-package/blob/btactic-documentation/onlyoffice-no-limits-2023-01.md](https://github.com/btactic/document-server-package/blob/btactic-documentation/onlyoffice-no-limits-2023-01.md)

## Additional developer notes

- Fork OnlyOffice repos from Github UI

- Then clone the repos from your own username/organisation

- Onlyoffice remote for server repo:
```
cd onlyoffice_repos/server
git remote add upstream-origin git@github.com:ONLYOFFICE/server.git
```

- Onlyoffice remote for build_tools repo:
```
cd onlyoffice_repos/build_tools
git remote add upstream-origin git@github.com:ONLYOFFICE/build_tools.git
```

- Onlyoffice remote for web-apps repo:
```
cd onlyoffice_repos/web-apps
git remote add upstream-origin git@github.com:ONLYOFFICE/web-apps.git
```

- Use screen, byobu or tmux when building in your virtual machine so that build is not lost because of a network disconnection

## Warning

This is not an official onlyoffice build. Do not seek for help on OnlyOffice issues/forums unless you replicate it on original source code or original binaries from them.

## Extra temp notes

```
../split-for-ai-v002.sh --prefix="This is Zimbra zm-build repo build.pl file. Please acknowledge and wait for instructions." --postfix="" build.pl
```
