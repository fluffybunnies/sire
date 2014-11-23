#misc crontab functions

crontab_add(){
  search=$1
  line=$2
  if [ ! "$line" ]; then
    line=$search
  fi

  tmp=`mktemp`
  crontab -l | grep -v "$search" > $tmp
  echo "$line" >> $tmp
  crontab < $tmp 
  rm $tmp
}

crontab_remove(){
  search=$1
  tmp=`mktemp`
  crontab -l | grep -v "$search" > $tmp
  crontab < $tmp
  rm $tmp
}

crontab_clear(){
  tmp=`mktemp`
  crontab -l > $tmp
  mv $tmp $tmp"_cron";
  echo "" | crontab
  echo "crontab cleared tmp in "$tmp"_cron"
}

gitsync_cron(){
	dir=$1
	branch=$2
	key="gitsync_cron $dir $branch"
	cron="cd '$dir' && git fetch && git reset --hard HEAD && git checkout -f $branch && git pull origin $branch; git submodule update; sleep 15;"
	crontab_add "$key" "* * * * * echo '$key'; $cron $cron $cron $cron"
}

remote_config_add(){
  serverName=$1
  file=$2
  key=$3
  val=$4
  search=`ssh ubuntu@$serverName "sudo cat $file 2>&1 /dev/null | grep $key | head -n1"`
  if [ "$search" == "" ]; then
    ssh ubuntu@$serverName "echo 'export $key=\"$val\"' | sudo tee -a $file >> /dev/null"
  fi
}

localhost_add_cname(){
  cname=$1
  check=`cat /etc/hosts | grep "$cname" | head -n1`
  if [ "$check" == "" ]; then
    echo "127.0.0.1   $cname" >> /etc/hosts
  fi
}

gen_add_line_to_file(){
	file=$1
	search=$2
	line=$3
	perms=$4
  if [ ! "$line" ]; then
    line=$search
  fi
  if [ ! -f "$file" ]; then
  	echo "$file is not a file"
  else
  	echo "$file is a file"
  fi
	if [ ! -f "$file" ]; then
		touch $file
		if [ "$perms" != "" ]; then
			chmod "$perms" $file
		fi
	fi
  tmp=`mktemp`
  cat "$file" | grep -v "$search" > $tmp

  echo "$line" >> $tmp
  echo "$file < $tmp"
  cat "$tmp"

  "$file" < $tmp 
  rm $tmp
}

forever_is_running(){
  /usr/local/bin/forever list | grep "$1"
}

forever_run(){
  torun1=`everything_but $1`
  file=`first_arg $1`
  script=`realpath $file`
  torun=$script
  if [ "$torun1" != "" ]; then # necessary check to prevent extra space if no $torun
  	torun=$script" "$torun1
  fi
  dir=/root/sire # @todo: pass and use $sireDir

  crontab_add "$script" "* * * * * $dir/bin/angel.sh \"$torun\" >> /var/log/angel.log 2>&1"
  forever_stop "$script"

  echo `date`
  echo "torun1: $torun1"
  echo "file: $file"
  echo "script: $script"
  echo "torun: $torun"
  echo "dir: $dir"
  /usr/local/bin/forever start --spinSleepTime 1000 --minUptime 500 $torun
}

forever_stop(){
	#index=`forever_uid $1`
  index=`forever_uid $1` # was using index before, but had issues when stopping index 0
  if [ "$index" == "" ]; then
    echo "forever stop> $1 not running"
  else
  	/usr/local/bin/forever list
    /usr/local/bin/forever stop $index
  fi
}

forever_uid(){
	/usr/local/bin/forever list | grep $1 | awk '{print $3}' | sed -e 's/\[\|\]//g'
}

forever_index(){
  /usr/local/bin/forever list | grep $1 | awk '{print $2}' | sed -e 's/\[\|\]//g'
}

forever_logfile(){
  search=$1
  /usr/local/bin/forever --plain list | grep $search | grep -oP '\/root[^ ]+'
}

first_arg(){
  echo $1 
}

everything_but(){
  out=""
  a=0
  for arg in $@;
  do
    if [ "$a" == "0" ]; then
      a=1
    else
      out=$out" "$arg
    fi
  done
  echo $out
}

public_ip(){
  curl http://169.254.169.254/latest/meta-data/public-ipv4
}



