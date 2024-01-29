#!/bin/bash

FLUTTER_VERSION=$(cat flutter_version)
FLUTTER_TAR_URL="https://flutter.dev/docs/get-started/install/linux"

# Download and install Flutter
curl -L "https://flutter.dev/flutter_$FLUTTER_VERSION-linux-x64.tar.xz" -o flutter.tar.xz
tar xf flutter.tar.xz
export PATH="$PATH:pwd/flutter/bin"