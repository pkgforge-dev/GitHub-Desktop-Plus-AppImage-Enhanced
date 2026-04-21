#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
#pacman -Syu --noconfirm \
    

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package github-desktop-bin

# If the application needs to be manually built that has to be done down here
echo "Getting app..."
echo "---------------------------------------------------------------"
case "$ARCH" in # they use AMD64 and ARM64 for the deb links
	x86_64)  deb_arch=amd64;;
	aarch64) deb_arch=arm64;;
esac
DEB_LINK=$(wget https://api.github.com/repos/shiftkey/desktop/releases/latest -O - \
grep "browser_download_url" | \
    grep "$deb_arch.deb" | \
    head -n 1 | \
    cut -d '"' -f 4)
#      | sed 's/[()",{} ]/\n/g' | grep -o -m 1 "https.*-$deb_arch-*.deb")
echo "$DEB_LINK" | awk -F'/' '{gsub(/^v/, "", $(NF-1)); print $(NF-1); exit}' > ~/version
if ! wget --retry-connrefused --tries=30 "$DEB_LINK" -O /tmp/app.deb 2>/tmp/download.log; then
	cat /tmp/download.log
	exit 1
fi

mkdir -p ./AppDir/bin
ar xvf /tmp/app.deb
tar -xvf ./data.tar.xz
rm -f ./*.xz
rm -rf ./usr/share/doc
mv -v ./usr/lib/github-desktop/* ./AppDir/bin
cp ./usr/share/icons/hicolor/256x256/apps/github-desktop.png ./AppDir/.DirIcon
mv -v ./usr/share/icons/hicolor/256x256/apps/github-desktop.png ./usr/share/applications/github-desktop.desktop ./AppDir
