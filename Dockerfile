FROM alpine:edge

ARG VERSION_INFO=
LABEL maintainer="Nigel Kukard <nkukard@lbsd.net>"

RUN set -ex; \
	true "Bash"; \
	apk add --no-cache bash; \
	true "Supervisord"; \
	apk add --no-cache supervisor; \
	true "Postfix"; \
	apk add --no-cache postfix; \
	true "Versioning"; \
	if [ -n "$VERSION_INFO" ]; then echo "$VERSION_INFO" >> /.VERSION_INFO; fi; \
	true "Cleanup"; \
	rm -f /var/cache/apk/*; \
	true "Cron"; \
	mkdir -p /etc/periodic/5min; \
	true "Scriptlets"; \
	mkdir /docker-entrypoint-pre-init-tests.d; \
	mkdir /docker-entrypoint-pre-init.d; \
	mkdir /docker-entrypoint-init.d; \
	mkdir /docker-entrypoint-pre-exec.d; \
	mkdir /docker-entrypoint-tests.d; \
	chmod 750 /docker-entrypoint-pre-init-tests.d; \
	chmod 750 /docker-entrypoint-pre-init.d; \
	chmod 750 /docker-entrypoint-init.d; \
	chmod 750 /docker-entrypoint-pre-exec.d; \
	chmod 750 /docker-entrypoint-tests.d


# Supervisord
COPY etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
RUN set -ex; \
		chown root:root \
			/etc/supervisor/supervisord.conf; \
		chmod 0644 \
			/etc/supervisor/supervisord.conf

# Crond
COPY etc/supervisor/conf.d/crond.conf /etc/supervisor/conf.d/crond.conf
COPY etc/crontabs/root /etc/crontabs/root
COPY tests.d/50-crond.sh /docker-entrypoint-tests.d/50-crond.sh
RUN set -ex; \
		chown root:root \
			/etc/supervisor/conf.d/crond.conf \
			/docker-entrypoint-tests.d/50-crond.sh; \
		chmod 0644 \
			/etc/supervisor/conf.d/crond.conf; \
		chmod 0755 \
			/docker-entrypoint-tests.d/50-crond.sh

# Postfix
COPY etc/supervisor/conf.d/postfix.conf.disabled /etc/supervisor/conf.d/postfix.conf.disabled
COPY init.d/50-postfix.sh /docker-entrypoint-init.d/50-postfix.sh
COPY pre-init-tests.d/50-postfix.sh /docker-entrypoint-pre-init-tests.d/50-postfix.sh
COPY tests.d/50-postfix.sh /docker-entrypoint-tests.d/50-postfix.sh
RUN set -ex; \
		chown root:root \
			/etc/supervisor/conf.d/postfix.conf.disabled \
			/docker-entrypoint-init.d/50-postfix.sh \
			/docker-entrypoint-pre-init-tests.d/50-postfix.sh \
			/docker-entrypoint-tests.d/50-postfix.sh; \
		chmod 0644 \
			/etc/supervisor/conf.d/postfix.conf.disabled; \
		chmod 0755 \
			/docker-entrypoint-init.d/50-postfix.sh \
			/docker-entrypoint-tests.d/50-postfix.sh

EXPOSE 25

# Entrypoint
COPY docker-entrypoint.sh /usr/local/sbin/
RUN set -ex; \
		chown root:root \
			/usr/local/sbin/docker-entrypoint.sh; \
		chmod 0755 \
			/usr/local/sbin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
