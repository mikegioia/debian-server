#!/bin/bash

# read in siteurl from arg[0] and output file to arg[1]
#
domainname=${1:-""}

if [ -z "$domainname" ]; then
    echo "No siteurl provided"
    exit 2
fi

echo "
[${domainname}]

listen = /var/run/php5-fpm-${domainname}.socket
listen.backlog = -1

; Unix user/group of processes
; user is the user who owns the site files
user = www-data     
group = www-data

; Choose how the process manager will control the number of child processes.
pm = dynamic
pm.max_children = 75
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
pm.max_requests = 500

; Pass environment variables
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp

; host-specific php ini settings here
; php_admin_value[open_basedir] = /var/www/${domainname}/htdocs:/tmp
" > /etc/php5/fpm/pool.d/$domainname.conf