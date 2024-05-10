# OnlyOffice - 2024 June - No limits - Complete log

## Introduction
This is a complete log of how we managed to bring out the 'No limits' version of OnlyOffice for those of you that like technical articles.

- It's 2024 June and we need to build OnlyOffice 8.0.1.32.
- Actually 2024 May build had so many changes that I need to rewrite this so that I can reuse it in the future without too much hassle.

- Please remember: **This is not a Docker build that you can use in production. This is a Docker system that let's you build a Debian package binary.**

You are also advised to check: [README-BUILD-DEBIAN-PACKAGE-NO-LIMITS.md](README-BUILD-DEBIAN-PACKAGE-NO-LIMITS.md) which are more straight-forward build and **use** instructions.

## Initial tasks TODO

- Internal build system is already there. No need to build it again.
  - Debian 11 Netinst was choosen (Any other Debian based distro which supports docker should also be fine).
  - Required RAM: 16 GB RAM (Minimum) or 8 GB RAM with 8 GB SWAP.
  - Recommended: 50 GB Hard disk space

- As we did before we should be able to build stuff thanks to `document-server-package` repo without almost no changes.

- Consider editing Mobile Edit to be turned on if we have some left time and we don't mind adding yet another repo. **Probably not.**

- Create custom `document-server-package` tag so that the Debian package can be built.

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
The most recent 8.0.x version is:

8.0.1-32

so that's the version that we will be using.

### document-server-package repo update

Back in the day we could just work with the latest onlyoffice document-server-package master branch.
Unfortunately they have a bug so let's do our own.

Old stuff that we already had:
- commit (Fix deb build): 58116a876090ba1d0c7e9b3618fb35a46d64de80

Let's fetch recent information from official OnlyOffice repo.

```
cd onlyoffice_repos/document-server-package
git checkout master
git pull upstream-origin master
git fetch --all --tags
```

We create a new branch based on the recently fetched tag.

```
git checkout tags/v8.0.1.32 -b 8.0.1.32-btactic
```

.

Apply deb build fix:
```
git cherry-pick 58116a876090ba1d0c7e9b3618fb35a46d64de80
```
.

Let's push and create appropiate tags.
Yes, having a branch here for everyone of the releases is not needed at all.
We could just upload the tag.

```
git push origin 8.0.1.32-btactic
git tag -a 'v8.0.1.32-btactic' -m '8.0.1.32-btactic'
git push origin v8.0.1.32-btactic
```

### build_tools repo update

Old stuff that we already had:
- tag: v8.0.1.31-btactic

- commit (Dockerfile to use Ubuntu 20): 8cdeff96f9b0de8eeaaeddc020fc90dbe3046ad2
- commit (owner changes in ssh): 7ce465ecb177fd20ebf2b459a69f98312f7a8d3d
- commit (Custom repos and tags): 9c8c9a29149da384e5e3a93d4cf9057d8449b191

Let's fetch recent information from official OnlyOffice repo.

```
cd onlyoffice_repos/build_tools
git checkout master
git pull upstream-origin master
git fetch --all --tags
```

We create a new branch based on the recently fetched tag.

```
git checkout tags/v8.0.1.32 -b 8.0.1.32-btactic
```

.

Cherry-pick what we already had:

```
git cherry-pick 8cdeff96f9b0de8eeaaeddc020fc90dbe3046ad2
git cherry-pick 7ce465ecb177fd20ebf2b459a69f98312f7a8d3d
git cherry-pick 9c8c9a29149da384e5e3a93d4cf9057d8449b191
```
.

Let's push and create appropiate tags:

```
git push origin 8.0.1.32-btactic
git tag -a 'v8.0.1.32-btactic' -m '8.0.1.32-btactic'
git push origin v8.0.1.32-btactic
```

### server repo update

Old stuff that we already had:
- tag: v8.0.1.31-btactic
- commit (connection limit): cb6100664657bc91a8bae82d005f00dcc0092a9c

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
git checkout tags/v8.0.1.32 -b 8.0.1.32-btactic
```
.

Cherry-pick what we already had:

```
git cherry-pick cb6100664657bc91a8bae82d005f00dcc0092a9c
```

Let's push and create appropiate tags:

```
git push origin 8.0.1.32-btactic
git tag -a 'v8.0.1.32-btactic' -m '8.0.1.32-btactic'
git push origin v8.0.1.32-btactic
```

### web-apps repo update

Old stuff that we already had:
- tag: v8.0.1.31-btactic
- commit (mobile edit): 2d186b887bd1f445ec038bd9586ba7da3471ba05

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
git checkout tags/v8.0.1.32 -b 8.0.1.32-btactic
```
.

Cherry-pick what we already had:

```
git cherry-pick 2d186b887bd1f445ec038bd9586ba7da3471ba05
```

Let's push and create appropiate tags:

```
git push origin 8.0.1.32-btactic
git tag -a 'v8.0.1.32-btactic' -m '8.0.1.32-btactic'
git push origin v8.0.1.32-btactic
```

### Build from build virtual machine (Optional)

This virtual machine has Docker installed in it.
And its build user can run docker commands.

```
mkdir ~/build-oo
cd ~/build-oo
git clone https://github.com/btactic-oo/unlimited-onlyoffice-package-builder
cd unlimited-onlyoffice-package-builder
./onlyoffice-package-builder.sh --product-version=8.0.1 --build-number=32 --unlimited-organization=btactic-oo --tag-suffix=-btactic --debian-package-suffix=-btactic
```

### Final package (Optional)

The final `onlyoffice-documentserver_8.0.1-32-btactic_amd64.deb` deb package can be found at: `~/build-oo/unlimited-onlyoffice-package-builder/document-server-package/deb/` directory.

### Release (Based on Github Actions)

We should be able to build and publish a release in our `unlimited-onlyoffice-package-builder` repo thanks to:

```
cd onlyoffice_repos/unlimited-onlyoffice-package-builder
git checkout main
git push origin main # Just to be safe
git tag -a 'builds-debian-11/8.0.1.32' -m 'builds-debian-11/8.0.1.32'
git push origin 'builds-debian-11/8.0.1.32'
```
.

## Useful links

- [https://www.btactic.com/build-onlyoffice-from-source-code-2023/?lang=en](https://www.btactic.com/build-onlyoffice-from-source-code-2023/?lang=en)
- [https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/releases/tag/onlyoffice-unlimited-build-debian-11%2F8.0.1.32](https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/releases/tag/onlyoffice-unlimited-build-debian-11%2F8.0.1.32)
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

- Onlyoffice remote for document-server-package repo:
```
cd onlyoffice_repos/document-server-package
git remote add upstream-origin git@github.com:ONLYOFFICE/document-server-package.git
```

- Onlyoffice remote for web-apps repo:
```
cd onlyoffice_repos/web-apps
git remote add upstream-origin git@github.com:ONLYOFFICE/web-apps.git
```

- Use screen, byobu or tmux when building in your virtual machine so that build is not lost because of a network disconnection

## Warning

This is not an official onlyoffice build. Do not seek for help on OnlyOffice issues/forums unless you replicate it on original source code or original binaries from them.
