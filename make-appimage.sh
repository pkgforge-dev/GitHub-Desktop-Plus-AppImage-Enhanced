#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/desktop-plus/desktop-plus/refs/heads/main/app/static/linux/logos/256x256.png
export STARTUPWMCLASS=desktop-plus
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export DEPLOY_PYTHON=1

# Deploy dependencies
quick-sharun ./AppDir/bin/* \
  /usr/bin/git-lfs \
  /usr/bin/gnome* \
  /usr/bin/pre-commit \
  /usr/bin/secret-tool \
  /usr/lib/gnome-keyring/devel/gkm*.so* \
  /usr/lib/pkcs11/gnome*.so* \
  /usr/lib/security/pam*.so* \
  /usr/lib/libsecret*.so* \
  /usr/lib/libcurl*.so*

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
quick-sharun --simple-test ./dist/*.AppImage
