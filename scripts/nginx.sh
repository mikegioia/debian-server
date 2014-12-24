#!/bin/bash
#
# Installs nginx from source
##

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will install nginx from source${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Install requirements if not installed
function installDependencies {
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' libpcre3-dev|grep "install ok installed")
    if [[ "" == "$PKG_OK" ]] ; then
        apt-get install libpcre3-dev
    fi

    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' build-essential|grep "install ok installed")
    if [[ "" == "$PKG_OK" ]] ; then
        apt-get install build-essential
    fi
}

## Check if nginx is up to date. If not install/update nginx.
function installNginx {
    NGINX_OK=$(/opt/nginx/sbin/nginx -v 2>&1 | grep "nginx/${nginx_version}")
    if [[ "" == "$NGINX_OK" && -n "${nginx_version}" ]] ; then
        echo -e "${green}Installing nginx from source to /opt/nginx${NC}"
        cd /opt/
        wget http://nginx.org/download/nginx-${nginx_version}.tar.gz
        tar -zxvf nginx-${nginx_version}.tar.gz
        cd /opt/nginx-${nginx_version}/
        ## @todo move this out to config file
        ./configure \
            --prefix=/opt/nginx \
            --user=nginx \
            --group=nginx \
            --with-http_ssl_module \
            --with-ipv6 \
            --with-http_stub_status_module \
            --with-http_spdy_module \
            --with-http_realip_module
        make
        make install
    else
        echo -e "${yellow}nginx already updated to version ${nginx_version}${NC}"
    fi
}

## Check if nginx user exists. If not, create the new user.
function addUser {
    egrep "^nginx" /etc/passwd >/dev/null
    if ! [[ $? -eq 0 ]] ; then
        echo -e "${green}Adding nginx user${NC}"
        adduser --system --no-create-home --disabled-login --disabled-password --group nginx
    fi
}

## Copy over the default nginx and trunk config. set up directories.
function copyConfig {
    echo -e "${green}Copying over config files to /opt/nginx/conf${NC}"
    if ! [[ -d "/opt/nginx/conf/sites-available" ]] ; then
        mkdir /opt/nginx/conf/sites-available
    fi
    if ! [[ -d "/opt/nginx/conf/sites-enabled" ]] ; then
        mkdir /opt/nginx/conf/sites-enabled
    fi

    if [[ -f "$basepath/conf/$profile/nginx.conf" ]] ; then
        cp $basepath/conf/$profile/nginx.conf /opt/nginx/conf/nginx.conf
    else
        cp $basepath/src/nginx_conf/nginx.conf /opt/nginx/conf/nginx.conf
    fi

    cp $basepath/src/nginx_conf/trunk.conf /opt/nginx/conf/trunk.conf
    cp $basepath/src/nginx_conf/mime.types /opt/nginx/conf/mime.types
}

## Copy over the nginx config files to sites-available. For each
## config file, check if there's a symlink in sites-enabled. if not,
## add he new sym link.
function copySites {
    if [[ -d "$basepath/conf/$profile/nginx" ]] ; then
        echo -e "${green}Copying over site config files${NC}"
        cp $basepath/conf/$profile/nginx/*.conf /opt/nginx/conf/sites-available/
        CONF_FILES="/opt/nginx/conf/sites-available/*.conf"
        for c in $CONF_FILES
        do
            config_filename=$(basename $c)
            if ! [[ -h "/opt/nginx/conf/sites-enabled/$config_filename" ]] ; then
                ln -s ../sites-available/$config_filename /opt/nginx/conf/sites-enabled/$config_filename
            fi
        done
    fi
}

## Ask the user if they need to copy over any SSL certs/keys
function promptSsl {
    echo -e "${yellow}nginx will now be started or reloaded. Now would be a good time to copy over any SSL certificates and keys!${NC}"
    read -p 'Press any key to continue ' anykey
}

## Copy over the init script and set up nginx to start on reboot
function copyInit {
    echo -e "${green}Configuring the init script${NC}"
    cp $basepath/src/nginx /etc/init.d/nginx
    chmod +x /etc/init.d/nginx
    read -p "Do you want to add nginx to system startup? [y/N]? " wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        /usr/sbin/update-rc.d -f nginx defaults
    fi
    read -p "Do you want to remove apache from system startup? [y/N]? " wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        /usr/sbin/update-rc.d -f apache2 remove
    fi
}

## Copy over remaining nginx files
function copyDefaults {
    echo -e "${green}Copying 404 and 50x files${NC}"
    if ! [[ -d "/var/www" ]] ; then
        mkdir /var/www
        chown www-data:www-data /var/www
    fi
    if ! [[ -f "/var/www/404.html" ]] ; then
        cp $basepath/src/404.html /var/www/404.html
        chown www-data:www-data /var/www/404.html
    fi
    if ! [[ -f "/var/www/50x.html" ]] ; then
        cp $basepath/src/50x.html /var/www/50x.html
        chown www-data:www-data /var/www/50x.html
    fi
}

## Update permissions
function updatePermissions {
    read -p "Do you want to change ownership of all /var/www files to www-data? [y/N]? " wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        chown -R www-data:www-data /var/www
    fi
}

## If nginx is running, reload the config. if it's not, start nginx.
function startReloadNginx {
    ps cax | grep 'nginx' > /dev/null
    if [[ $? -eq 0 ]] ; then
        read -p "nginx is running, do you want to reload it? [y/N]? " wish
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            service nginx reload
        fi
    else
        read -p "Do you want to start nginx? [y/N]? " wish
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            service nginx start
        fi
    fi
}

promptInstall
installDependencies
installNginx
addUser
copyConfig
copySites
promptSsl
copyInit
copyDefaults
updatePermissions
startReloadNginx
exit 0