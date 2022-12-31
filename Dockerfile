FROM alpine:edge

ARG VERSION_INFO=
LABEL org.opencontainers.image.authors   = "Nigel Kukard <nkukard@conarx.tech>"
LABEL org.opencontainers.image.version   = "edge"
LABEL org.opencontainers.image.base.name = "docker.io/library/alpine:edge"


RUN set -ex; \
	true "Bash"; \
	apk add --no-cache bash; \
	true "Supervisord"; \
	apk add --no-cache py3-setuptools; \
	apk add --no-cache supervisor; \
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
	mkdir /docker-healthcheck.d; \


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
COPY tests.d/99-healthcheck.sh /docker-entrypoint-tests.d/99-healthcheck.sh
RUN set -ex; \
		chown root:root \
			/etc/supervisor/conf.d/crond.conf \
			/docker-entrypoint-tests.d/50-crond.sh \
			/docker-entrypoint-tests.d/99-healthcheck.sh; \
		chmod 0644 \
			/etc/crontabs/root \
			/etc/supervisor/conf.d/crond.conf; \

		chmod 0755 \
			/docker-entrypoint-tests.d/50-crond.sh \
			/docker-entrypoint-tests.d/99-healthcheck.sh

# Entrypoint & health checks
COPY docker-entrypoint /usr/local/sbin/
COPY docker-healthcheck /usr/local/sbin/
RUN set -ex; \
		chown root:root \
			/usr/local/sbin/docker-entrypoint \
			/usr/local/sbin/docker-healthcheck; \
		chmod 750 \
			/docker-entrypoint-pre-init-tests.d \
			/docker-entrypoint-pre-init.d \
			/docker-entrypoint-init.d \
			/docker-entrypoint-pre-exec.d \
			/docker-entrypoint-tests.d \
			/docker-healthcheck.d; \
		chmod 0755 \
			/usr/local/sbin/docker-entrypoint \
			/usr/local/sbin/docker-healthcheck

ENTRYPOINT ["docker-entrypoint"]

HEALTHCHECK CMD docker-healthcheck
