# nginx conf

nginxBackend="127.0.0.1:9000"

cat > /etc/nginx/sites-available/migrate-wordpress <<FILE
server {
	listen 80;
	server_name fffdev-migrate-wordpress.com;
	return 301 http://www.fffdev-migrate-wordpress.com\$request_uri;
}
server {
	listen 80;

	server_name www.fffdev-migrate-wordpress.com local.fffdev-migrate-wordpress.com;
	root /var/www/migrate-wordpress/web;
	autoindex off;

	access_log /var/log/nginx/migrate-wordpress_access_log.log;

	gzip on; # use gzip compression
	gzip_min_length 1100;
	gzip_buffers 4 8k; 
	gzip_proxied any; # enable proxy for the fcgi requests
	gzip_types text/plain text/css application/x-javascript text/javascript application/json; 

	# pass php to fastcgi
	location ~ \.php\$ {
		fastcgi_index index.php;
		include /etc/nginx/fastcgi_params;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		if (-e \$request_filename) { # check if requested path exists
			fastcgi_pass $nginxBackend;
		}
	}

	location / {
		# set expire headers for assets
		if (\$request_uri ~* "\.(ico|css|js|gif|jpe?g|png)\$") {
			expires max;
		}
		include /etc/nginx/fastcgi_params;
		fastcgi_param SCRIPT_FILENAME \$document_root/index.php;
		fastcgi_param SCRIPT_NAME /index.php;
		# pass nonexistants to index.php
		if (!-f \$request_filename) {
			fastcgi_pass $nginxBackend;
			break;
		}
	}
}
FILE
rm /etc/nginx/sites-enabled/default 2> /dev/null
ln -f /etc/nginx/sites-available/migrate-wordpress /etc/nginx/sites-enabled/migrate-wordpress

/etc/init.d/nginx reload
