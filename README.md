# kube-mysqldump-s3
Backup MySQL/MariaDB databases using Docker and/or Kubernetes cronjobs to/from AWS S3

## Features

- dump a single or multiple databases
- databases are dumped into separate files
- dump files are optionally timestamped
- dumps are bzip2 compressed
- exclude a database from the dump


## Usage

### Docker only (without k8s)

#### Configure env vars

*Database configuration*

Create a file ```config.env``` with the following environment variables.

```
DB_HOST=10.0.0.11
DB_USER=root
DB_PASS=
DB_NAME=mysql
DB_OPTIONS=-add-drop-table --add-locks --dump-date --events --routines --master-data=2
ALL_DATABASES=
IGNORE_DATABASE=
AWS_BUCKET=s3://
```

Refer to: [mysqldump docs](https://mariadb.com/kb/en/library/mysqldump/) for guidance on DB_OPTIONS


*AWS configuration*


[AWS CLI Environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)

- AWS_ACCESS_KEY_ID – Specifies an AWS access key associated with an IAM user or role.
- AWS_SECRET_ACCESS_KEY – Specifies the secret key associated with the access key. This is essentially the "password" for the access key.
- AWS_DEFAULT_REGION – Specifies the [AWS Region](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration-region) to send the request to.


*Dump a database into the current folder*

```
docker run --rm -v $PWD:/data --env-file config.env --name mysqldump-s3 recipedude/kube-mysqldump-s3:latest
```

## Environment variables

- `ALL_DATABASES` - when set to ```yes``` all databases will be dumped; except mysql, information_schema, performance_schema and, ```IGNORE_DATABASE``` (if set).  Leave empty and define ```DB_NAME``` to dump a single database.  Either ```ALL_DATABASES``` or ```DB_NAME``` must be defined.
- `BZIP2_OPTIONS` - options to pass into the bzip2 compression e.g. ```-v -f``` will show compression stats and overwrite files that exist (optional)
- `DB_HOST` - hostname of the mysql or mariadb database server (required)
- `DB_USER` - database username (required)
- `DB_PASS` - database password (optional)
- `DB_NAME` - dump a single database, ```ALL_DATABASES``` must be empty when using this variable. Either ```ALL_DATABASES``` or ```DB_NAME``` must be defined.
- `DUMP_OPTIONS` - options to pass to the mysqldump command line. e.g. ```--add-drop-table --add-locks --dump-date --events --routines --single-transaction --master-data=2``` Refer to: [mysqldump docs](https://mariadb.com/kb/en/library/mysqldump/) for more options (optional)
- `IGNORE_DATABASE` - database to ignore. Only functional when ```ALL_DATABASES``` is not empty. (optional)
- ```TIMESTAMP``` - set to ```date``` to prefix dump filenames with date in the format: YYYY-MM-DD (optional)
- ```AWS_ACCESS_KEY_ID``` - AWS S3 Access Key (required)
- ```AWS_SECRET_ACCESS_KEY``` - AWS S3 Secret Key (required)
- ```AWS_DEFAULT_REGION``` - AWS Region e.g. ```us-east-1``` (required)
- ```AWS_BUCKET``` - AWS S3 bucket to copy the dump files to in URI format e.g. ```s3://my-backups```




