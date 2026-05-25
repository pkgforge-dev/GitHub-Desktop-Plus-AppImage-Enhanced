#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export STARTUPWMCLASS=github-desktop-plus
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1

# Deploy dependencies
quick-sharun ./AppDir/bin/* \
  /usr/bin/git-lfs \
  /usr/bin/gnome* \
  /usr/lib/gnome-keyring/devel/gkm*.so* \
  /usr/lib/pkcs11/gnome*.so* \
  /usr/lib/security/pam*.so* \
  /usr/bin/secret-tool \
  /usr/lib/libsecret*.so* \
  /usr/lib/libcurl*.so*

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
