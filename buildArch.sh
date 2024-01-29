#!/bin/bash

#install some packages
apt-get update
apt-get install -y --no-install-recommends sed unzip wget

#clean up after ourselves
apt-get clean

#download and unzip bootstrap for correct release
mkdir bootstrap
case "$1" in
  x86)
      wget https://github.com/termux/termux-packages/releases/latest/download/bootstrap-i686.zip
      unzip -d bootstrap bootstrap-i686.zip
      ;;
  arm)
      wget https://github.com/termux/termux-packages/releases/latest/download/bootstrap-arm.zip
      unzip -d bootstrap bootstrap-arm.zip
      ;;
  x86_64)
      wget https://github.com/termux/termux-packages/releases/latest/download/bootstrap-x86_64.zip
      unzip -d bootstrap bootstrap-x86_64.zip
      ;;
  arm64)
      wget https://github.com/termux/termux-packages/releases/latest/download/bootstrap-aarch64.zip
      unzip -d bootstrap bootstrap-aarch64.zip
      ;;
  *)
      echo "unsupported architecture"
      exit
      ;;
esac

mkdir -p release
mkdir -p rootfs
mv bootstrap rootfs/usr
cd rootfs/usr
sed -i 's/←/ /g' SYMLINKS.txt
sed -i 's/^/ln -s /g' SYMLINKS.txt
bash SYMLINKS.txt
rm SYMLINKS.txt
cd ..
mkdir home
tar -czvf ../release/$1-rootfs.tar.gz .
cd ..
mkdir -p release/assets
cp assets/all/* release/assets/
rm release/assets/assets.txt
tar -czvf release/$1-assets.tar.gz -C release/assets/ .
for f in $(ls release/assets/); do echo "$f $(date +%s -r release/assets/$f) $(md5sum release/assets/$f | awk '{ print $1 }')" >> release/$1-assets.txt; done
rm -rf release/assets
