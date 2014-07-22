#!/bin/bash
#
# Sets up the application, sites, and all
##

echo 'This script will create application directories, /var/www directories, and overwrite any nginx config files for your sites.'
read -p 'Do you want to continue? [y/N] ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

## Configure environment
echo '  --> configuring the environment directories'
if ! [[ -d "/var/www" ]] ; then
    mkdir /var/www
fi

## Resource the config file
. $basepath/conf/$profile/config

## Loop through any available sites and ssl sites
for site in "${sites[@]}"
do
    if ! [[ -d "/var/www/$site" ]] ; then
        mkdir /var/www/$site
    fi
    if ! [[ -d "/var/www/$site/www-data" ]] ; then
        mkdir /var/www/$site/www-data
    fi

    ## Generate nginx site config files to sites-available and add 
    ## symbolic links in sites-enabled
    $basepath/src/nginx_conf/sites-available/example.com.conf.sh $site
    if [[ -f "/opt/nginx/conf/sites-enabled/$site.conf" ]] ; then
        rm /opt/nginx/conf/sites-enabled/$site.conf
    fi
    ln -s ../sites-available/$site.conf /opt/nginx/conf/sites-enabled/$site.conf
    cp $basepath/src/index.php /var/www/$site/www-data/index.php
    cp $basepath/src/index.html /var/www/$site/www-data/index.html
done

for ssl_site in "${ssl_sites[@]}"
do
    if ! [[ -d "/var/www/$ssl_site" ]] ; then
        mkdir /var/www/$ssl_site
    fi
    if ! [[ -d "/var/www/$ssl_site/www-data" ]] ; then
        mkdir /var/www/$ssl_site/www-data
    fi

    ## Generate nginx site config files to sites-available and add 
    ## symbolic links in sites-enabled
    $basepath/src/nginx_conf/sites-available/example.com.ssl.conf.sh $site
    if [[ -f "/opt/nginx/conf/sites-enabled/$site.ssl.conf" ]] ; then
        rm /opt/nginx/conf/sites-enabled/$site.ssl.conf
    fi
    ln -s ../sites-available/$site.ssl.conf /opt/nginx/conf/sites-enabled/$site.ssl.conf
    cp $basepath/src/index.php /var/www/$site/www-data/index.php
    cp $basepath/src/index.html /var/www/$site/www-data/index.html
done

## Clone repos
echo '  --> install the app files'
if ! [[ `hash bc 2>/dev/null` ]] ; then
    apt-get install bc
fi

if ! [[ -d "/home/$username/repos" ]] ; then
    mkdir /home/$username/repos
fi

## Check for any mercurial projects (install if not installed)
if [[ ${#hg} ]] ; then
    if ! [[ `hash hg 2>/dev/null` ]]; then
        apt-get install mercurial
    fi
    for hg_url in "${hg[@]}"
    do
        reponame=$(basename "$hg_url")
        if ! [[ -d "/home/$username/repos/$reponame" ]] ; then
            echo "  --> cloning new repo $reponame"
            cd /home/$username/repos
            hg clone $hg_url
        fi
        ## Copy an hgrc if it exists in conf
        if [[ -f "$basepath/conf/$profile/repos/$reponame/hgrc" ]] ; then
            cp $basepath/conf/$profile/repos/$reponame/hgrc /home/$username/repos/$reponame/.hg/hgrc
        fi
    done
fi

## Check for any git projects (install if not installed)
if [[ ${#git} ]] ; then
    if ! [[ `hash git 2>/dev/null` ]] ; then
        apt-get install git
    fi
    for git_url in "${git[@]}"
    do
        reponame=$(basename "$git_url")
        if ! [[ -d "/home/$username/repos/$reponame" ]] ; then
            echo "  --> cloning new repo $reponame"
            cd /home/$username/repos
            git clone $git_url
        fi
    done
fi

## for each config file, check if there's a symlink in
## sites-enabled. if not, add the new sym link.
echo '  --> copying over any nginx configs'
if [[ -d $basepath/conf/$profile/nginx ]] ; then
    cp $basepath/conf/$profile/nginx/*.conf /opt/nginx/conf/sites-available/
    CONF_FILES="/opt/nginx/conf/sites-available/*.conf"
    for c in $CONF_FILES
    do
        config_filename=$(basename $c)
        if ! [[ -h "/opt/nginx/conf/sites-enabled/$config_filename" ]] ; then
            ln -s ../sites-available/$config_filename /opt/nginx/conf/sites-enabled/$config_filename
        fi
    done
    cd
fi

## Update permissions
echo '  --> updating /var/www permissions'
chown -R www-data:www-data /var/www
chown -R $username:$username /home/$username/repos

## Remove apache
ps cax | grep 'apache2' > /dev/null
if [[ $? -eq 0 ]] ; then
    echo '  --> stopping and removing apache2'
    /etc/init.d/apache2 stop
    /usr/sbin/update-rc.d -f apache2 remove
fi

## Restart nginx
ps cax | grep 'nginx' > /dev/null
if [[ $? -eq 0 ]] ; then
    echo '  --> reloading nginx configuration'
    /opt/nginx/sbin/nginx -s reload
fi

echo 'App completed'
echo ''