# unlimited-onlyoffice-package-builder

Unlimited OnlyOffice Package Builder let's you build OnlyOffice with no limits and package it (currently only deb packages are supported).

**WARNING: The development stage is in ALPHA QUALITY and it is not ready for production deployment.**

## Docker requirement

**TODO**

## How to build example

```
mkdir ~/build-onlyoffice-test-01
cd ~/build-onlyoffice-test-01
git clone https://github.com/btactic-oo/unlimited-onlyoffice-package-builder
cd unlimited-onlyoffice-package-builder
./onlyoffice-package-builder.sh --product-version=7.4.1 --build-number=36 --unlimited-organization=btactic-oo --tag-suffix=-btactic
```
