# HTTP Server
#
server {
    listen       80;
    listen       localhost:80;
    server_name  example.com www.example.com;

    error_log    /opt/nginx/logs/example.com.error.log;
    access_log   /opt/nginx/logs/example.com.access.log;

    root         /var/www/example.com/;
    index        index.php index.html index.htm;

    autoindex    off;

    location ~* \.(php|php5|php4)($|/) {
        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SERVER_PORT      80;
        fastcgi_param  SCRIPT_FILENAME  /var/www/example.com$fastcgi_script_name;
        fastcgi_param  REQUEST_URI      $request_uri;
        fastcgi_param  QUERY_STRING     $query_string;
        fastcgi_param  REQUEST_METHOD   $request_method;
        fastcgi_param  CONTENT_TYPE     $content_type;
        fastcgi_param  CONTENT_LENGTH   $content_length;
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

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    location ~ /\.ht {
        deny all;
    }
}
