var path = require('path')
,cp = require('child_process')
,fs = require('fs')
,argv = require('optimist').argv
,s3cmd = require('./s3cmd')
,tmpDir = '/tmp/sire-dbbak/'
;

var bucket = argv.b || argv.bucket
,dbName = argv.d || argv.database
;

if (!bucket || !dbName) throw "db and bucket required";

fs.mkdir(tmpDir,function(err){
  if (err && err.code != 'EEXIST')
    return console.log(err);
  var fn = dbName+'.'+Date.now()+'.sql.gz'
  ,path = tmpDir+fn;
  cp.exec('mysqldump --opt -hlocalhost -uroot '+dbName+' | gzip > '+path,function(err){
    if (err)
      return console.log(err);
    s3cmd(['put','s3://'+path.join([bucket,fn])],function(err){
      if (err)
        console.log('failed to push '+path+' to s3',err);
      else
        console.log('successfully pushed '+path+' to s3');
      fs.unlink(path,function(err){
        if (err)
          return console.log('failed to clean up');
      });
    });
  });
});

