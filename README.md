[![pipeline status](https://gitlab.conarx.tech/containers/alpine/badges/main/pipeline.svg)](https://gitlab.conarx.tech/containers/alpine/-/commits/main)

# Container Information

[Container Source](https://gitlab.conarx.tech/containers/alpine) - [GitHub Mirror](https://github.com/AllWorldIT/containers-alpine)

This is the Conarx Containers Alpine Linux base image, it is built specifically with re-use in mind along with flexible
initialization, unit testing and supports advanced health checks.

These additional container features we call Flexible Docker Containers.

Notable software included:

- bash
- cronie
- python
- supervisord
- syslog-ng

The environment is dropped prior to executing Supervisord to prevent leaking any initialization information. If environment
variables are required a `docker-entrypoint-pre-init.d` should be used to write the variables required to a safe location and a
script added (eg. `/usr/local/sbin/start-<DAEMON>`) which sources this and runs the daemon.

The reason we include syslog-ng is to capture any processes running that log to syslog and output that to the docker logs.

Cronie is included to allow us to run crontabs with a configurable user and time period, with the added benefit of a random delay.
It will be started 10 seconds after container start, but only if crontabs were added.

We include Supervisord to manage services started within the container.


# Mirrors

|  Provider  |  Repository                            |
|------------|----------------------------------------|
| DockerHub  | allworldit/alpine                      |
| Conarx     | registry.conarx.tech/containers/alpine |



# Commercial Support

Commercial support is available from [Conarx](https://conarx.tech).


# Environment Variables


## FDC_CI

When set to any value will trigger unit testing of the container. The difference to the normal execution path is supervisord will
be executed along-side scripts being sourced in from `docker-entrypoint-tests.d`.

An image may support the value of `FDC_CI` triggering certian tests.


## FDC_DEBUG

Enable Flexible Docker Containers debugging, this will output everything run using `set -x`.

An example of using this would be...
```bash
docker run -it --rm -e FDC_DEBUG=1 $IMAGE /bin/bash
```

## FDC_DISABLE_ENTRYPOINT

Setting this environment variable will disable the normal startup process and immediately execute the specified command.

An example of using this would be...
```bash
docker run -it --rm -e FDC_DISABLE_ENTRYPOINT=1 $IMAGE /bin/bash
```

## FDC_DISABLE_SUPERVISORD

If set, this environment variable will disable supervisord when used with a CMD override.

The result of using this option is that no init steps are run apposed to `FDC_DISABLE_ENTRYPOINT` where no init steps are run.
Furthermore no services will be started and Supervisord will not be started, but instead the command provided run instead.

An example of using this would be...
```bash
docker run -it --rm -e FDC_DISABLE_SUPERVISORD=1 $IMAGE /bin/bash
```


# Extending Using Flexible Docker Containers

All scripts are processed using `source` under `set -e` which will result in any failure being propagated to prevent container
start or tests from passing.

Shell scripts should use `#!/bin/bash` as the shebang and be set executable to allow for easy debugging, the latter can be done in
the `Dockerfile` by running `fdc set-perms` as the very last `RUN` instruction.

Scripts are executed in `sort -n` order and should be prefixed with a `XX-` number in the format of `XX-*.sh`.


## Directory: /usr/local/share/flexible-docker-containers/pre-init-tests.d

Files will be sourced in before `/usr/local/share/flexible-docker-containers/pre-init.d` and the purpose of which is to populate or
create configurations required for unit testing.


## Directory: /usr/local/share/flexible-docker-containers/pre-init.d

Files will be sourced in before `/usr/local/share/flexible-docker-containers/init.d`, these are rarely if ever used in our official
images but can be used to alter the environment before `/usr/local/share/flexible-docker-containers/init.d`.


## Directory: /usr/local/share/flexible-docker-containers/init.d

This directory is used to initialize the container environment, prepare any data and/or permissions required for container startup
and execute any upgrade steps required.


## Directory: /usr/local/share/flexible-docker-containers/pre-exec.d

Files will be sourced in after container initialization done in `/usr/local/share/flexible-docker-containers/init.d`, the purpose
of this directory is meant for adjusting an official container after initialization and before startup.

This is the last stage before startup. After any scripts in this directory are sourced in control will either be passed entirely
to supervisord or, in the case of unit testing, supervisord will be started and execution will continue in
`/usr/local/share/flexible-docker-containers/tests.d`.


## Directory: /usr/local/share/flexible-docker-containers/tests.d

Files in this directoy will be sourced in when the environment variable `FDC_CI` is set, this happens after supervisord is started,
but before any services may be up.

It is a wise idea to loop and check for service startup before starting unit testing of the service.

As the last step in unit testing `docker-healthcheck` will be executed to ensure the final state of the container passes a health
check.


## Directory: /usr/local/share/flexible-docker-containers/healthcheck.d

Files will be sourced in when `docker-healthcheck` is run as part of `HEALTHCHECK`. The purpose of this directory
is to add any health checks in a stacked container environment.

Consider outputting a usable message when a healthcheck fails to help with debugging.


# Writing Tests

Tests should be written as below...

```sh
echo "TEST START (healthcheck): Check healthcheck works..."
if ! fdc healthcheck; then
	echo "TEST FAILED (healthcheck): Did not succeed"
	false
fi
echo "TEST PASSED (healthcheck): Ran OK"
```

If you need to wait, it can be implmented like this...

```sh
echo "TEST START (crond): Check running..."
for i in {30..0}; do
    if ! pgrep crond > /dev/null; then
        break
    fi
    echo "TEST PROGRESS (crond): Waiting for crond to start... ${i}s"
    sleep 1
done
if [ "$i" = 0 ]; then
	echo "TEST FAILED (crond): Did not start!"
	false
fi
echo "TEST PASSED (crond): Started"
```
