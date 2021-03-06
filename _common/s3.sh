# put and get from s3 like a champ

apt-get install --assume-yes s3cmd

if [ ! -f "/root/.s3cfg" ]; then

cat > /root/.s3cfg <<FILE
[default]
access_key = $awsAccessKey
bucket_location = US
cloudfront_host = cloudfront.amazonaws.com
cloudfront_resource = /2010-07-15/distribution
default_mime_type = binary/octet-stream
delete_removed = False
dry_run = False
encoding = UTF-8
encrypt = False
follow_symlinks = False
force = False
get_continue = False
gpg_command = /usr/bin/gpg
gpg_decrypt = %(gpg_command)s -d --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_encrypt = %(gpg_command)s -c --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_passphrase = 
guess_mime_type = True
host_base = s3.amazonaws.com
host_bucket = %(bucket)s.s3.amazonaws.com
human_readable_sizes = False
list_md5 = False
log_target_prefix = 
preserve_attrs = True
progress_meter = True
proxy_host = 
proxy_port = 0 
recursive = False
recv_chunk = 4096
reduced_redundancy = False
secret_key = $awsAccessSecret
send_chunk = 4096
simpledb_host = sdb.amazonaws.com
skip_existing = False
socket_timeout = 10
urlencoding_mode = normal
use_https = True
verbosity = WARNING
FILE

echo "s3cmd configured";

else

echo "s3cmd already configured"

fi


# temp hack for problem i havent solved yet where s3cmd is looking in home/ubuntu even though i sudo
if [ -d /home/ubuntu ]; then
	sudo cp /root/.s3cfg /home/ubuntu/
fi




