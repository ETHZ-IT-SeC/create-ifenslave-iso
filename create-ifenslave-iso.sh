#!/bin/sh

set -e

# Automatic configuration
BASEDIR="$(dirname $0)"
SOURCEDIR="${BASEDIR}/debs"

# Source os-release for release name
. /etc/os-release

# Create download directory and change to it
mkdir -pv "${SOURCEDIR}"
cd "${SOURCEDIR}"

# Download what's not yet there.
if [ -r ../packages-${VERSION_CODENAME} ]; then
    apt download $(egrep -v '^$|^#' ../packages-${VERSION_CODENAME})
else
    apt download $(egrep -v '^$|^#' ../packages)
fi
if [ -r ../packages.local ]; then
    apt download $(egrep -v '^$|^#' ../packages.local)
fi

# Copy some helpful config files into the ISO's source
cd ..
for file in sources.list interfaces ; do
    if [ -r default-config-files/$file-${VERSION_CODENAME} ]; then
        cp -pv default-config-files/$file-${VERSION_CODENAME} debs/$file
    else
        cp -pv default-config-files/$file debs/
    fi
done

# Finally generate the ISO with the proper options
genisoimage -iso-level 4 -allow-lowercase -o ifenslave-${VERSION_CODENAME}.iso debs
