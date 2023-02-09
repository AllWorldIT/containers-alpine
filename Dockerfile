# Copyright (c) 2022-2023, AllWorldIT.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.


FROM alpine:edge

ARG VERSION_INFO=
LABEL org.opencontainers.image.authors   = "Nigel Kukard <nkukard@conarx.tech>"
LABEL org.opencontainers.image.version   = "edge"
LABEL org.opencontainers.image.base.name = "docker.io/library/alpine:edge"


RUN set -eux; \
	true "Upgrade Alpine"; \
	apk upgrade --no-cache; \
	true "Bash"; \
	apk add --no-cache bash; \
	true "Supervisord"; \
	apk add --no-cache py3-setuptools; \
	apk add --no-cache supervisor; \
	true "Syslog-ng"; \
	apk add --no-cache syslog-ng; \
	true "Cron"; \
	rm -rfv \
		/etc/crontabs/* \
		/etc/periodic; \
	apk add --no-cache cronie; \
	true "Security - minimum version requirements"; \
	apk list --no-cache 2>&1 | grep libssl3; apk add --no-cache "libssl3>3.0.8"; \
	true "Cleanup"; \
	rm -f /var/cache/apk/*; \
	mkdir -p \
		/usr/local/share/flexible-docker-containers/lib \
		/usr/local/share/flexible-docker-containers/pre-init-tests.d \
		/usr/local/share/flexible-docker-containers/pre-init.d \
		/usr/local/share/flexible-docker-containers/init.d \
		/usr/local/share/flexible-docker-containers/pre-exec.d \
		/usr/local/share/flexible-docker-containers/tests.d \
		/usr/local/share/flexible-docker-containers/healthcheck.d


# Supervisord
COPY etc/supervisor/supervisord.conf /etc/supervisor/
RUN set -eux; \
		chown root:root \
			/etc/supervisor/supervisord.conf; \
		chmod 0644 \
			/etc/supervisor/supervisord.conf


# Syslog-ng (for logging of syslog to stdout/stderr to docker)
COPY etc/syslog-ng/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
COPY etc/supervisor/conf.d/syslog-ng.conf /etc/supervisor/conf.d/syslog-ng.conf
RUN set -eux; \
	chown root:root \
		/etc/syslog-ng/syslog-ng.conf; \
	chmod 0644 \
		/etc/syslog-ng/syslog-ng.conf


# Crond
COPY etc/supervisor/conf.d/crond.conf.disabled /etc/supervisor/conf.d/
COPY usr/local/share/flexible-docker-containers/tests.d/40-crond.sh /usr/local/share/flexible-docker-containers/tests.d
COPY usr/local/share/flexible-docker-containers/pre-init-tests.d/40-crond.sh /usr/local/share/flexible-docker-containers/pre-init-tests.d
COPY usr/local/share/flexible-docker-containers/pre-init.d/40-crond.sh /usr/local/share/flexible-docker-containers/pre-init.d
COPY usr/local/share/flexible-docker-containers/healthcheck.d/40-crond.sh /usr/local/share/flexible-docker-containers/healthcheck.d


# Install Flexible Docker Containers
COPY usr/local/sbin/fdc /usr/local/sbin/
COPY usr/local/share/flexible-docker-containers/lib/logging.sh /usr/local/share/flexible-docker-containers/lib
COPY usr/local/share/flexible-docker-containers/tests.d/90-healthcheck.sh /usr/local/share/flexible-docker-containers/tests.d
RUN set -eux; \
	true "Flexible Docker Containers"; \
	if [ -n "$VERSION_INFO" ]; then echo "$VERSION_INFO" >> /.VERSION_INFO; fi; \
	true "Permissions"; \
	chown root:root \
		/usr/local/sbin/fdc \
		/usr/local/share/flexible-docker-containers/*; \
	chmod 0755 \
		/usr/local/sbin/fdc \
		/usr/local/share/flexible-docker-containers/*; \
	fdc set-perms


ENTRYPOINT ["fdc", "start"]

HEALTHCHECK CMD fdc healthcheck
