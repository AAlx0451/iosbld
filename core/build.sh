#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

BASE_DIR=$(dirname "$SCRIPT_DIR")

if [ -z "$1" ]; then
    echo "Usage: $0 <package_name>"
    exit 1
fi

PACKAGE_NAME=$1
PACKAGE_FILE="$BASE_DIR/packages/$PACKAGE_NAME.pak"

if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Error: Package '$PACKAGE_NAME' not found at $PACKAGE_FILE"
    exit 1
fi

source "$BASE_DIR/global/global.pak"
source "$PACKAGE_FILE"

echo "--- Running prerequisite checks for $PACKAGE ---"
eval "$TESTS"
if [ $? -ne 0 ]; then
    echo "!!! Prerequisite checks failed. Aborting."
    exit 1
fi
echo "--- Checks passed ---"

BUILD_DIR="/tmp/build/$PACKAGE"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
echo "--- Created build directory at $BUILD_DIR ---"

echo "--- Downloading from $LINK ---"

curl -sSL "$LINK" | tar -xzv -C "$BUILD_DIR" --strip-components=1

cd "$BUILD_DIR"
echo "--- Starting build in `pwd` ---"

./configure --prefix="$PREFIX" $CONFIGURE_FLAGS
make $MAKE_FLAGS
make install

echo "--- Build successful for $PACKAGE ---"
