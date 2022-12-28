# Introduction

This is the AllWorldIT Alpine Linux base image for various other docker images.

It comes bundled with Supervisord and Cron.



# Environment


## DISABLE_SUPERVISORD

If set, this environment variable will disable supervisord when overriding the run command only.




# Script directories


## Directory: /docker-entrypoint-pre-init-tests.d

Any file with the .sh extension in this directory will be sourced in before initialization takes place during tests only.


## Directory: /docker-entrypoint-pre-init.d

Any file with the .sh extension in this directory will be sourced in before initialization takes place.


## Directory: /docker-entrypoint-init.d

Any file with the .sh extension in this directory will be sourced for initialization.


## Directory: /docker-entrypoint-pre-exec.d

Any file with the .sh extension in this directory will be sourced in after initialization, before startup.


## Directory: /docker-entrypoint-tests.d

Any file with the .sh extension in this directory will be sourced in during tests only.


## Directory: /docker-healthcheck.d

Any file with the .sh extension in this directory will be sourced in during healthcheck.
