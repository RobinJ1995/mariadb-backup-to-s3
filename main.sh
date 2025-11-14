#!/bin/bash
set -xe

timestamp=`date +%s`
test ! -z "$timestamp"

test ! -z "$DB_HOST"
test ! -z "$DB_NAME"
test ! -z "$DB_USERNAME"

set +x
test ! -z "$DB_PASSWORD"
export MYSQL_PWD="$DB_PASSWORD"
set -x

test ! -z "$S3_BUCKET"

output_filename="${DB_HOST}_${DB_NAME}_${timestamp}.sql"

echo '== Backup =='
mysqldump -h "$DB_HOST" -u "$DB_USERNAME" "$DB_NAME" > "$output_filename"
test -f "$output_filename"
test -s "$output_filename"

echo '== Compress =='
zstd -6 "$output_filename"
compressed_output_filename="${output_filename}.zst"
test -f "$compressed_output_filename"
test -s "$compressed_output_filename"

echo '== Upload =='
if [ -z $S3_ENDPOINT ]
then
  s3_cmd='aws s3'
else
  s3_cmd="aws s3 --endpoint=${S3_ENDPOINT}"
fi

$s3_cmd cp "$compressed_output_filename" "s3://${S3_BUCKET}/"
