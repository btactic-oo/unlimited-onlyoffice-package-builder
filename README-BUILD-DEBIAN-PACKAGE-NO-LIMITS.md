# Build OnlyOffice Debian Package (No limits)

## Introduction

This howto explains in an straight-forward manner how to build from [bTactic](https://www.btactic.com/) modified repos an OnlyOffice Debian package.

This OnlyOffice Debian package has no limits.

This package is known to work in Debian 11 systems and might also work on other Debian/Ubuntu systems.

If you need more technical articles that cover how we deal with releasing new debian package binaries you can check:

- [onlyoffice-no-limits-2024-05.md](onlyoffice-no-limits-2024-05.md) .

## System Base

- **Debian 11** Netinst was choosen (Any other Debian based distro which supports docker should also be fine).
- **Required RAM**: 16 GB RAM (Minimum) or 8 GB RAM with 8 GB SWAP.
- **Hard disk** (Recommended): 50 GB

## Phase 1 - Build DocumentServer Binaries

### System preparation

```
sudo -i
# Enter user password

sudo apt-get update
 sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io

systemctl status docker
# docker.io start/running, process 14394
```


### Fetch everything and build in one go

```
mkdir /root/build-onlyoffice-unlimited
cd /root/build-onlyoffice-unlimited
git clone https://github.com/btactic-oo/unlimited-onlyoffice-package-builder
cd unlimited-onlyoffice-package-builder

./onlyoffice-package-builder.sh \
  --product-version=8.0.1 \
  --build-number=31 \
  --unlimited-organization=btactic-oo \
  --tag-suffix=-btactic \
  --debian-package-suffix=-btactic
```

### Package is built

Package `onlyoffice-documentserver_8.0.1-31-btactic_amd64.deb` should be found at `/root/build-onlyoffice-unlimited/unlimited-onlyoffice-package-builder/deb_build/document-server-package/deb/` directory.

## Usage

Use documentation on how to install OnlyOffice package on Ubuntu such as [https://helpcenter.onlyoffice.com/installation/docs-community-install-ubuntu.aspx](https://helpcenter.onlyoffice.com/installation/docs-community-install-ubuntu.aspx).

However:

- Do not add OnlyOffice repo.
- When asked to install `onlyoffice-documentserver` package do instead:

```
sudo apt install /path/to/onlyoffice-documentserver_8.0.1-31-btactic_amd64.deb
```

## Developer notes

- Use tags to make sure to use your exact version
- This build not only depends on btactic organisation repos but on ONLYOFFICE ones. TODO: Create btactic-onlyoffice org and clone all the needed repos there.
- Even then the build depends on other software downloads so you could not perform it offline (accessing offline local repos).
- Hopefully they manage to remove the need of building everything instead of only server because building everything makes us to build qt which we don't need and it takes too long.
- Find new upstream packages at [https://download.onlyoffice.com/](https://download.onlyoffice.com/)

### Work on built container

If you have just built an container and you want to do Debian package manually (in order to avoid waiting for 9 hours for it to build again) you can do like this:

Once:
```
docker run -v $(pwd)/out:/build_tools/out onlyoffice-document-editors-builder
```
has finished we should have:

```
CONTAINER ID        IMAGE                                        COMMAND                CREATED             STATUS              PORTS               NAMES
035367486ecd        onlyoffice-document-editors-builder:latest   "/bin/sh -c 'cd tool   39 minutes ago      Exited (0) 3 minutes ago                           loving_pare
```

Now we can do a commit to freeze that status with:
```
docker commit 035367486ecd onlyoffice-just-built
```

and then we can enter that image without triggering the default build process:


```
cd /build_tools
docker run -it --entrypoint /bin/bash -v $(pwd)/out:/build_tools/out onlyoffice-just-built
```
.

### Special github repos, branches and tags

- 8.0.1-31-btactic : Use special btactic repos.
- v8.0.1-31-btactic : Tag for associated release.

- https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/releases/tag/v8.0.1.31-btactic

- https://github.com/btactic-oo/unlimited-onlyoffice-package-builder
- https://github.com/btactic-oo/document-server-package/commits/v8.0.1.31-btactic/
- https://github.com/btactic-oo/build_tools/commits/v8.0.1.31-btactic/
- https://github.com/btactic-oo/server/commits/v8.0.1.31-btactic/
- https://github.com/btactic-oo/web-apps/commits/v8.0.1.31-btactic/

## Warning

This is not an official onlyoffice build. Do not seek for help on OnlyOffice issues/forums unless you replicate it on original source code or original binaries from them.
