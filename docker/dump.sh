#!/bin/bash

# env vars (mainly for convienience)
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

#
# validate all env vars have been provided and error on missing env vars
#

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

#
# Create ~/.my.cnf to avoid passing password on command line
#

echo "[mysqldump]" > ~/.my.cnf
echo "user=$DB_USER" >> ~/.my.cnf
echo "password=$DB_PASS" >> ~/.my.cnf

# timestamp option

if [[ $TIMESTAMP == "date" ]]; then
	PREFIX=`date +%Y-%m-%d`_
fi

if [[ $ALL_DATABASES == "" ]]; then

	#
	# dump a single database
	#

	FILENAME=$PREFIX$DB_NAME.sql.bz2

	echo "Dumping database: $DB_NAME to $FILENAME"
	mysqldump --host="$DB_HOST" $DUMP_OPTIONS "$DB_NAME" | bzip2 $BZIP2_OPTIONS > "/data/$FILENAME"
	aws s3 cp "/data/$FILENAME" $AWS_BUCKET

else

	#
	# dump all databases
	#

	echo "Dumping all databases"
	databases=`mysql --host="${DB_HOST}" -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
	for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "$IGNORE_DATABASE" ]]; then
      
			FILENAME=$PREFIX$db.sql.bz2

			echo "Dumping database: $db to $FILENAME"
			mysqldump --host="$DB_HOST" $DUMP_OPTIONS "$db" | bzip2 $BZIP2_OPTIONS > "/data/$FILENAME"
			aws s3 cp "/data/$FILENAME" $AWS_BUCKET
			echo ""

    fi
	done

fi

echo "Dump completed"
