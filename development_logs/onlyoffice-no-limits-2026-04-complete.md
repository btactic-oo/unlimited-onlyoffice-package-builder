## Based on doc

I will just try to follow [https://github.com/btactic-oo/unlimited-onlyoffice-package-builder/blob/v0.0.6/README-BUILD-NEWER-VERSIONS.md] but I will skip some stuff that I have already done by my side.

## Which version to build

In my OO test machine:
```
sudo apt update
sudo apt-cache show onlyoffice-documentserver | less
```

Latest version there would be: **9.3.1-10**.

I can find it in the server repo as *v9.3.1.10* so let's go with it.

## Manual cherry-pick check (1) - Pass 1

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
mkdir build-oo-2026-04-07
cd build-oo-2026-04-07
```

```
git clone https://github.com/btactic-oo/server
cd server
git remote add upstream-origin https://github.com/ONLYOFFICE/server

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.3.1.10 -b 9.3.1.10-btactic
git cherry-pick 35fda010a253c42344c08857424aa50c48f7eb8a

cd ..
```

So... In the `git pull upstream-origin master` step I am getting:

```
remote: Enumerating objects: 2497, done.
remote: Counting objects: 100% (241/241), done.
remote: Compressing objects: 100% (60/60), done.
remote: Total 2497 (delta 186), reused 181 (delta 181), pack-reused 2256 (from 3)
Recibiendo objetos: 100% (2497/2497), 721.64 KiB | 7.22 MiB/s, listo.
Resolviendo deltas: 100% (378/378), completado con 69 objetos locales.
Desde https://github.com/ONLYOFFICE/server                                                                                             
 * branch              master     -> FETCH_HEAD                                                                                        
 * [nueva rama]        master     -> upstream-origin/master 

hint: You have divergent branches and need to specify how to reconcile them.
hint: You can do so by running one of the following commands sometime before
hint: your next pull:
hint: 
hint:   git config pull.rebase false  # merge
hint:   git config pull.rebase true   # rebase
hint:   git config pull.ff only       # fast-forward only
hint: 
hint: You can replace "git config" with "git config --global" to set a default
hint: preference for all repositories. You can also pass --rebase, --no-rebase,
hint: or --ff-only on the command line to override the configured default per
hint: invocation.
```

This is something unusual because it implies that they have rewritten Git history so I would need to probably branch out from an older commit so that my default master branch can be fast-forward to whatever they have in OnlyOffice themselves. I will also have to rename my current branch.

**Wait a moment.** Apparently I did not push my local changes to the btactic-oo server master branch repo back in the day. I wonder if that's the problem.

Let me just push them for now from a development machine with:

```
git push origin master
```
.

Now this makes more sense. Let's try again.

## Manual cherry-pick check (1) - Pass 2

( As root again. )

```
mkdir build-oo-2026-04-07-v2
cd build-oo-2026-04-07-v2
```

```
git clone https://github.com/btactic-oo/server
cd server
git remote add upstream-origin https://github.com/ONLYOFFICE/server

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.3.1.10 -b 9.3.1.10-btactic
git cherry-pick 35fda010a253c42344c08857424aa50c48f7eb8a

cd ..
```

So... In the `git pull upstream-origin master` step I am getting again:

```
remote: Enumerating objects: 2497, done.
remote: Counting objects: 100% (235/235), done.
remote: Compressing objects: 100% (60/60), done.
remote: Total 2497 (delta 180), reused 175 (delta 175), pack-reused 2262 (from 3)
Receiving objects: 100% (2497/2497), 722.33 KiB | 1.93 MiB/s, done.
Resolving deltas: 100% (372/372), completed with 63 local objects.
From https://github.com/ONLYOFFICE/server
 * branch              master     -> FETCH_HEAD
 * [new branch]        master     -> upstream-origin/master
hint: You have divergent branches and need to specify how to reconcile them.
hint: You can do so by running one of the following commands sometime before
hint: your next pull:
hint: 
hint:   git config pull.rebase false  # merge
hint:   git config pull.rebase true   # rebase
hint:   git config pull.ff only       # fast-forward only
hint: 
hint: You can replace "git config" with "git config --global" to set a default
hint: preference for all repositories. You can also pass --rebase, --no-rebase,
hint: or --ff-only on the command line to override the configured default per
hint: invocation.
fatal: Need to specify how to reconcile divergent branches.
```

I am going to branch out from an older commit so that my default master branch can be fast-forward to whatever they have in OnlyOffice themselves. I will also have to rename my current branch. That way I guess this will be fixed.

## Branching out from older commit

And **also renaming my current master branch**.

I run those commands with a user that can push to our Github repo. I am not running this from the build VPS but from a development machine.

```
git checkout master -b pre_2026_04_master
git branch -D master
git fetch upstream-origin master
git checkout -b master upstream-origin/master
git push origin pre_2026_04_master
git push --force origin master
```

## Manual cherry-pick check (1) - Pass 3

( As root again. )

```
mkdir build-oo-2026-04-07-v3
cd build-oo-2026-04-07-v3
```

```
git clone https://github.com/btactic-oo/server
cd server
git remote add upstream-origin https://github.com/ONLYOFFICE/server

git checkout master
git pull upstream-origin master
git fetch --all --tags
git fetch --all --tags --force # To avoid '(would clobber existing tag)'
git checkout tags/v9.3.1.10 -b 9.3.1.10-btactic
git cherry-pick 35fda010a253c42344c08857424aa50c48f7eb8a

# Force our changes
git tag --delete v9.3.1.10
git tag -a 'v9.3.1.10' -m 'v9.3.1.10'

cd ..
```

Some of the clobber tags (for the record):
```
 ! [rejected]          v99.99.99.2471    -> v99.99.99.2471  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2472    -> v99.99.99.2472  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2473    -> v99.99.99.2473  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2474    -> v99.99.99.2474  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2478    -> v99.99.99.2478  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2479    -> v99.99.99.2479  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2480    -> v99.99.99.2480  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2481    -> v99.99.99.2481  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2482    -> v99.99.99.2482  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2483    -> v99.99.99.2483  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2484    -> v99.99.99.2484  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2486    -> v99.99.99.2486  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2487    -> v99.99.99.2487  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2488    -> v99.99.99.2488  (would clobber existing tag)                                               
 ! [rejected]          v99.99.99.2489    -> v99.99.99.2489  (would clobber existing tag)
```

Example of why this happens.

---

OnlyOffice has suddenly pushed-forced old tags for the sake of it. So, we now have:

- `https://github.com/ONLYOFFICE/server/releases/tag/v99.99.99.2471`
    - Author: konovalovsergey
    - Date: Tagged this Jun 7, 2021
    - Description: v99.99.99.2471: Merge pull request #275 from ONLYOFFICE/release/v6.4.0
    - Associated commit: **8915d819221782c4223a5885051ea007e5cbadbc**

- `https://github.com/btactic-oo/server/releases/tag/v99.99.99.2471`
    - Author: konovalovsergey
    - Date: Tagged this Jun 7, 2021
    - Description: v99.99.99.2471: Merge pull request #275 from ONLYOFFICE/release/v6.4.0
    - Associated commit: **b746ad8221088f47fdbbeca76dd6c76d1cc60e43**

Similar thing happened to: v6.4.0.33 and many more tags. In both onlyoffice and btactic 'server' repos there are 1749 commits. We are not sure any more if they represent the same changes.

After some more digging: common commit in history is:

- https://github.com/btactic-oo/server/commit/51b574e83c62a89fff9e7df9dd3046b225a2d9c3
- https://github.com/ONLYOFFICE/server/commit/51b574e83c62a89fff9e7df9dd3046b225a2d9c3

Then it diverges:

- https://github.com/btactic-oo/server/commit/47393e9b5c4090e5952727e1e90f02d0d41d397c
- https://github.com/ONLYOFFICE/server/commit/5389d026b966eb3d92058c988f55e95fc4117ff9

The btactic (original one) is verified. Clicking on Verified we can see:

```
This commit was signed with the committer's verified signature.
ShockwaveNN
GPG Key ID: 8DAD236C00523ECF
Verified on Nov 13, 2024, 12:27 AM
```

The other one, despite being exactly the same set of changes and changes is not verified.

So... it's like some obscure repo (inside of Ascensio dev machines) which did not have commits with their verified signatures has been pushed-forced and that's there's a divergence.

Github UI comparison (before I might move `btactic-oo/server` to another organization):

https://github.com/btactic-oo/server/commits/v6.1.0.1/?after=c274cb2739dfc439811fe48a33a3554888aa046f+565
https://github.com/ONLYOFFICE/server/commits/v6.1.0.1/?after=9d8bdfaa645517c5df6abcf0b45c06ad30870a62+565

---

## Manual cherry-pick check (2) - Pass 1

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
# At this point you should be in:
# build-oo-2026-04-07-v3
# directory
```

```
git clone https://github.com/btactic-oo/web-apps
cd web-apps
git remote add upstream-origin https://github.com/ONLYOFFICE/web-apps

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.3.1.10 -b 9.3.1.10-btactic
git cherry-pick 140ef6d1d687532dcb03b05912838b8b4cf161a3

# Force our changes
git tag --delete v9.3.1.10
git tag -a 'v9.3.1.10' -m 'v9.3.1.10'

cd ..
```

## Docker image build

```
# At this point you should be in:
# build-oo-2026-04-07-v3
# directory
```

```
git clone https://github.com/ONLYOFFICE/build_tools
cd build_tools
git checkout v9.3.1.10
docker build --tag onlyoffice-document-editors-builder .
cd ..
```

## Manual build from the Docker image

```
docker run -e PRODUCT_VERSION=9.3.1 -e BUILD_NUMBER=10 -e NODE_ENV='production' -v $(pwd)/build_tools/out:/build_tools/out -v $(pwd)/server:/server -v $(pwd)/web-apps:/web-apps -it --entrypoint /bin/bash onlyoffice-document-editors-builder

cd /build_tools
cd tools/linux && python3 ./automate.py --branch=tags/v9.3.1.10
```

Well, in any case, this fails with:

```
delete warning [file not exist]: ./v8.data
Cloning into 'depot_tools'...
fatal: unable to access 'https://chromium.googlesource.com/chromium/tools/depot_tools.git/': Could not resolve host: chromium.googlesource.com
Error (git): 128
Error (./make.py): 1
```

This might be a temporary error on resolving the host because this host is actually resolvable.

Or maybe, more likely, some 'Not enough space' which has failed here.

Let's start from scratch forking again the server repo and so on.

## Repo swap

I move this repo a new 'btactic-oo-old-verified' organization.
I also fork again server repo from OnlyOffice organization onto btactic-oo.

Then I need to recreate my local repo which was linked to the 'old-verified' btactic-oo organization.

I won't be documenting this.

## Create server commit from scratch

We use an old tag so that we can later on validate that the cherry-pick works as expected.

```
git checkout tags/v9.1.0.173 -b 9.1.0.173-btactic
# Make changes
sed -i 's/exports.LICENSE_CONNECTIONS = 20;/exports.LICENSE_CONNECTIONS = 99999;/g' Common/sources/constants.js
sed -i 's/exports.LICENSE_USERS = 3;/exports.LICENSE_USERS = 99999;/g' Common/sources/constants.js
git add Common/sources/constants.js
git commit -m 'License connection updated from 20 to 99999'
git push origin 9.1.0.173-btactic
```

Let's write down the created commit so that we can use it later: `c9de34cefddb32bf08c39dd1b7372ae7b2f082d7`.

Now, let's to work on our build from scratch in order to validate it.

## Manual cherry-pick check (1) - Pass 4

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
mkdir build-oo-2026-04-07-v4
cd build-oo-2026-04-07-v4
```

```
git clone https://github.com/btactic-oo/server
cd server
git remote add upstream-origin https://github.com/ONLYOFFICE/server

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.3.1.10 -b 9.3.1.10-btactic
git cherry-pick c9de34cefddb32bf08c39dd1b7372ae7b2f082d7

# Force our changes
git tag --delete v9.3.1.10
git tag -a 'v9.3.1.10' -m 'v9.3.1.10'

cd ..
```

## Manual cherry-pick check (2) - Pass 4

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
# At this point you should be in:
# build-oo-2026-04-07-v4
# directory
```

```
git clone https://github.com/btactic-oo/web-apps
cd web-apps
git remote add upstream-origin https://github.com/ONLYOFFICE/web-apps

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.3.1.10 -b 9.3.1.10-btactic
git cherry-pick 140ef6d1d687532dcb03b05912838b8b4cf161a3

# Force our changes
git tag --delete v9.3.1.10
git tag -a 'v9.3.1.10' -m 'v9.3.1.10'

cd ..
```

## Docker image build

```
# At this point you should be in:
# build-oo-2026-04-07-v4
# directory
```

```
git clone https://github.com/ONLYOFFICE/build_tools
cd build_tools
git checkout v9.3.1.10
docker build --tag onlyoffice-document-editors-builder .
cd ..
```

## Manual build from the Docker image

```
docker run -e PRODUCT_VERSION=9.3.1 -e BUILD_NUMBER=10 -e NODE_ENV='production' -v $(pwd)/build_tools/out:/build_tools/out -v $(pwd)/server:/server -v $(pwd)/web-apps:/web-apps -it --entrypoint /bin/bash onlyoffice-document-editors-builder

cd /build_tools
cd tools/linux && python3 ./automate.py --branch=tags/v9.3.1.10
```

Well, this seems to fail anyways...

```
[0:02:56] Still working on:                                                                                                            
[0:02:56]   v8                                                                                                                         
3>WARNING: subprocess '"git" "-c" "core.deltaBaseCacheLimit=2g" "clone" "--no-checkout" "--progress" "https://chromium.googlesource.com
/chromium/src/buildtools.git" "/core/Common/3dParty/v8_89/v8/_gclient_buildtools_d1ug8b52"' in /core/Common/3dParty/v8_89 failed; will 
retry after a short nap...
(...)

(...)

  File "/core/Common/3dParty/v8_89/depot_tools/gclient_scm.py", line 859, in update                                                    
    self._DeleteOrMove(options.force)                                                                                                  
  File "/core/Common/3dParty/v8_89/depot_tools/gclient_scm.py", line 224, in _DeleteOrMove                                             
    shutil.move(checkout_path, dest_path)                                                                                              
  File "/root/.cache/vpython-root.0/store/cpython+l5fnajrvijf7cvdkjqmbicg3i8/contents/lib/python3.11/shutil.py", line 873, in move     
    copy_function(src, real_dst)                                                                                                         File "/root/.cache/vpython-root.0/store/cpython+l5fnajrvijf7cvdkjqmbicg3i8/contents/lib/python3.11/shutil.py", line 448, in copy2        copyfile(src, dst, follow_symlinks=follow_symlinks)                                                                                
  File "/root/.cache/vpython-root.0/store/cpython+l5fnajrvijf7cvdkjqmbicg3i8/contents/lib/python3.11/shutil.py", line 256, in copyfile     with open(src, 'rb') as fsrc:                                                                                                      
         ^^^^^^^^^^^^^^^                                                                                                               FileNotFoundError: [Errno 2] No such file or directory: '/core/Common/3dParty/v8_89/v8/buildtools'                                     
                                                                                                                                       Subprocess failed with return code 1.                                                                                                  
./cipd: line 146: ./depot_tools/cipd_client_version.digests: No such file or directory                                                 
Platform linux-amd64 is not supported by the CIPD client bootstrap: there's no pinned SHA256 hash for it in the *.digests file.
```

It's like *chromium.googlesource.com* web server doesn't like how often we connect there. I wonder if this is corrected on a newer tag or if I should just yolo and test this in Github to see if it actually builds as-is.

Let's try one more time (4 hours later) and let's see what happens. If it still fails I'll yolo this new change in Github.

4 hours later I am getting:
```
Info: creating stash file /desktop-apps/win-linux/.qmake.stash
Project MESSAGE: linux-64
Project MESSAGE: linux_64/release
Project MESSAGE: core_static_link_libstd
Project MESSAGE: QTVER_DOWNGRADE
Project MESSAGE: webapps help url: \"https://download.onlyoffice.com/install/desktop/editors/help/v9.3.1/apps\"
Project MESSAGE: linux_64
Project ERROR: libnotify development package not found
Error (/build_tools/tools/linux/qt_build/Qt-5.9.9/gcc_64/bin/qmake): 3
Error (./make.py): 1
```
.

Let's install `libnotify-dev` package manually and then:
```
python3 ./automate.py --branch=tags/v9.3.1.10
```
to hope it fixes it.

Let's take a look at Dockerfile file git log to see if this is fixed in a latest version.
Well, just one day later than the v9.3.1.10 release Dockerfile is changed onto Ubuntu 24.04.
That's suspicious.

And that matches v9.3.1.11. Ok, so let's switch to that version for now.

## Manual cherry-pick check (1) - Pass 5

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
mkdir build-oo-2026-04-07-v5
cd build-oo-2026-04-07-v5
```

```
git clone https://github.com/btactic-oo/server
cd server
git remote add upstream-origin https://github.com/ONLYOFFICE/server

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.3.1.11 -b 9.3.1.11-btactic
git cherry-pick c9de34cefddb32bf08c39dd1b7372ae7b2f082d7

# Force our changes
git tag --delete v9.3.1.11
git tag -a 'v9.3.1.11' -m 'v9.3.1.11'

cd ..
```

## Manual cherry-pick check (2) - Pass 5

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
# At this point you should be in:
# build-oo-2026-04-07-v5
# directory
```

```
git clone https://github.com/btactic-oo/web-apps
cd web-apps
git remote add upstream-origin https://github.com/ONLYOFFICE/web-apps

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.3.1.11 -b 9.3.1.11-btactic
git cherry-pick 140ef6d1d687532dcb03b05912838b8b4cf161a3

# Force our changes
git tag --delete v9.3.1.11
git tag -a 'v9.3.1.11' -m 'v9.3.1.11'

cd ..
```

## Docker image build

```
# At this point you should be in:
# build-oo-2026-04-07-v5
# directory
```

```
git clone https://github.com/ONLYOFFICE/build_tools
cd build_tools
git checkout v9.3.1.11
docker build --tag onlyoffice-document-editors-builder .
cd ..
```

## Manual build from the Docker image

```
docker run -e PRODUCT_VERSION=9.3.1 -e BUILD_NUMBER=11 -e NODE_ENV='production' -v $(pwd)/build_tools/out:/build_tools/out -v $(pwd)/server:/server -v $(pwd)/web-apps:/web-apps -it --entrypoint /bin/bash onlyoffice-document-editors-builder

cd /build_tools
cd tools/linux && python3 ./automate.py --branch=tags/v9.3.1.11
```

Well, this fails from the start with:
```
/build_tools/tools/linux/../../scripts/base.py:1155: SyntaxWarning: invalid escape sequence '\.'
  return re.sub("[^a-zA-Z0-9\.\-]", "-", bundle_identifier)
/build_tools/tools/linux/../../scripts/base.py:1653: SyntaxWarning: invalid escape sequence '\d'
  sdks = [re.findall('^MacOSX(1\d\.\d+)\.sdk$', s) for s in os.listdir(sdk_dir)]
/build_tools/tools/linux/../../scripts/base.py:1854: SyntaxWarning: invalid escape sequence '\$'
  new_path = new_path.replace("$ORIGIN", "\$ORIGIN")
install dependencies...
---------------------------------------------
build branch: tags/v9.3.1.11
---------------------------------------------
---------------------------------------------
build modules: desktop builder server
---------------------------------------------
/usr/bin/env: ‘python’: No such file or directory
Error (./configure.py): 127
```
.

So... we need to find out a more recent version or else fix the v9.3.1.10 version with a custom build_tools version which I thought we were never going to need any more.

Let me read the issues to see if someone has been able to build this.

Nothing useful found. Let's just use the latest tag: `v9.4.0.36` which it's from two weeks ago and let's see what happens.

## Manual cherry-pick check (1) - Pass 6

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
mkdir build-oo-2026-04-07-v6
cd build-oo-2026-04-07-v6
```

```
git clone https://github.com/btactic-oo/server
cd server
git remote add upstream-origin https://github.com/ONLYOFFICE/server

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.4.0.36 -b 9.4.0.36-btactic
git cherry-pick c9de34cefddb32bf08c39dd1b7372ae7b2f082d7

# Force our changes
git tag --delete v9.4.0.36
git tag -a 'v9.4.0.36' -m 'v9.4.0.36'

cd ..
```

## Manual cherry-pick check (2) - Pass 6

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
# At this point you should be in:
# build-oo-2026-04-07-v6
# directory
```

```
git clone https://github.com/btactic-oo/web-apps
cd web-apps
git remote add upstream-origin https://github.com/ONLYOFFICE/web-apps

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.4.0.36 -b 9.4.0.36-btactic
git cherry-pick 140ef6d1d687532dcb03b05912838b8b4cf161a3

# Force our changes
git tag --delete v9.4.0.36
git tag -a 'v9.4.0.36' -m 'v9.4.0.36'

cd ..
```

## Docker image build

```
# At this point you should be in:
# build-oo-2026-04-07-v6
# directory
```

```
git clone https://github.com/ONLYOFFICE/build_tools
cd build_tools
git checkout v9.4.0.36
docker build --tag onlyoffice-document-editors-builder .
cd ..
```

## Manual build from the Docker image

```
docker run -e PRODUCT_VERSION=9.4.0 -e BUILD_NUMBER=36 -e NODE_ENV='production' -v $(pwd)/build_tools/out:/build_tools/out -v $(pwd)/server:/server -v $(pwd)/web-apps:/web-apps -it --entrypoint /bin/bash onlyoffice-document-editors-builder

cd /build_tools
cd tools/linux && python3 ./automate.py --branch=tags/v9.4.0.36
```

This still fails from the start:
```
/build_tools/tools/linux/../../scripts/base.py:1155: SyntaxWarning: invalid escape sequence '\.'
  return re.sub("[^a-zA-Z0-9\.\-]", "-", bundle_identifier)
/build_tools/tools/linux/../../scripts/base.py:1653: SyntaxWarning: invalid escape sequence '\d'
  sdks = [re.findall('^MacOSX(1\d\.\d+)\.sdk$', s) for s in os.listdir(sdk_dir)]
/build_tools/tools/linux/../../scripts/base.py:1854: SyntaxWarning: invalid escape sequence '\$'
  new_path = new_path.replace("$ORIGIN", "\$ORIGIN")
install dependencies...
---------------------------------------------
build branch: tags/v9.4.0.36
---------------------------------------------
---------------------------------------------
build modules: desktop builder server
---------------------------------------------
/usr/bin/env: ‘python’: No such file or directory
Error (./configure.py): 127
```
.

**Wait a moment!**

I was just going to fill a bug against OnlyOffice so that they fix this.

However... after double-checking what their Dockerfile changes are about I see that the default command has been changed. They are no longer relying on automate.py. Now the command is much more complex.

So that's what we should be using instead.

```
BRANCH="tags/v9.4.0.36" ./tools/linux/python3/bin/python3 ./configure.py --sysroot "1" --clean "0" --update-light "1" --branch "${BRANCH}" --update "1" --module "desktop server builder" --qt-dir "$(pwd)/tools/linux/qt_build/Qt-5.9.9" && ./tools/linux/python3/bin/python3 ./make.py
```

Also when calling the Docker build we should be make sure to set something like `-e BRANCH=tags/v9.4.0.36`.

Now, that this is much more clear let's try to build v9.3.1.11.

## Manual cherry-pick check (1) - Pass 7

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
mkdir build-oo-2026-04-07-v7
cd build-oo-2026-04-07-v7
```

```
git clone https://github.com/btactic-oo/server
cd server
git remote add upstream-origin https://github.com/ONLYOFFICE/server

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.3.1.11 -b 9.3.1.11-btactic
git cherry-pick c9de34cefddb32bf08c39dd1b7372ae7b2f082d7

# Force our changes
git tag --delete v9.3.1.11
git tag -a 'v9.3.1.11' -m 'v9.3.1.11'

cd ..
```

## Manual cherry-pick check (2) - Pass 7

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
# At this point you should be in:
# build-oo-2026-04-07-v7
# directory
```

```
git clone https://github.com/btactic-oo/web-apps
cd web-apps
git remote add upstream-origin https://github.com/ONLYOFFICE/web-apps

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.3.1.11 -b 9.3.1.11-btactic
git cherry-pick 140ef6d1d687532dcb03b05912838b8b4cf161a3

# Force our changes
git tag --delete v9.3.1.11
git tag -a 'v9.3.1.11' -m 'v9.3.1.11'

cd ..
```

## Docker image build

```
# At this point you should be in:
# build-oo-2026-04-07-v7
# directory
```

```
git clone https://github.com/ONLYOFFICE/build_tools
cd build_tools
git checkout v9.3.1.11
docker build --tag onlyoffice-document-editors-builder .
cd ..
```

## Manual build from the Docker image

```
docker run -e BRANCH=tags/v9.3.1.11 -e PRODUCT_VERSION=9.3.1 -e BUILD_NUMBER=11 -e NODE_ENV='production' -v $(pwd)/build_tools/out:/build_tools/out -v $(pwd)/server:/server -v $(pwd)/web-apps:/web-apps -it --entrypoint /bin/bash onlyoffice-document-editors-builder

cd /build_tools

BRANCH="tags/v9.3.1.11" ./tools/linux/python3/bin/python3 ./configure.py --sysroot "1" --clean "0" --update-light "1" --branch "${BRANCH}" --update "1" --module "desktop server builder" --qt-dir "$(pwd)/tools/linux/qt_build/Qt-5.9.9" && ./tools/linux/python3/bin/python3 ./make.py
```

They still have these SyntaxWarning messages:
```
/build_tools/tools/linux/sysroot/../../../scripts/base.py:1155: SyntaxWarning: invalid escape sequence '\.'
  return re.sub("[^a-zA-Z0-9\.\-]", "-", bundle_identifier)                                                                            
/build_tools/tools/linux/sysroot/../../../scripts/base.py:1653: SyntaxWarning: invalid escape sequence '\d'
  sdks = [re.findall('^MacOSX(1\d\.\d+)\.sdk$', s) for s in os.listdir(sdk_dir)] 
/build_tools/tools/linux/sysroot/../../../scripts/base.py:1854: SyntaxWarning: invalid escape sequence '\$'
  new_path = new_path.replace("$ORIGIN", "\$ORIGIN")
```
.

Also, look at that, Ubuntu 16.04 it's still there somehow:
```
Patching linker scripts in ubuntu16-amd64-sysroot/usr/lib/x86_64-linux-gnu...
```
.

In any case, let's this build cook itself.

( At this point I had to start again because there was no space left on the device. Let's ignore it in this documentation. )

This ends up in:
```
delete warning [file not exist]: /build_tools/scripts/../out/linux_64/onlyoffice/desktopeditors/editors/sdkjs/slide/sdk-all.cache
copy warning [file not exist]: /build_tools/scripts/../../core/build/lib/linux_64/libdocbuilder.jni.so
patchelf: getting info about 'libdocbuilder.jni.so': No such file or directory
copy warning [file not exist]: /build_tools/scripts/../../server/Metrics/node_modules/modern-syslog/build/Release/core.node
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11231  100 11231    0     0   158k      0 --:--:-- --:--:-- --:--:--  171k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 22832  100 22832    0     0   314k      0 --:--:-- --:--:-- --:--:--  353k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 16875  100 16875    0     0  97387      0 --:--:-- --:--:-- --:--:--   99k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11231  100 11231    0     0   144k      0 --:--:-- --:--:-- --:--:--  156k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 22832  100 22832    0     0   146k      0 --:--:-- --:--:-- --:--:--  154k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 16875  100 16875    0     0   339k      0 --:--:-- --:--:-- --:--:--  383k
delete warning [file not exist]: /build_tools/scripts/../out/linux_64/onlyoffice/documentserver-snap/var/www/onlyoffice/documentserver/example/nodejs/example
```
. After checking out directory it seems to me that this is being built ok.

## Manual cherry-pick check (1) - Pass 8

This new build test is by only building 'server' component.

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
mkdir build-oo-2026-04-07-v8
cd build-oo-2026-04-07-v8
```

```
git clone https://github.com/btactic-oo/server
cd server
git remote add upstream-origin https://github.com/ONLYOFFICE/server

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.3.1.11 -b 9.3.1.11-btactic
git cherry-pick c9de34cefddb32bf08c39dd1b7372ae7b2f082d7

# Force our changes
git tag --delete v9.3.1.11
git tag -a 'v9.3.1.11' -m 'v9.3.1.11'

cd ..
```

## Manual cherry-pick check (2) - Pass 8

I am just running this step manually to avoid finding problems later on.

I run all of these commands as root in my build VPS.

```
# At this point you should be in:
# build-oo-2026-04-07-v8
# directory
```

```
git clone https://github.com/btactic-oo/web-apps
cd web-apps
git remote add upstream-origin https://github.com/ONLYOFFICE/web-apps

git checkout master
git pull upstream-origin master
git fetch --all --tags
git checkout tags/v9.3.1.11 -b 9.3.1.11-btactic
git cherry-pick 140ef6d1d687532dcb03b05912838b8b4cf161a3

# Force our changes
git tag --delete v9.3.1.11
git tag -a 'v9.3.1.11' -m 'v9.3.1.11'

cd ..
```

## Docker image build

```
# At this point you should be in:
# build-oo-2026-04-07-v8
# directory
```

```
git clone https://github.com/ONLYOFFICE/build_tools
cd build_tools
git checkout v9.3.1.11
docker build --tag onlyoffice-document-editors-builder .
cd ..
```

## Manual build from the Docker image

```
docker run -e BRANCH=tags/v9.3.1.11 -e PRODUCT_VERSION=9.3.1 -e BUILD_NUMBER=11 -e NODE_ENV='production' -v $(pwd)/build_tools/out:/build_tools/out -v $(pwd)/server:/server -v $(pwd)/web-apps:/web-apps -it --entrypoint /bin/bash onlyoffice-document-editors-builder

cd /build_tools

BRANCH="tags/v9.3.1.11" ./tools/linux/python3/bin/python3 ./configure.py --sysroot "1" --clean "0" --update-light "1" --branch "${BRANCH}" --update "1" --module "server" --qt-dir "$(pwd)/tools/linux/qt_build/Qt-5.9.9" && ./tools/linux/python3/bin/python3 ./make.py
```

After checking out directory it seems to me that this is being built ok.

# Unlimited build script rewrite

- We need to push the updated commit ( `NEW-SERVER-COMMIT-ID` ) for server in the `unlimited-onlyoffice-package-builder` repo.
- Then we need to modify what command it uses for building the binaries.

That's what v0.0.7 is going to be.

## Update documentation

- Commit this complete file.
- Create the simplified version of this file based on v0.0.7.
- `README-BUILD-NEWER-VERSIONS.md` file should reference v0.0.7 version instead of older v0.0.6 version.
- v0.0.7 tag should be pushed.
- Associated issue asking for feedback should be updated.

## Packaging issues on Debian 11

Apparently building in Debian 11 (or Debian 12) is not possible because I am getting an `dpkg-deb: error: unknown option --threads-max=4` error.

So,... we should switch to Debian 13.

So, let's fix that and release v0.0.8 and hope for the best.

## Publish build on Github Actions

Build the new version based on Github Actions so that it can be downloaded and tested.

## Github Actions errors

If there are Github Actions errors we should fix them.

# ANNEX - ADDITIONAL CHECK COMMAND:
```
docker ps
docker exec -it 1d495cfb89a1 bash
```
