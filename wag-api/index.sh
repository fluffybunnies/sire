# @todo: move most of this into wagapi/install.sh

. ../secrets

# modules
../_common/nginx.sh
../_common/php.sh


# laravel needs this...
/usr/bin/apt-get -y install php5-mcrypt
service php5-fpm restart


# nginx conf
. ./nginx.sh


# install repo
install_repo "$installDir" "$gitRepo"
if [ -f "$installDir/install.sh" ]; then
	echo "running repo's install.sh"
	eval "$installDir/install.sh" -r
fi


# @todo: move this to wagapi/install.sh
cd "$installDir"
/usr/bin/curl -sS https://getcomposer.org/installer | /usr/bin/php
/usr/bin/php composer.phar install
# also maybe: php artisan migrate


#gitsync_cron "$installDir" "master"

