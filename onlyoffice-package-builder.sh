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

  Usage: $0 --production-version=PRODUCT_VERSION --build-number=BUILD_NUMBER --unlimited-organization=ORGANIZATION --tag-suffix=-TAG_SUFFIX
  Example: $0 --production-version=7.4.1 --build-number=36 --unlimited-organization=btactic-oo --tag-suffix=-btactic

EOF

}


# Check the arguments.
for option in "$@"; do
  case "$option" in
    -h | --help)
      usage
      exit 0
    ;;
    --production-version=*)
      PRODUCTION_VERSION=`echo "$option" | sed 's/--production-version=//'`
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
  esac
done


if [ "x${PRODUCTION_VERSION}" == "x" ] ; then
    cat << EOF
    --production-version option must be informed.
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

build_oo_binaries() {

  _OUT_FOLDER=$1 # out
  _PRODUCT_VERSION=$2 # 7.4.1
  _BUILD_NUMBER=$3 # 36
  _TAG_SUFFIX=$4 # -btactic
  _UNLIMITED_ORGANIZATION=$5 # btactic-oo

  _GIT_CLONE_BRANCH="v${_PRODUCT_VERSION}.${_BUILD_NUMBER}${_TAG_SUFFIX}"

  git clone \
    --depth=1 \
    --recursive \
    --branch ${_GIT_CLONE_BRANCH} \
    https://github.com/${_UNLIMITED_ORGANIZATION}/build_tools.git \
    build_tools
  # Ignore detached head warning
  cd build_tools
  mkdir ${_OUT_FOLDER}
  docker build --tag onlyoffice-document-editors-builder .
  docker run -e PRODUCT_VERSION=${_PRODUCT_VERSION} -e BUILD_NUMBER=${_BUILD_NUMBER} -e NODE_ENV='production' -v $(pwd)/${_OUT_FOLDER}:/build_tools/out onlyoffice-document-editors-builder /bin/bash -c 'cd tools/linux && python3 ./automate.py --branch=tags/'"${_GIT_CLONE_BRANCH}"
  cd ..

}

build_deb() {

  build_deb_pre_pwd="$(pwd)"

  _PRODUCT_VERSION=$2 # 7.4.1
  _BUILD_NUMBER=$3 # 36
  _TAG_SUFFIX=$4 # -btactic
  _UNLIMITED_ORGANIZATION=$5 # btactic-oo

  _GIT_CLONE_BRANCH="v${_PRODUCT_VERSION}.${_BUILD_NUMBER}${_TAG_SUFFIX}"

  # TODO: These requirements should be moved to Dockerfile
  # apt install build-essential m4 npm
  # npm install -g pkg

  git clone https://github.com/${_UNLIMITED_ORGANIZATION}/document-server-package.git -b ${_GIT_CLONE_BRANCH}
  # Ignore DETACHED warnings
  # Workaround for installing dependencies - BEGIN
  cd document-server-package

  cat << EOF >> Makefile

deb_dependencies: \$(DEB_DEPS)

EOF

  PRODUCT_VERSION="${_PRODUCT_VERSION}" BUILD_NUMBER="${_BUILD_NUMBER}${_TAG_SUFFIX}" make deb_dependencies
  cd document-server-package/deb/build
  apt build-dep ./
  # Workaround for installing dependencies - END

  cd document-server-package
  PRODUCT_VERSION="${_PRODUCT_VERSION}" BUILD_NUMBER="${_BUILD_NUMBER}${_TAG_SUFFIX}" make deb

  cd ${build_deb_pre_pwd}

}

build_oo_binaries "out" "${PRODUCT_VERSION}" "${BUILD_NUMBER}" "${TAG_SUFFIX}" "${UNLIMITED_ORGANIZATION}"
build_deb "${PRODUCT_VERSION}" "${BUILD_NUMBER}" "${TAG_SUFFIX}" "${UNLIMITED_ORGANIZATION}"
