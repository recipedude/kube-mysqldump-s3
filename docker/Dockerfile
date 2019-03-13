FROM alpine:3.8

RUN apk -v --update add --no-cache \
			bash \
			bzip2 \
			groff \
			less \
			mailcap \
			mariadb-client \
			openssh-client \
			python \
			py-pip \
			&& \
			pip install --upgrade pip && \
			pip install --upgrade awscli==1.14.5 s3cmd==2.0.1 python-magic && \
			apk -v --purge del py-pip && \
    	rm -f /var/cache/apk/* 

COPY dump.sh /
COPY import.sh /

VOLUME /data

ENTRYPOINT ["/dump.sh"]
