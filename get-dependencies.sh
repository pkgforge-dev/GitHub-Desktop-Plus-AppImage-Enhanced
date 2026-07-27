#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	git-lfs		   \
	gnome-keyring  \
	libcurl-gnutls \
	pre-commit

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package github-desktop-bin

# If the application needs to be manually built that has to be done down here
echo "Getting app..."
echo "---------------------------------------------------------------"
case "$ARCH" in # they use ARM64 for the deb links
	x86_64)  deb_arch=x86_64;;
	aarch64) deb_arch=arm64;;
esac
DEB_LINK=$(wget -qO- https://api.github.com/repos/pol-rivero/github-desktop-plus/releases | grep -Po 'https://[^"]+'$deb_arch'\.deb' | head -n 1)
echo "$DEB_LINK" | awk -F'/' '{gsub(/^v/, "", $(NF-1)); print $(NF-1); exit}' > ~/version
if ! wget --retry-connrefused --tries=30 "$DEB_LINK" -O /tmp/app.deb 2>/tmp/download.log; then
	cat /tmp/download.log
	exit 1
fi

mkdir -p ./AppDir/bin
ar xvf /tmp/app.deb
bsdtar -xvf ./data.tar.zst
rm -f ./*.zst
rm -rf ./usr/share/doc
mv -v ./usr/lib/desktop-plus/* ./AppDir/bin
cp ./usr/share/icons/hicolor/256x256/apps/gh-desktop-plus.png ./AppDir/.DirIcon
mv -v ./usr/share/icons/hicolor/256x256/apps/gh-desktop-plus.png ./usr/share/applications/desktop-plus.desktop ./AppDir
