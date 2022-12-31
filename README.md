# Container Information

This is the Conarx Containers Alpine Linux base image, it is built specifically with re-use in mind along with flexible
initialization, unit testing and health checks.


Notable software included:

- bash
- supervisord
- crond

The environment is dropped prior to executing Supervisord to prevent leaking any initialization information. If environment variables are required a `docker-entrypoint-pre-init.d` should be used to write the variables required to a safe location and a script added (eg. `/usr/local/sbin/start-<DAEMON>`) which sources this and runs the daemon.


# Environment Variables


## CI

When set to any value will trigger unit testing of the container. The difference to the normal execution path is supervisord will
be executed along-side scripts being sourced in from `docker-entrypoint-tests.d`.


## DISABLE_ENTRYPOINT

Setting this environment variable will disable the normal entrypoint if used with a CMD override.


## DISABLE_SUPERVISORD

If set, this environment variable will disable supervisord when used with a CMD override.



# Stackable Script Directories

All scripts are processed `source` under `set -e` which will result in any failure being propagated to prevent container start.

Shell scripts should use `#!/bin/bash` as the shebang and be set executable to allow for easy debugging.

Scripts are executed in plain `sort` order and should be prefixed with a `XX-` number.


## Directory: /docker-entrypoint-pre-init-tests.d

Files will be sourced in before `/docker-entrypoint-pre-init.d` and the purpose of which is to populate or create configurations
required for unit testing.


## Directory: /docker-entrypoint-pre-init.d

Files will be sourced in before `/docker-entrypoint-init.d`, these are rarely if ever used in our official images but can be used
to alter the environment before `/docker-entrypoint-init.d`.


## Directory: /docker-entrypoint-init.d

This directory is used to initialize the container environment, prepare any data and/or permissions required for container startup
and execute any upgrade steps required.


## Directory: /docker-entrypoint-pre-exec.d

Files will be sourced in after container initialization done in `/docker-entrypoint-init.d`, the purpose of this directory is meant
for adjusting an official container after initialization and before startup.

This is the last stage before startup. After any scripts in this directory are sourced in control will either be passed entirely
to supervisord or, in the case of unit testing, supervisord will be started and execution will continue in
`/docker-entrypoint-tests.d`.


## Directory: /docker-entrypoint-tests.d

Files in this directoy will be sourced in when the environment variable `CI` is set, this happens after supervisord is started, but
before any services may be up.

It is a wise idea to loop and check for service startup before starting unit testing of the service.

As the last step in unit testing `docker-healthcheck` will be executed to ensure the final state of the container passes a health
check.


## Directory: /docker-healthcheck.d

Files will be sourced in when `docker-healthcheck` is run as part of `HEALTHCHECK`. The purpose of this directory
is to add any health checks in a stacked container environment.

Consider outputting a usable message when a healthcheck fails to help with debugging.
