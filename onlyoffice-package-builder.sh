#!/bin/bash

#######################################################################
# OnlyOffice Package Builder

# Copyright (C) 2024 BTACTIC, SCCL

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################

usage() {
cat <<EOF

  $0
  Copyright BTACTIC, SCCL
  Licensed under the GNU PUBLIC LICENSE 3.0

  Usage: $0 --product-version=PRODUCT_VERSION --build-number=BUILD_NUMBER --unlimited-organization=ORGANIZATION --tag-suffix=-TAG_SUFFIX --debian-package-suffix=-DEBIAN_PACKAGE_SUFFIX
  Example: $0 --product-version=7.4.1 --build-number=36 --unlimited-organization=btactic-oo --tag-suffix=-btactic --debian-package-suffix=-btactic

  For Github actions you might want to either build only binaries or build only deb so that it's easier to prune containers
  Example: $0 --product-version=7.4.1 --build-number=36 --unlimited-organization=btactic-oo --tag-suffix=-btactic --debian-package-suffix=-btactic --binaries-only
  Example: $0 --product-version=7.4.1 --build-number=36 --unlimited-organization=btactic-oo --tag-suffix=-btactic --debian-package-suffix=-btactic --deb-only

EOF

}

BINARIES_ONLY="false"
DEB_ONLY="false"

# Check the arguments.
for option in "$@"; do
  case "$option" in
    -h | --help)
      usage
      exit 0
    ;;
    --product-version=*)
      PRODUCT_VERSION=`echo "$option" | sed 's/--product-version=//'`
    ;;
    --build-number=*)
      BUILD_NUMBER=`echo "$option" | sed 's/--build-number=//'`
    ;;
    --unlimited-organization=*)
      UNLIMITED_ORGANIZATION=`echo "$option" | sed 's/--unlimited-organization=//'`
    ;;
    --tag-suffix=*)
      TAG_SUFFIX=`echo "$option" | sed 's/--tag-suffix=//'`
    ;;
    --debian-package-suffix=*)
      DEBIAN_PACKAGE_SUFFIX=`echo "$option" | sed 's/--debian-package-suffix=//'`
    ;;
    --binaries-only)
      BINARIES_ONLY="true"
    ;;
    --deb-only)
      DEB_ONLY="true"
    ;;
  esac
done

BUILD_BINARIES="true"
BUILD_DEB="true"

if [ ${BINARIES_ONLY} == "true" ] ; then
  BUILD_BINARIES="true"
  BUILD_DEB="false"
fi

if [ ${DEB_ONLY} == "true" ] ; then
  BUILD_BINARIES="false"
  BUILD_DEB="true"
fi

if [ "x${PRODUCT_VERSION}" == "x" ] ; then
    cat << EOF
    --product-version option must be informed.
    Aborting...
EOF
    usage
    exit 1
fi

if [ "x${BUILD_NUMBER}" == "x" ] ; then
    cat << EOF
    --build-number option must be informed.
    Aborting...
EOF
    usage
    exit 1
fi

if [ "x${UNLIMITED_ORGANIZATION}" == "x" ] ; then
    cat << EOF
    --unlimited-organization option must be informed.
    Aborting...
EOF
    usage
    exit 1
fi

if [ "x${TAG_SUFFIX}" == "x" ] ; then
    cat << EOF
    --tag-suffix option must be informed.
    Aborting...
EOF
    usage
    exit 1
fi

if [ "x${DEBIAN_PACKAGE_SUFFIX}" == "x" ] ; then
    cat << EOF
    --debian-package-suffix option must be informed.
    Aborting...
EOF
    usage
    exit 1
fi

PRUNE_DOCKER_CONTAINERS_ACTION="false"
if [ "x${PRUNE_DOCKER_CONTAINERS}" != "x" ] ; then
  if [ ${PRUNE_DOCKER_CONTAINERS} == "true" ] -o [ ${PRUNE_DOCKER_CONTAINERS} == "TRUE" ] ; then
    PRUNE_DOCKER_CONTAINERS_ACTION="true"
    cat << EOF
    WARNING !
    WARNING !
    --prune-docker-containers has been set to true
    This will erase all of your docker containers
    after the binaries build.

    Waiting for 30s so that you can CTRL+C
EOF
    sleep 30s
  fi
fi

build_oo_binaries() {

  _OUT_FOLDER=$1 # out
  _PRODUCT_VERSION=$2 # 7.4.1
  _BUILD_NUMBER=$3 # 36
  _TAG_SUFFIX=$4 # -btactic
  _UNLIMITED_ORGANIZATION=$5 # btactic-oo

  _UPSTREAM_TAG="v${_PRODUCT_VERSION}.${_BUILD_NUMBER}"
  _UNLIMITED_ORGANIZATION_TAG="${_UPSTREAM_TAG}${_TAG_SUFFIX}"

  git clone \
    --depth=1 \
    --recursive \
    --branch ${_UNLIMITED_ORGANIZATION_TAG} \
    https://github.com/${_UNLIMITED_ORGANIZATION}/build_tools.git \
    build_tools
  # Ignore detached head warning
  cd build_tools
  mkdir ${_OUT_FOLDER}
  docker build --tag onlyoffice-document-editors-builder .
  docker run -e PRODUCT_VERSION=${_PRODUCT_VERSION} -e BUILD_NUMBER=${_BUILD_NUMBER} -e NODE_ENV='production' -v $(pwd)/${_OUT_FOLDER}:/build_tools/out onlyoffice-document-editors-builder /bin/bash -c '\
    cd tools/linux && \
    python3 ./automate.py \
      --branch=tags/'"${_UPSTREAM_TAG}"' \
      --repo-overrides=server=https://github.com/'"${_UNLIMITED_ORGANIZATION}"'/server.git,web-apps=https://github.com/'"${_UNLIMITED_ORGANIZATION}"'/web-apps.git \
      --repo-branch-overrides=server=tags/'"${_UNLIMITED_ORGANIZATION_TAG}"',web-apps=tags/'"${_UNLIMITED_ORGANIZATION_TAG}"
  cd ..

}

if [ "${BUILD_BINARIES}" == "true" ] ; then
  build_oo_binaries "out" "${PRODUCT_VERSION}" "${BUILD_NUMBER}" "${TAG_SUFFIX}" "${UNLIMITED_ORGANIZATION}"
  build_oo_binaries_exit_value=$?
fi

# Simulate that binaries build went ok
# when we only want to make the deb
if [ ${DEB_ONLY} == "true" ] ; then
  build_oo_binaries_exit_value=0
fi

if [ "${BUILD_DEB}" == "true" ] ; then
  if [ ${build_oo_binaries_exit_value} -eq 0 ] ; then
    cd deb_build
    docker build --tag onlyoffice-deb-builder . -f Dockerfile-manual-debian-11
    docker run \
      --env PRODUCT_VERSION=${PRODUCT_VERSION} \
      --env BUILD_NUMBER=${BUILD_NUMBER} \
      --env TAG_SUFFIX=${TAG_SUFFIX} \
      --env UNLIMITED_ORGANIZATION=${UNLIMITED_ORGANIZATION} \
      --env DEBIAN_PACKAGE_SUFFIX=${DEBIAN_PACKAGE_SUFFIX} \
      -v $(pwd):/usr/local/unlimited-onlyoffice-package-builder:ro \
      -v $(pwd):/root:rw \
      -v $(pwd)/../build_tools:/root/build_tools:ro \
      onlyoffice-deb-builder /bin/bash -c "/usr/local/unlimited-onlyoffice-package-builder/onlyoffice-deb-builder.sh --product-version ${PRODUCT_VERSION} --build-number ${BUILD_NUMBER} --tag-suffix ${TAG_SUFFIX} --unlimited-organization ${UNLIMITED_ORGANIZATION} --debian-package-suffix ${DEBIAN_PACKAGE_SUFFIX}"
    cd ..
  else
    echo "Binaries build failed!"
    echo "Aborting... !"
    exit 1
  fi
fi
