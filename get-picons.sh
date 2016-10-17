#!/bin/sh
#
# get-picons.sh v1.0 written by Andreas J. Bathe (2016-10-17)
#
# This script downloads picons from http://picons.xyz
# and integrates them into Kodi Media Center under /storage/picons
#
# Service Reference Picons (SRP); e.g. picon://1_0_1_1389_3EA_1_C00000_0_0_0.png
# Service Named Picons (SNP); e.g. picon://logos/bbcworldnews.png
#
# see, e.g. http://echannelizer.com/guide/what-are-picons/ for more information
#
# Don't forget to set TV-Settings -> Menu/OSD -> Folder with channel icons to
# /storage/picons/logos (this path can be different with other OSes).
 
URL="https://picons.xyz/downloads"
DIR="binaries-srp-full"
TYPE="400x240-400x240.light.on.transparent"

# Namespace of orbital positions
# Astra 19.2°E    =  C00000 ( 19.2 * 10 = 192 =   0xC0 )
# Astra 28.2°E    = 11A0000 ( 28.2 * 10 = 282 =  0x11A )
# Hot Bird 13.0°E =  820000 ( 13.0 * 10 = 130 =   0x82 )
#
# use picons of Astra 19.2..E only
NAMESPACE="C00000"
# use picons of Astra 19.2..E and Hot Bird 13.0..E
# NAMESPACE="C00000 820000"
#
# use all available picons when NAMESPACE is unset

# extract name of archive from web listing
FILE="`curl -s "$URL/?dir=$DIR" | sed -e "/$TYPE/!d" -e "/symlink/!d" \
                                      -e "s|<[^>]*>||g" -e "s|[[:blank:]]||g"`"
# download compressed picon archive file
echo "Downloading $FILE from $URL/$DIR/"
curl "$URL/$DIR/$FILE" > "/tmp/$FILE" || exit 1

# extract archive file
tar xfJ "/tmp/$FILE" -C /tmp || exit 2
rm -fr "/tmp/$FILE" "/tmp/picons" "/tmp/picons.xyz"
# rename archive directory
mv "/tmp/`echo $FILE | sed -e 's|\.symlink\.tar\.xz||'`" "/tmp/picons.xyz"

# create destination directory
DESTDIR="/storage/picons"
[ -e "$DESTDIR" ] && mv "$DESTDIR" "$DESTDIR.old-$$"
mkdir "$DESTDIR" || exit 3

if [ ! -z "$NAMESPACE" ]; then
    # move only symlinks on defined namespaces
    for OP in "$NAMESPACE"; do
        mv /tmp/picons.xyz/*_"$OP"_0_0_0.png "$DESTDIR"
    done
    # copy all SNP files of choosen symlinks
    mkdir "$DESTDIR/logos"
    find "$DESTDIR" -name *.png | while read LINK; do
        SNP="`ls -l $LINK | sed -e 's|^.*logos/||'`"
        cp -fp "/tmp/picons.xyz/logos/$SNP" "$DESTDIR/logos"
    done
else
    # move everything to destination directory
    mv /tmp/picons.xyz/* "$DESTDIR"
fi
chmod -R g-w "$DESTDIR"

# clean up
rm -fr /tmp/picons.xyz

# end of script.
