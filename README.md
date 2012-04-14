#Web Server Installation

@version 1.0
 
##About

A complete installation script for PHP, MySQL, nginx, Mongo DB, Exim, and
user environment. Includes support for HTTP and HTTPS in nginx. All scripts
are broken out into separate files if you want to run them separately, but
run `./install.sh` to fire them all. These scripts are optimized to run on
a clean Debian 6 installation and tested heavily on Rackspace Cloud in
particular. If you have any issues at all, please add them here or message
me directly @mikegioia (http://twitter.com/mikegioia).

##Extremely important SSH notes

SSH is set to run on port 30000 in this set up. If you want to use a different
port (like 22) then edit line 5 of `/src/sshd_config`. 

This SSH config looks in `./ssh/authorized_keys` for SSH keys. Edit the
`/src/authorized_keys` file to include any SSH keys for your local machines
to connect directly. **Password authentication is currently enabled** but in
my experience this is unwise. If you want to disable password authentication
then edit line 50 of `/src/sshd_config` to be `PasswordAuthentication yes`
and then restart SSH by running `sudo /etc/init.d/ssh restart`.

##Edit the configuration file

There are a few config variables in `example.cfg`:

* **username**: user account on the web server
* **siteurl**: your web site URL
* **server**: the directory folder containing your server config files (in `/conf`).
          If you want to include multiple server configs, make a new folder for
          each one and a separate config file too.

You should change `example.cfg` to be something related to your web server
in case you want to run this across multiple machines.

##Edit the server configuration files

Inside `/conf/server` are a collection of nginx configuration files. You should
change the `example.com` references to be your site URL hosted on the web
server. Inside `nginx.conf` you should change the include paths. HTTS is not
inluced by default, so uncomment it out to have nginx load that file.

##Choose which sub-scripts to run

You can specify which sub-scripts to run by editing `install.sh`. By default it
will run all 8. Comment out or remove any numbered scripts you do not want to
run (for example, if you don't want to install and set up mongo, comment out the
line to run `8_mongo.sh`).

##Run the installer

When you're ready to install run the command `./install.sh example.cfg`. If you
changed the name of `example.cfg` make sure to use the new name in the command 
you run.