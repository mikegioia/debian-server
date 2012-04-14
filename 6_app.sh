#!/bin/bash

# set up the application
#

echo "This script will set overwrite nginx config files and create the application directories"
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    exit
fi

usage="$0 <config>"
config=${1:-"server.cfg"}

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config."
    exit
fi

. ./$config

cd

# configure environment
#
echo '  --> configuring the environment directories'
if [ ! -d /var/www ] ; then
    mkdir /var/www
fi
if [ ! -d /var/www/$siteurl ] ; then
    mkdir /var/www/$siteurl
fi
if [ ! -L /home/$username/$siteurl ] ; then
    ln -s /var/www/$siteurl /home/$username/$siteurl
fi


# install phpmyadmin
#
echo '  --> installing phpmyadmin'
cd
apt-get install phpmyadmin
if [ ! -L /var/www/$siteurl/phpmyadmin ] ; then
    ln -s /usr/share/phpmyadmin /var/www/$siteurl/phpmyadmin
fi


# copy nginx config files (all files in instance folder)
#
echo '  --> copy nginx config files'
cd
conffiles="./conf/$server/*.conf"
for f in $conffiles
do
    filename=`basename ${f:2}`
    echo "        + $filename"
    if [ -f /opt/nginx/conf/$filename ]; then
        rm /opt/nginx/conf/$filename
    fi
    cp $f /opt/nginx/conf/$filename
done


# set permissions on web folders
#
echo '  --> install the app files'
apt-get install bc
chown -R $username /home/$username
chgrp -R $username /home/$username
chown -R www-data /var/www/$siteurl
chgrp -R www-data /var/www/$siteurl
cd
cp ./src/404.html /var/www/404.html
cp ./src/50x.html /var/www/50x.html
cp ./src/index.php /var/www/$siteurl/index.php

# update www permissions
#
chown -R www-data /var/www
chgrp -R www-data /var/www

# remove apache (again)
#
/etc/init.d/apache2 stop
/usr/sbin/update-rc.d -f apache2 remove

# restart nginx
#
echo '  --> restarting nginx'
/etc/init.d/nginx restart

