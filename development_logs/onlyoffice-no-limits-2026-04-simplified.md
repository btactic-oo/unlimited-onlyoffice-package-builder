# OnlyOffice - 2026 April - No limits - Simplified log

## Introduction
This is a simplified log of how we managed to bring out the 'No limits' version of OnlyOffice for those of you that like technical articles.

- It's 2026 April and we need to build OnlyOffice 9.3.1.11.

- Please remember: **This is not a Docker build that you can use in production. This is a Docker system that let's you build a Debian package binary.**

## Initial tasks TODO

- Internal build system is already there. No need to build it again.
  - Debian 11 Netinst was choosen (Any other Debian based distro which supports docker should also be fine).
  - Required RAM: 16 GB RAM (Minimum) or 8 GB RAM with 8 GB SWAP.
  - Recommended: 50 GB Hard disk space

- Update github documentation.

- Update Nextcloud forum post.

- Update www.btactic.com post or create a new one.

- Update Bibliography if needed.

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
The most recent 9.3.1 version is:

9.3.1-10

but after failing to build we will switch to:

9.3.1-11

.

### Build from build virtual machine (Optional)

This virtual machine has Docker installed in it.
And its build user can run docker commands.

```
mkdir ~/build-oo
cd ~/build-oo
git clone https://github.com/btactic-oo/unlimited-onlyoffice-package-builder
cd unlimited-onlyoffice-package-builder
git checkout v0.0.8
./onlyoffice-package-builder.sh --product-version=9.3.1 --build-number=11 --unlimited-organization=btactic-oo --tag-suffix=-btactic --debian-package-suffix=-btactic
```

### Final package (Optional)

The final `onlyoffice-documentserver_9.3.1-11-btactic_amd64.deb` deb package can be found at: `~/build-oo/unlimited-onlyoffice-package-builder/document-server-package/deb/` directory.

### Release (Based on Github Actions)

We should be able to build and publish a release in our `unlimited-onlyoffice-package-builder` repo thanks to:

```
cd onlyoffice_repos/unlimited-onlyoffice-package-builder
git checkout main
git push origin main # Just to be safe
git tag -a 'builds-debian-11/9.3.1.11' -m 'builds-debian-11/9.3.1.11'
git push origin 'builds-debian-11/9.3.1.11'
```
.

Release based on Github Actions **went ok** after 2h30m build time.

## Useful links

- [https://www.btactic.com/build-onlyoffice-from-source-code-2023/?lang=en](https://www.btactic.com/build-onlyoffice-from-source-code-2023/?lang=en)
- [https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/releases/tag/onlyoffice-unlimited-build-debian-11%2F9.3.1.50](https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/releases/tag/onlyoffice-unlimited-build-debian-11%2F9.3.1.50)
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
