# OnlyOffice - 2025 November - No limits - Complete log

## Based on doc

I will just try to follow [https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/blob/v0.0.5/README-BUILD-NEWER-VERSIONS.md] but I will skip some stuff that I have already done by my side.

## Which version to build

In my OO test machine:
```
sudo apt update
sudo apt-cache show onlyoffice-documentserver | less
```

Latest version there would be: **9.1.0-168**.

Apparently in the server repo there is an older *v9.1.0.165* and then it jumps to: *v9.1.0.173* version. Both versions point to the same commit. We will use the more recent one: **v9.1.0.173**.

## Manual cherry-pick check (1) - Pass 1

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
mkdir build-oo-2025-11-28
cd build-oo-2025-11-28
```

```
git clone https://github.com/btactic-oo/server
cd server
git remote add upstream-origin https://github.com/ONLYOFFICE/server

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.1.0.173 -b 9.1.0.173-btactic
git cherry-pick 81db34dee17f8a6a364669232a8c7c2f5d36d81f

cd ..
```

So... In the *cherry-pick* step I am getting:
```
Auto-fusionando Common/sources/constants.js
CONFLICTO (contenido): Conflicto de fusión en Common/sources/constants.js
error: no se pudo aplicar 81db34de... License connection updated from 20 to 99999
```
.

So this is something that needs to be dealt manually by checking what they have changed.

I think it was also reported in the feedback issue that we have open. Let's check it to see if someone else has fixed this bit. Well, that's not the case. Let's see what the commit actually did and what changes they have done to the constants.js file.

## Fixing the problem

I run those commands with a user that can push to our Github repo. I am not running this from the build VPS but from a development machine.

```
mkdir tmp-build-oo-2025-11-28-server-fix
cd tmp-build-oo-2025-11-28-server-fix
```

```
git clone git@github.com:btactic-oo/server.git
cd server

git remote add upstream-origin https://github.com/ONLYOFFICE/server

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.1.0.173 -b 9.1.0.173-btactic

## Edit ‎Common/sources/constants.js manually
git add ‎Common/sources/constants.js
git commit -m 'License connection updated from 20 to 99999'
git push origin 9.1.0.173-btactic

cd ..
```

`git show HEAD` shows that the new commit to be used is: `35fda010a253c42344c08857424aa50c48f7eb8a`.

Later on we will have to modify the `unlimited-onlyoffice-package-builder` repo with it.

## Manual cherry-pick check (1) - Pass 2

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

Please notice that I use `9.1.0.173-btactic2` branch because I have already pushed `9.1.0.173-btactic` branch so that needed commit is there. I also use the new commit I have just pushed.

```
mkdir build-oo-2025-11-28-v2
cd build-oo-2025-11-28-v2
```

```
git clone https://github.com/btactic-oo/server
cd server
git remote add upstream-origin https://github.com/ONLYOFFICE/server

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.1.0.173 -b 9.1.0.173-btactic2
git cherry-pick 35fda010a253c42344c08857424aa50c48f7eb8a

# Force our changes
git tag --delete v9.1.0.173
git tag -a 'v9.1.0.173' -m 'v9.1.0.173'

cd ..
```

## Manual cherry-pick check (2) - Pass 2

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
# At this point you should be in:
# build-oo-2025-11-28-v2
# directory
```

```
git clone https://github.com/btactic-oo/web-apps
cd web-apps
git remote add upstream-origin https://github.com/ONLYOFFICE/web-apps

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.1.0.173 -b 9.1.0.173-btactic
git cherry-pick 140ef6d1d687532dcb03b05912838b8b4cf161a3

# Force our changes
git tag --delete v9.1.0.173
git tag -a 'v9.1.0.173' -m 'v9.1.0.173'

cd ..
```

## Docker image build

```
# At this point you should be in:
# build-oo-2025-11-28-v2
# directory
```

```
git clone https://github.com/ONLYOFFICE/build_tools
cd build_tools
git checkout v9.1.0.173
docker build --tag onlyoffice-document-editors-builder .
cd ..
```

## Manual build from the Docker image

```
docker run -e PRODUCT_VERSION=9.1.0 -e BUILD_NUMBER=173 -e NODE_ENV='production' -v $(pwd)/build_tools/out:/build_tools/out -v $(pwd)/server:/server -v $(pwd)/web-apps:/web-apps -it --entrypoint /bin/bash onlyoffice-document-editors-builder

cd /build_tools
cd tools/linux && python3 ./automate.py --branch=tags/v9.1.0.173
```

ADDITIONAL CHECK COMMAND:
```
docker ps
docker exec -it 1d495cfb89a1 bash
```

## Check

If the build went ok we can decide to push the updated commit ( `35fda010a253c42344c08857424aa50c48f7eb8a` ) in the `unlimited-onlyoffice-package-builder` repo so that it's actually used when applying changes to server repo in the `onlyoffice-package-builder.sh` script.

## Update documentation

- Commit this complete file.
- Create the simplified version of this file based on v0.0.6.
- `README-BUILD-NEWER-VERSIONS.md` file should reference v0.0.6 version instead of older v0.0.5 version.
- v0.0.6 tag should be pushed.
- Associated issue asking for feedback should be updated.

## Publish build on Github Actions

Build the new version based on Github Actions so that it can be downloaded and tested.
