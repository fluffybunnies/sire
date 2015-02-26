
startpwd=`pwd`

. ../secrets

# modules
../_common/nginx.sh
../_common/php.sh
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh


# nginx conf
. ./nginx.sh


# install repo
install_repo "$installDir" "$gitRepo"


# deploy hook service
#IP=`public_ip`
#echo '[{"repo":"'$installDir'","branch":"master"}]' > $installDir'/hooky.json'
#cd $startpwd/hooky
#npmi
#forever_run "./index.js -t $githubHookAuthToken -a $IP -c $installDir/hooky.json"
#cd $startpwd

# until i fix multiple github hooks issue...
gitsync_cron "$installDir" "master"


# test cname
localhost_add_cname 'local.alechulce.com'


# rotate logs
logrotate_log=/var/log/logrotate_alechulce.log
rotate_logs 'alechulce' "`accessLogLocation alechulce`" "`errorLogLocation alechulce`" "$logrotate_log" -o "$logrotate_log"
rotate_logs 'alechulce-logrotate' "$logrotate_log" -o "$logrotate_log" -t '@weekly'