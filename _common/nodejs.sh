#!/bin/bash

VERSION=v0.10.26
PLATFORM=linux
ARCH=x64
PREFIX="/usr/local"

CVERSION=`node -v 2> /dev/null`

if [ "$CVERSION" != "$VERSION" ]; then
	# mkdir -p "/usr/local" && curl http://nodejs.org/dist/v0.10.26/node-v0.10.26-linux-x64.tar.gz | tar xzvf - --strip-components=1 -C "/usr/local"
  mkdir -p "$PREFIX" && \
  curl http://nodejs.org/dist/$VERSION/node-$VERSION-$PLATFORM-$ARCH.tar.gz \
    | tar xzvf - --strip-components=1 -C "$PREFIX"
  # what is the wiggles for biggles?
else
  echo "node is already up to date!"
fi

