# OnlyOffice - 2024 May - No limits - Complete log

## Introduction
This is a complete log of how we managed to bring out the 'No limits' version of OnlyOffice for those of you that like technical articles.

- It's 2024 May and we need to build OnlyOffice 8.0.x.
- Unlike previous attempts to rebuild OnlyOffice now we are moving every repo to a new organization so that everything it's in a single github organization.
- Unlike previous attempts to rebuild OnlyOffice we are moving its build a to a Docker based build. **This is not a Docker build that you can use in production. This is a Docker system that let's you build a Debian package binary.**
- Finally we might finally use that new Docker system to build new deb images thanks to Github actions.

You are also advised to check: [README-BUILD-DEBIAN-PACKAGE-NO-LIMITS.md](README-BUILD-DEBIAN-PACKAGE-NO-LIMITS.md) which are more straight-forward build and **use** instructions.

## New organization btactic-oo

Repos:

- server
- document-server-package
- build_tools

have been moved from btactic organization to btactic-oo organization.

## Docker based build

We need a new system, probably in a new repo, to be able to build the Debian binary from within a Docker system.

`unlimited-onlyoffice-package-builder` might be its name.

Let's do a quick search to see if anyone has done something similar.

Well, I have seen some results but nothing useful.

Wait a moment... the first step of this build process (building the DocumentServer binaries) it's already done in Docker.
We would just need to do the second step in Docker itself.

## unlimited-onlyoffice-package-builder work

Let's work on `onlyoffice-package-builder.sh` .

Let's try to have a nice understanding of what to do.

- Building OO binaries. Inside of the docker. It's already provided to us.
- Building OO binaries. Outside of the docker. This should be in onlyoffice-package-builder.sh file.
- Building deb file. Inside of the docker. We have written it on the onlyoffice-package-builder.sh file. We should probably separate it in a different file.
- Building deb file. Outside of the docker. This should be in onlyoffice-package-builder.sh file.

So... we are unable to build OO binaries because we are trying a very old version of the tags.

We will update those tags to something new that we can rely on and build from there.

Ok, let's try to build the OO binaries once again and see what happens.

So we build as documented but we will comment the lines regarding the creation of the deb file so that we can conclude that this very first step works as expected.

Well, the build has failed as the last time.

```
[0:02:33] Still working on:                                                                                                                      
[0:02:33]   v8                                                                                                                                   
________ running 'python3 third_party/depot_tools/update_depot_tools_toggle.py --disable' in '/core/Common/3dParty/v8_89/v8'                     
________ running 'python3 build/landmines.py --landmine-scripts tools/get_landmines.py' in '/core/Common/3dParty/v8_89/v8'                       
________ running 'python3 third_party/depot_tools/download_from_google_storage.py --no_resume --no_auth --bucket chromium-clang-format -s buildto
ols/linux64/clang-format.sha1' in '/core/Common/3dParty/v8_89/v8'                                                                                
  File "third_party/depot_tools/download_from_google_storage.py", line 51                                                                        
    return f'.{gcs_file_name}{MIGRATION_TOGGLE_FILE_SUFFIX}'                                                                                     
                                                           ^                                                                                     
SyntaxError: invalid syntax
```
```
Error: Command 'python3 third_party/depot_tools/download_from_google_storage.py --no_resume --no_auth --bucket chromium-clang-format -s buildtool
s/linux64/clang-format.sha1' returned non-zero exit status 1 in /core/Common/3dParty/v8_89/v8                                                    
  File "third_party/depot_tools/download_from_google_storage.py", line 51                                                                        
    return f'.{gcs_file_name}{MIGRATION_TOGGLE_FILE_SUFFIX}'                                                                                     
                                                           ^                                                                                     
SyntaxError: invalid syntax
```

```
Running: gclient root                                                                                                                            
Running: gclient config --spec 'solutions = [                                                                                                    
  {                                                                                                                                              
    "name": "v8",                                                                                                                                
    "url": "https://chromium.googlesource.com/v8/v8.git",                                                                                        
    "deps_file": "DEPS",                                                                                                                         
    "managed": False,                                                                                                                            
    "custom_deps": {},                                                                                                                           
  },                                                                                                                                             
]                                                                                                                                                
'                                                                                                                                                
Running: gclient sync --with_branch_heads                                                                                                        
Subprocess failed with return code 2.                                                                                                            
./cipd: line 137: ./depot_tools/cipd_client_version.digests: No such file or directory                                                           
Platform linux-amd64 is not supported by the CIPD client bootstrap: there's no pinned SHA256 hash for it in the *.digests file.
error: unknown option `type'
usage: git config [<options>]
```

```
ninja: Entering directory `out.gn/linux_64'                                                                                            [82/93487]
[1/2933] CXX obj/cppgc_base/allocation.o                                                                                                         
FAILED: obj/cppgc_base/allocation.o                                                                                                              
../../third_party/llvm-build/Release+Asserts/bin/clang++ -MMD -MF obj/cppgc_base/allocation.o.d -DUSE_UDEV -DUSE_AURA=1 -DUSE_GLIB=1 -DUSE_NSS_CE
RTS=1 -DUSE_OZONE=1 -DUSE_X11=1 -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_GNU_SOURCE -DCR_CLANG_REVISION=\"llvmorg-12-i
nit-16296-g5e476061-1\" -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D_FORTIFY_SOURCE=2 -DNDEBUG -DNVALGRIND -DDYNAMIC_ANNOTATIONS_ENABLED=0 
-DV8_TYPED_ARRAY_MAX_SIZE_IN_HEAP=64 -DENABLE_GDB_JIT_INTERFACE -DENABLE_MINOR_MC -DV8_INTL_SUPPORT -DV8_ATOMIC_OBJECT_FIELD_WRITES -DV8_ATOMIC_M
ARKING_STATE -DV8_ENABLE_LAZY_SOURCE_POSITIONS -DV8_WIN64_UNWINDING_INFO -DV8_ENABLE_REGEXP_INTERPRETER_THREADED_DISPATCH -DV8_SNAPSHOT_COMPRESSI
ON -DV8_COMPRESS_POINTERS -DV8_31BIT_SMIS_ON_64BIT_ARCH -DV8_DEPRECATION_WARNINGS -DV8_IMMINENT_DEPRECATION_WARNINGS -DV8_NO_ARGUMENTS_ADAPTOR -D
CPPGC_CAGED_HEAP -DV8_TARGET_ARCH_X64 -DV8_HAVE_TARGET_OS -DV8_TARGET_OS_LINUX -DDISABLE_UNTRUSTED_CODE_MITIGATIONS -DV8_COMPRESS_POINTERS -DV8_3
1BIT_SMIS_ON_64BIT_ARCH -DV8_DEPRECATION_WARNINGS -DV8_IMMINENT_DEPRECATION_WARNINGS -DV8_NO_ARGUMENTS_ADAPTOR -DCPPGC_CAGED_HEAP -I../.. -Igen -
I../.. -I../../include -Igen -I../../include -fno-delete-null-pointer-checks -fno-strict-aliasing --param=ssp-buffer-size=4 -fstack-protector -fu
nwind-tables -fPIC -pthread -fcolor-diagnostics -fmerge-all-constants -fcrash-diagnostics-dir=../../tools/clang/crashreports -mllvm -instcombine-
lower-dbg-declare=0 -m64 -march=x86-64 -msse3 -Wno-builtin-macro-redefined -D__DATE__= -D__TIME__= -D__TIMESTAMP__= -Xclang -fdebug-compilation-d
ir -Xclang . -no-canonical-prefixes -Wall -Wextra -Wimplicit-fallthrough -Wunreachable-code -Wthread-safety -Wextra-semi -Wno-missing-field-initi
alizers -Wno-unused-parameter -Wno-c++11-narrowing -Wno-unneeded-internal-declaration -Wno-undefined-var-template -Wno-psabi -Wno-ignored-pragma-
optimize -Wno-implicit-int-float-conversion -Wno-final-dtor-non-final-class -Wno-builtin-assume-aligned-alignment -Wno-deprecated-copy -Wno-non-c
-typedef-for-linkage -Wmax-tokens -fno-omit-frame-pointer -g0 -Wheader-hygiene -Wstring-conversion -Wtautological-overlap-compare -Wmissing-field
-initializers -Wunreachable-code -Wshorten-64-to-32 -O3 -fno-ident -fdata-sections -ffunction-sections -fvisibility=default -Wexit-time-destructo
rs -std=c++14 -fno-trigraphs -Wno-trigraphs -fno-exceptions -fno-rtti -c ../../src/heap/cppgc/allocation.cc -o obj/cppgc_base/allocation.o       
/bin/sh: 1: ../../third_party/llvm-build/Release+Asserts/bin/clang++: not found 
```

It would seem as `clang++` cannot be built properly because some source code download that comes from Google Chromium source code is failing.

This might be also related to the way that we fetch all of the versions (our custom organization repo tags plus the ones from develop branch from the upstream organization).

We also have related to this:
```
Running: gclient sync --with_branch_heads                                                                                                        
Subprocess failed with return code 2.                                                                                                            
./cipd: line 137: ./depot_tools/cipd_client_version.digests: No such file or directory                                                           
Platform linux-amd64 is not supported by the CIPD client bootstrap: there's no pinned SHA256 hash for it in the *.digests file.
```

Let's do one thing... let's build the docker thing without cache... just in case.
**Be careful. This command removes more stuff than usual.**

```
docker system prune -a
docker builder prune -a
```

```
mkdir ~/build-onlyoffice-test-02
cd ~/build-onlyoffice-test-02
git clone https://github.com/btactic-oo/unlimited-onlyoffice-package-builder
cd unlimited-onlyoffice-package-builder

# Edit so that deb build is not done

./onlyoffice-package-builder.sh --product-version=8.0.1 --build-number=31 --unlimited-organization=btactic-oo --tag-suffix=-btactic
```

### Checking the build the next day

**It still fails !!!**

### Upstream build

Let's forget about our btactic-oo organization and any patches that we might have and let's just build everything and report how it goes. We will even build this as a root user even if using docker this should not be a problem. Let's go.

```
cd /root
git clone \
  --depth=1 \
  --recursive \
  --branch v8.0.1.31 \
  https://github.com/ONLYOFFICE/build_tools.git \
  build_tools
# Ignore detached head warning
cd build_tools
mkdir out
docker build --tag onlyoffice-document-editors-builder .
docker run -e PRODUCT_VERSION=8.0.1 -e BUILD_NUMBER=31 -e NODE_ENV='production' -v $(pwd)/out:/build_tools/out onlyoffice-document-editors-builder /bin/bash -c 'cd tools/linux && python3 ./automate.py --branch=tags/v8.0.1.31'
```

Let's see if it builds.

Part of the error 1:
```
Cloning into 'depot_tools'...                                           
WARNING: Your metrics.cfg file was invalid or nonexistent. A new one will be created.
error: unknown option `type'                                            
usage: git config [<options>]

Config file location                                                                                                                             
    --global              use global config file
```

Part of error 2:
```
[0:03:44] Still working on:                                                                                                            [33/97738]
[0:03:44]   v8
________ running 'python3 third_party/depot_tools/update_depot_tools_toggle.py --disable' in '/core/Common/3dParty/v8_89/v8'
________ running 'python3 build/landmines.py --landmine-scripts tools/get_landmines.py' in '/core/Common/3dParty/v8_89/v8'
________ running 'python3 third_party/depot_tools/download_from_google_storage.py --no_resume --no_auth --bucket chromium-clang-format -s buildto
ols/linux64/clang-format.sha1' in '/core/Common/3dParty/v8_89/v8'
  File "third_party/depot_tools/download_from_google_storage.py", line 51
    return f'.{gcs_file_name}{MIGRATION_TOGGLE_FILE_SUFFIX}'
                                                           ^
SyntaxError: invalid syntax
Error: Command 'python3 third_party/depot_tools/download_from_google_storage.py --no_resume --no_auth --bucket chromium-clang-format -s buildtool
s/linux64/clang-format.sha1' returned non-zero exit status 1 in /core/Common/3dParty/v8_89/v8
  File "third_party/depot_tools/download_from_google_storage.py", line 51
    return f'.{gcs_file_name}{MIGRATION_TOGGLE_FILE_SUFFIX}'
                                                           ^
SyntaxError: invalid syntax

Running: gclient root
Running: gclient config --spec 'solutions = [
  {
    "name": "v8",
    "url": "https://chromium.googlesource.com/v8/v8.git",
    "deps_file": "DEPS",
    "managed": False,
    "custom_deps": {},
  },
]
'
Running: gclient sync --with_branch_heads
Subprocess failed with return code 2.
./cipd: line 137: ./depot_tools/cipd_client_version.digests: No such file or directory
Platform linux-amd64 is not supported by the CIPD client bootstrap: there's no pinned SHA256 hash for it in the *.digests file.
error: unknown option `type'
usage: git config [<options>]

Config file location
```

Part of the error 3:
```
[fetch & build]: icu
[fetch & build]: openssl
delete warning [file not exist]: ./openssl.data
gn gen out.gn/linux_64 --args="v8_static_library=true is_component_build=false v8_monolithic=true v8_use_external_startup_data=false use_custom_libcxx=false treat_warnings_as_errors=false target_cpu=\"x64\" v8_target_cpu=\"x64\" is_debug=false is_clang=true use_sysroot=false"
Error (ninja): 1
install dependencies...
Node.js version cannot be less 14
Reinstall
install qt...
---------------------------------------------
build branch: tags/v8.0.1.31
---------------------------------------------
---------------------------------------------
build modules: desktop builder server
---------------------------------------------
Error (./make.py): 1
```

We report the problem to: [https://github.com/ONLYOFFICE/build_tools/issues/802](https://github.com/ONLYOFFICE/build_tools/issues/802) so that it is hopefully taken into account.

## Another build with only the server

Let's see how it goes also with upstream.
As we only build the server module we might skip the chromium related bug.

```
mkdir ~/onlyoffice-only-server
cd ~/onlyoffice-only-server
git clone \
  --depth=1 \
  --recursive \
  --branch v8.0.1.31 \
  https://github.com/ONLYOFFICE/build_tools.git \
  build_tools
# Ignore detached head warning
cd build_tools
mkdir out
docker build --tag onlyoffice-document-editors-builder .
docker run -e PRODUCT_VERSION=8.0.1 -e BUILD_NUMBER=31 -e NODE_ENV='production' -v $(pwd)/out:/build_tools/out onlyoffice-document-editors-builder /bin/bash -c 'cd tools/linux && python3 ./automate.py server --branch=tags/v8.0.1.31'
```

Same problem as above.

## Try to build an older version

Let's try to build: `8.0.0-99`. Ok, as always we will try to build **everything** and from **upstream** to see if it's worth of it.

```
cd /root
git clone \
  --depth=1 \
  --recursive \
  --branch v8.0.0.99 \
  https://github.com/ONLYOFFICE/build_tools.git \
  build_tools
# Ignore detached head warning
cd build_tools
mkdir out
docker build --tag onlyoffice-document-editors-builder .
docker run -e PRODUCT_VERSION=8.0.0 -e BUILD_NUMBER=99 -e NODE_ENV='production' -v $(pwd)/out:/build_tools/out onlyoffice-document-editors-builder /bin/bash -c 'cd tools/linux && python3 ./automate.py --branch=tags/v8.0.0.99'
```

The same problem happens.

## Let's try to build our target version but manually so that we can debug

```
mkdir ~/build-only-manual-01
cd ~/build-only-manual-01
git clone \
  --depth=1 \
  --recursive \
  --branch v8.0.1.31 \
  https://github.com/ONLYOFFICE/build_tools.git \
  build_tools
# Ignore detached head warning
cd build_tools
mkdir out
docker build --tag onlyoffice-document-editors-builder .
docker run -it -e PRODUCT_VERSION=8.0.1 -e BUILD_NUMBER=31 -e NODE_ENV='production' -v $(pwd)/out:/build_tools/out onlyoffice-document-editors-builder /bin/bash
```

We run:
```
cd tools/linux
PRODUCT_VERSION=8.0.1 BUILD_NUMBER=31 NODE_ENV=production python3 ./automate.py server --branch=tags/v8.0.1.31
```
till it fails so that it's a bit easier to change some bits and try to build again.

This f-string was added in Python 3.6. We are supposed to be using Python 3.8.10 so we should be fine.

I think what we should be doing is to modify:
```
base.cmd("git", ["clone", "https://chromium.googlesource.com/chromium/tools/depot_tools.git"])
```
line inside of the make function in `scripts/core_common/modules/v8.py` from build_tools so that we can ask for an specific branch which it's a bit older and that does not introduce this error.

Look at that, `python3 --version` from Ubuntu 16.04 it's Python 3.5.2 which it's not good enough for using f-strings as they are using in depot_tools latest commit. So this must be the problem.

The workaround for me it's going to be to check an older version of v8.

**Wait a moment.**

I suspect that using NODE_ENV not set to production might trigger the development recipe and Python 3.8.x will be used and then the problem won't happen. Although the source code does not seem to have any of this. Well, let's forget about this.

I will update the Docker from Ubuntu 16.04 to Ubuntu 20.04 on build_tools and force-push the new tag.

## New build test with Ubuntu 20.04

```
mkdir ~/build-onlyoffice-test-u20
cd ~/build-onlyoffice-test-u20
git clone https://github.com/btactic-oo/unlimited-onlyoffice-package-builder
cd unlimited-onlyoffice-package-builder

# Edit so that deb build is not done

./onlyoffice-package-builder.sh --product-version=8.0.1 --build-number=31 --unlimited-organization=btactic-oo --tag-suffix=-btactic
```

**The build has been succesful.**

I have created an issue regarding that their [default Dockerfile should be updated to use Ubuntu 20.04](https://github.com/ONLYOFFICE/build_tools/issues/807) or whatever.

## Package Ubuntu 20.04 build into deb package thanks to Docker

Now we can actually test the new code (manually) we have done in order to package everything to see how it goes.

```
docker build --tag onlyoffice-deb-builder . -f Dockerfile-manual-debian-11
export PRODUCT_VERSION=8.0.1 BUILD_NUMBER=31 TAG_SUFFIX=-btactic UNLIMITED_ORGANIZATION=btactic-oo
docker run \
  -it \
  --env PRODUCT_VERSION=${PRODUCT_VERSION} \
  --env BUILD_NUMBER=${BUILD_NUMBER} \
  --env TAG_SUFFIX=${TAG_SUFFIX} \
  --env UNLIMITED_ORGANIZATION=${UNLIMITED_ORGANIZATION} \
  -v $(pwd):/usr/local/unlimited-onlyoffice-package-builder:ro \
  -v $(pwd):/root:rw \
  onlyoffice-deb-builder /bin/bash -c "/usr/local/unlimited-onlyoffice-package-builder/onlyoffice-deb-builder.sh --product-version ${PRODUCT_VERSION} --build-number ${BUILD_NUMBER} --tag-suffix ${TAG_SUFFIX} --unlimited-organization ${UNLIMITED_ORGANIZATION}"
```

Well, there has been some errors around switch ordering which we have fixed:
```
Cloning into 'document-server-package'...
Username for 'https://github.com':
```

So, after many fixes the final error that we have is the following one:
```
mkdir -p common/documentserver/home/core-fonts common/documentserver/home/license common/documentserver/home/web-apps common/documentserver/home/server common/documentserver/home/sdkjs common/documentserver/home/sdkjs-plugins
cp -rf -t common/documentserver/home ../build_tools/out/linux_64/onlyoffice/documentserver/*
cp: cannot stat '../build_tools/out/linux_64/onlyoffice/documentserver/*': No such file or directory
make: *** [Makefile:323: documentserver] Error 1
```

And it finally builds the deb package.

There are a lot of warning about `en_US.UTF-8` not being installed so we might review why it's getting ignored because Dockerfile-manual-debian-11 has it in it.
**TODO1**: We should try to install `locales-all` package and see if it fixes it.

**TODO2**: It would be also useful not to send all of the binaries output to the Docker daemon. So, probably the deb build part needs to be in a subdirectory.

In any case we have our resultant deb file here: `document-server-package/deb/onlyoffice-documentserver_8.0.1-31-btactic_amd64.deb` .

We will be also missing some `.gitignore` files for the repos that we checkout.

## New build test ( dev-v010 ) Ubuntu 20.04

```
mkdir ~/build-onlyoffice-test-u20-v010
cd ~/build-onlyoffice-test-u20-v010
git clone https://github.com/btactic-oo/unlimited-onlyoffice-package-builder -b dev-v010
cd unlimited-onlyoffice-package-builder

./onlyoffice-package-builder.sh --product-version=8.0.1 --build-number=31 --unlimited-organization=btactic-oo --tag-suffix=-btactic
```

## Let's add a new parametre --debian-package-suffix

```
mkdir ~/build-onlyoffice-test-u20-v012
cd ~/build-onlyoffice-test-u20-v012
git clone https://github.com/btactic-oo/unlimited-onlyoffice-package-builder -b dev-v012
cd unlimited-onlyoffice-package-builder

./onlyoffice-package-builder.sh --product-version=8.0.1 --build-number=31 --unlimited-organization=btactic-oo --tag-suffix=-btactic --debian-package-suffix=-btactic
```

## web-apps . Mobile Edit feature

We will try to turn on Mobile Edit feature directly into web-apps and see what happens.
We will fork web-apps onto btactic-oo and add some commits there.

Let's fetch recent information from official OnlyOffice repo.

```
cd onlyoffice_repos/web-apps
git checkout master
git pull upstream-origin master
git fetch --all --tags
```

We create a new branch based on the recently fetched tag.

```
git checkout tags/v8.0.1.31 -b 8.0.1.31-btactic
```

Now we will do our changes regarding the mobile edit feature and commit them.

Let's push and create appropiate tags:

```
git push origin 8.0.1.31-btactic
git tag -a 'v8.0.1.31-btactic' -m '8.0.1.31-btactic'
git push origin v8.0.1.31-btactic
```

## Github Actions

We should be able to build and publish a release thanks to:

```
git tag -a 'builds-debian-11/8.0.1.31' -m 'builds-debian-11/8.0.1.31'
git push origin 'builds-debian-11/8.0.1.31'
```

we will polish the yml till it works.

The last failure is about not having enough space but that does not make sense because, right now, we are only building binaries so we shouldn't run out of space.

Apparently this has failed while trying to build v8.

```
Receiving objects:  64% (711672/1096341), 659.62 MiB | 24.55 MiB/s
Receiving objects:  65% (712622/1096341), 674.91 MiB | 25.34 MiB/s
Receiving objects:  65% (715198/1096341), 674.91 MiB | 25.34 MiB/s
fatal: write error: No space left on device
fatal: index-pack failed
1>WARNING: subprocess '"git" "-c" "core.deltaBaseCacheLimit=2g" "clone" "--no-checkout" "--progress" "https://chromium.googlesource.com/v8/v8.git" "/core/Common/3dParty/v8_89/_gclient_v8_nx5im46z"' in /core/Common/3dParty/v8_89 failed; will retry after a short nap...
```

I am going to attempt to rebuild all the jobs just in case.

In any case it seems we will need to figure out a better way of building this, probably step by step or with some switches to remove some space.

Maybe when qt is being built you can delete its source code.

So... I had a very strange permissions error: ``.
Which I was not able to fix because apparently I was working with [a commit that modified a workflow/Github Action](https://github.blog/changelog/2023-11-02-github-actions-enforcing-workflow-scope-when-creating-a-release/).

I need both `contents:write` and `workflows:write`.

But that does not work in because workflows isn't recognised. I will push a branch that already has that commit and, that way, it will somehow work. E.g. Do not push the tag directly but its branch first and then the tag.

I confirm that first sending the branch and then the tag does the trick and the release can be published.

Now we should be able to update build_tools so that the web-apps directory is taken onto account and more stuff.

## build_tools improvement

So we want to include the unlimited org, the unlimited tag suffix and the unlimited repos so that everything it's a bit better.

Ok, so now we have this new branch named 8.0.1.31-btactic3 with this three interesting commits:
- Dockerfile: Bump Docker from Ubuntu 16 to Ubuntu 20 so that it uses Python 3.8.
- owner is used on ssh protocol too
- Use btactic-oo organization and -btactic suffix when either server or web-apps repo are fetched.

Now, let's make sure to recreate the `v8.0.1.31-btactic` tag so that it points to this branch.

## Build everything again

Now we should be fine to try to build everything onto Github again.

Let's try in our unlimited-onlyoffice-package-builder :

- Delete latest release (which we want to recreate)
- Delete tags from our latest release (which we want to recreate).

```
git push origin dev-v015
git tag --delete 'builds-debian-11/8.0.1.31'
git tag -a 'builds-debian-11/8.0.1.31' -m 'builds-debian-11/8.0.1.31'
git push --force origin 'builds-debian-11/8.0.1.31'
```

## Testing has some problems

So, apparently we are lacking `/etc/supervisor/conf.d/ds-converter.conf` in our system after installing the package. I think it is a consequence of only installing the `server` component which does not have those configuration files. **If that's the case this is a bug.**

```
Desempaquetando onlyoffice-documentserver (8.0.1-31-btactic) sobre (7.0.0-132~btactic1) ...                                                      
Configurando onlyoffice-documentserver (8.0.1-31-btactic) ...                                                                                    
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver-example/default.json ...                                
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver-example/nginx/includes/ds-example.conf ...              
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver-example/production-linux.json ...                       
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver-example/production-windows.json ...                     
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver/default.json ...                                        
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver/development-linux.json ...                              
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver/development-mac.json ...                                
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver/development-windows.json ...                            
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver/log4js/development.json ...                             
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver/log4js/production.json ...                              
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver/logrotate/ds.conf ...
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver/nginx/ds-ssl.conf.tmpl ...
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver/nginx/ds.conf.tmpl ...
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver/nginx/includes/ds-docservice.conf ...
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver/nginx/includes/http-common.conf ...
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver/production-linux.json ...
Instalando una nueva versión del fichero de configuración /etc/onlyoffice/documentserver/production-windows.json ...
```

So, apparently the files are there but somehow those same files are removed from supervisord so this cannot be updated.

I might need to check if there is any guide to update from OnlyOffice 7 to OnlyOffice 8.

Wait a moment... those files are not used in our production environment.

Our production environment leads us to:
```
● ds-docservice.service - Docs Docservice
     Loaded: loaded (/lib/systemd/system/ds-docservice.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2024-05-10 19:13:06 CEST; 49min ago
   Main PID: 1753208 (sh)
      Tasks: 12 (limit: 9510)
     Memory: 90.0M
        CPU: 4.734s
     CGroup: /system.slice/ds-docservice.service
             ├─1753208 /bin/sh -c exec /var/www/onlyoffice/documentserver/server/DocService/docservice 2>&1 | tee -a /var/log/onlyoffice/documen>
             ├─1753212 /var/www/onlyoffice/documentserver/server/DocService/docservice
             └─1753213 tee -a /var/log/onlyoffice/documentserver/docservice/out.log

may 10 20:02:56 onlyoffice006 sh[1753213]: [2024-05-10T20:02:56.668] [ERROR] [localhost] [docId] [userId] nodeJS - [AMQP] Error: connect ECONNRE>
may 10 20:02:56 onlyoffice006 sh[1753213]:     at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1187:16
```
where we can debug what might be happening (assuming it's not a bug related to **not building all of the modules**).

Unfortunately those `Error: connect ECONNREFUSED` errors happened way before installing this package.
I might need to restore an snapshot of my onlyoffice build machine to make sure I'm not over checking something that it was already broken.

Well, before doing that... The port 5672 that appears in the logs seems to be related to `beam.smp` which it's connected to rabbitmq.

And that's right, trying to start its service (after stopping it) ends in an error.

```
root@onlyoffice006:~# systemctl start rabbitmq-server.service 
Job for rabbitmq-server.service failed because the control process exited with error code.
See "systemctl status rabbitmq-server.service" and "journalctl -xe" for details.
```

I'll try to debug this just in case it's something easy to fix.

It's worth a try to reinstall this package after a purge and then probably reinstall our onlyoffice package.

```
sudo apt-get purge rabbitmq-server
sudo apt-get install rabbitmq-server
```

Wait a moment... apparently... fixing my /etc/hosts should fix this issue.

Well, after all, it might have not been needed to build every module instead of only the `server` module.
With only server module it takes around 2 hours to build in Github Actions, if it takes much longer with all of the modules (or if it takes too much space) I might reconsider switching back to only build the server component.

Ok, there is no meaningful difference between building only the `server` module or all of them so we will build all of them as once I was advised.

I think we are done with all of this.

## Possible issue with QT

Do we actually need to build QT for the server part? Never mind, it has been already [reported](https://github.com/ONLYOFFICE/build_tools/issues/190).

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

8.0.1-31

so that's the version that we will be using.

### server repo update

Old stuff that we already had:
- branch: 7.4.1.36-btactic
- tag: v7.4.1.36-btactic
- commit (connection limit): e6a3bc05f84cd05fa7ee6516fb0e662a20c0336f

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
git checkout tags/v8.0.1.31 -b 8.0.1.31-btactic
```
.

Cherry-pick what we already had:

```
git cherry-pick e6a3bc05f84cd05fa7ee6516fb0e662a20c0336f
```

At this point we have a conflict. Let's try to fix it.


Let's push and create appropiate tags:

```
git push origin 8.0.1.31-btactic
git tag -a 'v8.0.1.31-btactic' -m '8.0.1.31-btactic'
git push origin v8.0.1.31-btactic
```

### build_tools repo update

Old stuff that we already had:
- branch: 7.4.1.36-btactic
- tag: v7.4.1.36-btactic
- commit (use custom repo): a082e48f11dc081a87227ca8d1f5714a0470d151

Let's fetch recent information from official OnlyOffice repo.

```
cd onlyoffice_repos/build_tools
git checkout master
git pull upstream-origin master
git fetch --all --tags
```

We create a new branch based on the recently fetched tag.

```
git checkout tags/v8.0.1.31 -b 8.0.1.31-btactic
```

.

Cherry-pick what we already had:

```
git cherry-pick a082e48f11dc081a87227ca8d1f5714a0470d151
```
.

Now we need to edit this commit so that it no longer uses btactic org but new btactic-oo org.
Also its description.

Let's push and create appropiate tags:

```
git push origin 8.0.1.31-btactic
git tag -a 'v8.0.1.31-btactic' -m '8.0.1.31-btactic'
git push origin v8.0.1.31-btactic
```

### document-server-package repo update

Back in the day we could just work with the latest onlyoffice document-server-package master branch.
Unfortunately they have a bug so let's do our own.

Old stuff that we already had:
- commit (Fix deb build): 93170568b3b1bc30ce9356342080e34cbea3c089

Let's fetch recent information from official OnlyOffice repo.

```
cd onlyoffice_repos/document-server-package
git checkout master
git pull upstream-origin master
git fetch --all --tags
```

We create a new branch based on the recently fetched tag.

```
git checkout tags/v8.0.1.31 -b 8.0.1.31-btactic
```

.

Apply deb build fix:
```
git cherry-pick 93170568b3b1bc30ce9356342080e34cbea3c089
```
.

Let's push and create appropiate tags.
Yes, having a branch here for everyone of the releases is not needed at all.
We could just upload the tag.

```
git push origin 8.0.1.31-btactic
git tag -a 'v8.0.1.31-btactic' -m '8.0.1.31-btactic'
git push origin v8.0.1.31-btactic
```

### Build from build virtual machine

This virtual machine has Docker installed in it.

```
mkdir ~/build-oo
cd ~/build-oo
git clone https://github.com/btactic-oo/unlimited-onlyoffice-package-builder
cd unlimited-onlyoffice-package-builder
./onlyoffice-package-builder.sh --product-version=8.0.1 --build-number=31 --unlimited-organization=btactic-oo --tag-suffix=-btactic --debian-package-suffix=-btactic
```

### Final package

The final `onlyoffice-documentserver_8.0.1-31-btactic_amd64.deb` deb package can be found at: `~/build-oo/unlimited-onlyoffice-package-builder/document-server-package/deb/` directory.

### TODO: GitHub Actions for releasing

### Release

Get your `onlyoffice-documentserver_8.0.1-31-btactic_amd64.deb` to your local machine.

Visit: [https://github.com/btactic-oo/document-server-package/releases/tag/v8.0.1.31-btactic](https://github.com/btactic-oo/document-server-package/releases/tag/v8.0.1.31-btactic) and click **Create release from tag** button.

Fill in appropiate release title, description, and finally attach your renamed deb as a binary.

Publish release.

## Useful links

- [https://www.btactic.com/build-onlyoffice-from-source-code-2023/?lang=en](https://www.btactic.com/build-onlyoffice-from-source-code-2023/?lang=en)
- [https://github.com/btactic-oo/document-server-package/releases/tag/v8.0.1.31-btactic](https://github.com/btactic/document-server-package/releases/tag/v8.0.1.31-btactic)
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
