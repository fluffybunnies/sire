#!/bin/bash
# Ex: ./index.sh ace alechulce -na
# -na will skip installing basics

echo 'whoami: '`whoami`

aptUpdate=1
for arg in "$@"; do
	if [ "$arg" == '-na' ]; then
		aptUpdate=0
	fi
done


if [ -f /usr/bin/apt-get ]; then
	echo "we have apt-get"
	if [ $aptUpdate == 1 ]; then
		echo 'apt-get update...'
		apt-get update
		apt-get install --assume-yes curl build-essential
	fi
	apt-get --assume-yes install realpath
	export DEBIAN_FRONTEND=noninteractive # shhh!
fi


if [ "`which realpath`" == "" ]; then
	echo "we dont have realpath"
	realpath() {
		echo `cd "${1}";pwd`
	}
fi


refDir=`dirname $0`
refDir=`/usr/bin/realpath $refDir`
cd $refDir


if [ "$1" == "" ]; then
	echo "if you would like to deploy specific environment(s) please specify them as arguments"
else
	oneInvalid=0
	deployed=""
	for env in "$@"; do
		if [ "$env" == '-na' ]; then
			echo '.'
		elif [ -d "$env" ]; then
			./_common/deploy.sh "$refDir/$env"
			deployed=$deployed"$env "
		else
			echo "$env is not a valid deploy name"
			oneInvalid=1
		fi
	done
	if [ $oneInvalid == 1 ]; then
		ls -d */ | grep -v _common
		exit 1
	fi
	for env in $deployed; do
		echo "testing $env"
		if [ -f "$env"/test.sh ]; then
			./_common/test.sh "$refDir/$env" "$env"
			eCode=$?
			if [ "$eCode" != "0" ]; then
				echo "$env"/test.sh" failed: $eCode"
				exit 1
			fi
			echo "$env passed!"
		else
			echo "$env"/test.sh" does not exist"
		fi
	done
fi

