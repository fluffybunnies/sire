
. ../secrets

../_common/forever.sh

if [ ! -f /usr/local/bin/node ]; then
	ln -s /usr/bin/node /usr/local/bin/node
fi

installDir=/var/www/platform-v2-lucky/current
#echo "githubHookAuthToken: $githubHookAuthToken"
configure_hooky $installDir develop $githubHookAuthToken 8013 $installDir/restart.sh
