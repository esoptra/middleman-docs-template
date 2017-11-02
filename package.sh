#!/usr/bin/env bash
set -xe
# Figure out where the repo is stored
WD=$(dirname $(realpath $0))
# We need to inject a version into the build, if one isnt set a a environment variable we inject the branch and current hash
if [ -z "$WEBSITE_VERSION" ]
then
    BRANCH=$( cd $(dirname $(realpath $0)); git rev-parse --abbrev-ref HEAD )
    HASH_SHORT=$( cd $(dirname $(realpath $0)); git rev-parse --short HEAD )
    PACKAGE_VERSION=$BRANCH-$HASH_SHORT
else
    PACKAGE_VERSION=$WEBSITE_VERSION
fi
# Clean the package workspace
rm -rf package

# Inject the version into the CHANGES file
mkdir -p package
cp $WD/CHANGES.md package/CHANGES.md
sed -i -e "1s/.*/${PACKAGE_VERSION}/g" package/CHANGES.md

# Create the artifact deb
mkdir -p package/deb
mkdir -p package/deb/var/www/docs.esoptra.io
cp -a $WD/build/. package/deb/var/www/docs.esoptra.io

fpm \
  -s dir \
  -t deb \
  -a all \
  -n docs.esoptra.io \
  --vendor 'Esoptra N.V' \
  --version $PACKAGE_VERSION \
  --description 'Esoptra engineering docs website' \
  --maintainer esoptra \
  --deb-user root \
  --deb-group root \
  --deb-changelog package/CHANGES.md \
  --deb-use-file-permissions \
  --epoch '1' \
  --iteration '1' \
  --url 'https://docs_esoptra_io' \
  -C package/deb \
  .

# Output the content en metadata for the created rpm
dpkg-deb -I *.deb
dpkg-deb -c *.deb
