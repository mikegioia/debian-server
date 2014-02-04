#!/bin/bash

# read in siteurl from arg[0] and output file to arg[1]
#
siteurl=${1:-""}

if [ -z "$siteurl" ]; then
    echo "No siteurl provided"
    exit 2
fi

echo "
# HTTPS Server
#
server {
    listen       443 ssl spdy;
    listen       localhost:443 ssl spdy;
    server_name  www.$siteurl;

    ssl on;
    ssl_certificate      /opt/nginx/ssl/$siteurl.bundle.crt;
    ssl_certificate_key  /opt/nginx/ssl/$siteurl.key;
    ssl_session_timeout  5m;
    ssl_protocols        SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers          AES128-GCM-SHA256:ECDHE-RSA-AES128-SHA256:RC4:HIGH:!MD5:!aNULL:!EDH;
    ssl_prefer_server_ciphers   on;

    return 301 \$scheme://$siteurl\$request_uri;
}

server {
    listen       443 ssl spdy;
    listen       localhost:443 ssl spdy;
    server_name  $siteurl;

    error_log    /opt/nginx/logs/$siteurl.error.log;
    access_log   /opt/nginx/logs/$siteurl.access.log;

    root         /var/www/$siteurl/www-data/;
    index        index.php index.html index.htm;

    autoindex    off;
    charset      utf-8;

    ssl on;
    ssl_certificate      /opt/nginx/ssl/$siteurl.bundle.crt;
    ssl_certificate_key  /opt/nginx/ssl/$siteurl.key;
    ssl_session_timeout  5m;
    ssl_protocols        SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers          AES128-GCM-SHA256:ECDHE-RSA-AES128-SHA256:RC4:HIGH:!MD5:!aNULL:!EDH;
    ssl_prefer_server_ciphers  on;

    # htpasswd
    #
    # auth_basic             \"Restricted\";
    # auth_basic_user_file   /var/www/$siteurl/htpasswd;

    # include trunk configuration
    #
    include trunk.conf;

    # spdy and ssl headers
    #
    add_header Strict-Transport-Security max-age=31536000;
    add_header X-Frame-Options DENY;
    add_header Alternate-Protocol 443:npn-spdy/2;

    # uncomment to route non-file requests to index.php
    #
    # try_files \$uri \$uri/ @rewrite;
    #
    # location @rewrite {
    #     rewrite ^/(.*)$ /index.php/\$1;
    # }

    location ~* \.(php|php5|php4)($|/) {
        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        fastcgi_pass   unix:/var/run/php5-fpm.socket;
        fastcgi_index  index.php;
        fastcgi_param  SERVER_PORT      80;
        fastcgi_param  SCRIPT_FILENAME  /var/www/$siteurl/www-data\$fastcgi_script_name;
        fastcgi_param  REQUEST_URI      \$request_uri;
        fastcgi_param  QUERY_STRING     \$query_string;
        fastcgi_param  REQUEST_METHOD   \$request_method;
        fastcgi_param  CONTENT_TYPE     \$content_type;
        fastcgi_param  CONTENT_LENGTH   \$content_length;
        include        fastcgi_params;
    }

    # redirect for 404 errors to the static page /404.html
    #
    error_page  404  /404.html;
    location = /404.html {
        root   /var/www;
    }
    
    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /var/www;
    }
}
" > /opt/nginx/conf/sites-available/$siteurl.ssl.conf
