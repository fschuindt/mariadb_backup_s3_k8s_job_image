#!/bin/bash

databases=`mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" --batch | tr -d "| " | grep -v Database`

aws configure set aws_access_key_id $S3_ACCESS_KEY_ID
aws configure set aws_secret_access_key $S3_SECRET_ACCESS_KEY
aws configure set default.region $S3_REGION
aws configure set region $S3_REGION --profile default

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "SAVING: $db"
        filename=`date +%Y-%m-%d_at_%H-%M-%S`_$db.sql
        mysqldump -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWORD --databases $db > $filename
        gzip $filename
        aws s3 cp $filename.gz $S3_DESTINATION/$filename.gz
    fi
done
