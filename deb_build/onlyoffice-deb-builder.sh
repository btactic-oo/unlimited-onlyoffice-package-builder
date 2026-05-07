#!/bin/bash

#######################################################################
# OnlyOffice Deb Builder

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

EOF

}

UPSTREAM_ORGANIZATION="ONLYOFFICE"

DOCUMENT_SERVER_PACKAGE_CUSTOM_COMMITS="84268299a425d4ea8966cf1645c65236d41cbe15"

prepare_custom_repo() {

  _REPO=$1
  shift
  _TAG=$1
  shift
  _UNLIMITED_ORGANIZATION=$1
  shift
  # Rest of arguments are commits to cherry-pick in order

  git clone https://github.com/${_UNLIMITED_ORGANIZATION}/${_REPO}
  cd ${_REPO}
  git remote add upstream-origin https://github.com/${UPSTREAM_ORGANIZATION}/${_REPO}

  git checkout master
  git pull upstream-origin master
  git fetch --all --tags
  git checkout tags/${_TAG} -b ${_TAG}-custom

  # Hard-code temp git user.name and user.email for this local cherry-picked commit
  git config user.name 'CherryPick User'
  git config user.email 'cherrypick@btacticoo.com'

  while [ "$#" -gt 0 ]; do
    _ncommit=$1
    if ! git cherry-pick "${_ncommit}"; then
      echo "Error: cherry-pick of commit ${_ncommit} failed in ${_REPO}" >&2
      echo "Aborting!"
      exit 3
    fi
    shift
  done

  # Force our changes
  git tag --delete ${_TAG}
  git tag -a "${_TAG}" -m "${_TAG}"

  cd ..

}


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
  esac
done


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

build_deb() {

  build_deb_pre_pwd="$(pwd)"
  DOCUMENT_SERVER_PACKAGE_PATH="$(pwd)/document-server-package"

  _PRODUCT_VERSION=$1 # 7.4.1
  _BUILD_NUMBER=$2 # 36
  _TAG_SUFFIX=$3 # -btactic
  _UNLIMITED_ORGANIZATION=$4 # btactic-oo
  _DEBIAN_PACKAGE_SUFFIX=$5

  _GIT_CLONE_BRANCH="v${_PRODUCT_VERSION}.${_BUILD_NUMBER}"

  # TODO: These requirements should be moved to Dockerfile
  # apt install build-essential m4 npm
  # npm install -g pkg

  prepare_custom_repo "document-server-package" "${_GIT_CLONE_BRANCH}" "${_UNLIMITED_ORGANIZATION}" ${DOCUMENT_SERVER_PACKAGE_CUSTOM_COMMITS}
  # Ignore DETACHED warnings
  # Workaround for installing dependencies - BEGIN
  cd ${DOCUMENT_SERVER_PACKAGE_PATH}

  cat << EOF >> Makefile

deb_dependencies: \$(DEB_DEPS)

EOF

  PRODUCT_VERSION="${_PRODUCT_VERSION}" BUILD_NUMBER="${_BUILD_NUMBER}${_DEBIAN_PACKAGE_SUFFIX}" make deb_dependencies
  cd ${DOCUMENT_SERVER_PACKAGE_PATH}/deb/build
  apt-get -qq build-dep -y ./
  # Workaround for installing dependencies - END

  cd ${DOCUMENT_SERVER_PACKAGE_PATH}
  PRODUCT_VERSION="${_PRODUCT_VERSION}" BUILD_NUMBER="${_BUILD_NUMBER}${_DEBIAN_PACKAGE_SUFFIX}" make deb

  cd ${build_deb_pre_pwd}

}

build_deb "${PRODUCT_VERSION}" "${BUILD_NUMBER}" "${TAG_SUFFIX}" "${UNLIMITED_ORGANIZATION}" "${DEBIAN_PACKAGE_SUFFIX}"
