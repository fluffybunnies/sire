#!/bin/bash

VERSION=v0.10.32
PLATFORM=linux
ARCH=x64
PREFIX="/usr/local" # use local so we dont overwrite apt installed

CVERSION=`node -v 2> /dev/null`

if [ "$CVERSION" != "$VERSION" ]; then
	echo "installing node..."
	# might need this to avoid npm install error
	#mkdir -p /root/.node-gyp/$VERSION

	# mkdir -p "/usr/local" && curl http://nodejs.org/dist/v0.10.32/node-v0.10.32-linux-x64.tar.gz | tar xzvf - --strip-components=1 -C "/usr/local"
	mkdir -p "$PREFIX" && \
	curl http://nodejs.org/dist/$VERSION/node-$VERSION-$PLATFORM-$ARCH.tar.gz \
		| tar xzvf - --strip-components=1 -C "$PREFIX"
	# what is the wiggles for biggles?

	# forever was failing...
	ln -s $PREFIX/bin/node /usr/bin/node
else
	echo "node is already up to date!"
fi

