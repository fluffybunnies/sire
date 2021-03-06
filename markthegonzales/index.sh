
startpwd=`pwd`

. ../secrets

# modules
../_common/s3.sh
../_common/nginx.sh
../_common/php.sh
../_common/mysql.sh
../_common/nodejs.sh
../_common/forever.sh
../_common/s3dl.sh


# nginx conf
echo "nginx.sh..."
. ./nginx.sh


# install repo
install_repo "$installDir" "$gitRepo"


# wordpress
echo "create database if not exists $mysqlDb" | mysql -uroot
# we need this file to be there immediately
mkdir -p $installDir/web/wp-content/uploads/x
s3cmd get --skip-existing s3://$s3Bucket/wp-content/uploads/x/style.css $installDir/web/wp-content/uploads/x/style.css
# we may have a problem when s3 pulls down a directory that wasnt previously given permissions...
chown -R www-data $installDir/web/wp-content/uploads
chmod -R +w $installDir/web/wp-content/uploads
# fetch wordpress db
node ../_common/s3dl/bin/loadsql.js -d $mysqlDb -b $s3Bucket/sql


# secret configs
if [ -f $installDir/web/config.local.php ]; then
	rm $installDir/web/config.local.php
fi
gen_add_line_to_file "$installDir/web/config.local.php" '<?php' '<?php'
gen_add_line_to_file "$installDir/web/config.local.php" twitterAppKey "\$twitterAppKey='$twitterAppKey';"
gen_add_line_to_file "$installDir/web/config.local.php" twitterAppSecret "\$twitterAppSecret='$twitterAppSecret';"
if [ "$awsAccessKey" != "" ]; then
	gen_add_line_to_file "$installDir/web/config.local.php" awsAccessKey "\$awsAccessKey='$awsAccessKey';"
	gen_add_line_to_file "$installDir/web/config.local.php" awsAccessSecret "\$awsAccessSecret='$awsAccessSecret';"
	gen_add_line_to_file "$installDir/web/config.local.php" awsRegion "\$awsRegion='$awsRegion';"
fi
if [ "$googleAnalyticsId" != "" ]; then
	gen_add_line_to_file "$installDir/web/config.local.php" googleAnalyticsId "\$googleAnalyticsId='$googleAnalyticsId';"
fi


# test cname
localhost_add_cname 'local.markthegonzales.com'


#configure_hooky "$installDir" master $githubHookAuthToken 9998
# until i fix multiple github hooks issue...
gitsync_cron "$installDir" "master"


# backup sql
baksql_log=/var/log/markthegonzales_baksql.log
cron="0 2 * * * /usr/local/bin/node $sireDir/_common/s3dl/bin/baksql.js -d $mysqlDb -b $s3Bucket/sql >> $baksql_log 2>&1 #markthegonzales_bakSql"
crontab_add '#markthegonzales_bakSql' "$cron"


# s3 sync service
cd $sireDir/_common/s3dl
npmi
forever_run "$sireDir/_common/s3dl/index.js -d $installDir/web/wp-content/uploads -w /wp-content/uploads -b $s3Bucket/wp-content/uploads -p 9991,9900-9995,/etc/nginx/sites-available/markthegonzales"
cd $startpwd


# rotate logs
logrotate_log=/var/log/logrotate_markthegonzales.log
rotate_logs 'markthegonzales' "$baksql_log" "`accessLogLocation markthegonzales`" "`errorLogLocation markthegonzales`" -o "$logrotate_log"
rotate_logs 'markthegonzales-logrotate' "$logrotate_log" -o "$logrotate_log" -t '@weekly'

