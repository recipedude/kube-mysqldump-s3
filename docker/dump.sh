#!/bin/bash


ALL_DATABASES=${ALL_DATABASES}
BZIP2_OPTIONS=${BZIP2_OPTIONS}
DB_HOST=${DB_HOST}
DB_USER=${DB_USER}
DB_PASS=${DB_PASS}
DB_NAME=${DB_NAME}
DUMP_OPTIONS=${DUMP_OPTIONS}
IGNORE_DATABASE=${IGNORE_DATABASE}
MISSING=false
TIMESTAMP=${TIMESTAMP}
AWS_BUCKET=${AWS_BUCKET}

if [[ $DB_HOST == "" ]]; then
	echo "Missing DB_HOST"
	MISSING=true
fi

if [[ $DB_USER == "" ]]; then
	echo "Missing DB_USER"
	MISSING=true
fi

# if [[ $DB_PASS == "" ]]; then
# 	echo "Missing DB_PASS"
# 	MISSING=true
# fi

if [[ $ALL_DATABASES == "" ]]; then
	if [[ $DB_NAME == "" ]]; then
		echo "Missing DB_NAME and ALL_DATABASES has not been set"
		MISSING=true
	fi
fi

if [[ ${AWS_ACCESS_KEY_ID} == "" ]]; then
		echo "Missing AWS_ACCESS_KEY_ID"
		MISSING=true
fi

if [[ ${AWS_SECRET_ACCESS_KEY} == "" ]]; then
		echo "Missing AWS_SECRET_ACCESS_KEY"
		MISSING=true
fi

if [[ ${AWS_DEFAULT_REGION} == "" ]]; then
		echo "Missing AWS_DEFAULT_REGION"
		MISSING=true
fi

if [[ ${AWS_BUCKET} == "" ]]; then
		echo "Missing AWS_BUCKET"
		MISSING=true
fi

if [[ $MISSING == "true" ]]; then
	echo "Need to provide missing env vars, exiting now."
	exit 1
fi



echo "[msyqldump]\nuser=$DB_USER\npassword=$DB_PASSWORD\n" > ~/.my.cnf


if [[ $TIMESTAMP == "date" ]]; then
	PREFIX=`date +%Y-%m-%d`
fi

if [[ $ALL_DATABASES == "" ]]; then

	FILENAME=$PREFIX\_$DB_NAME.sql.bz2

	echo "Dumping database: $DB_NAME to $FILENAME"
#	CMD="mysqldump --host="$DB_HOST" $DUMP_OPTIONS "$DB_NAME" > "/data/$FILENAME""
#	echo $CMD
	mysqldump --host="$DB_HOST" $DUMP_OPTIONS "$DB_NAME" | bzip2 $BZIP2_OPTIONS > "/data/$FILENAME"

	aws s3 cp "/data/$FILENAME" $AWS_BUCKET

else

	echo "Backing up all databases"
	databases=`mysql --host="${DB_HOST}" -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
	for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "$IGNORE_DATABASE" ]]; then
      
			FILENAME=$PREFIX\_$db.sql.bz2

			echo "Dumping database: $db to $FILENAME"
#			CMD="mysqldump --host="$DB_HOST" $DUMP_OPTIONS "$db" > "/data/$FILENAME""
#			echo $CMD
			mysqldump --host="$DB_HOST" $DUMP_OPTIONS "$db" | bzip2 $BZIP2_OPTIONS > "/data/$FILENAME"

			# to do: upload to S3

			aws s3 cp "/data/$FILENAME" $AWS_BUCKET

			echo ""

    fi
done


fi

