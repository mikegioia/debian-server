# Web Server Installation

@version 3.0 BETA

*THIS IS CURRENTLY BEING WORKED ON FOR VERSION 3. IF YOU'RE USING THIS OR
NEED A STABLE VERSION, PLEASE PICK FROM THE LATEST 2.X TAG.*

## About

A custom set of software installation scripts for a Debian 7 web server.
Included are scripts for nGinx, MariaDB, MongoDB, MySQL, PHP, Redis, Xtrabackup,
Fail2Ban, Monit, creating and setting up the bash environment, firewall using
iptables, and installing application software from either git or mercurial
repositories.

Support for HTTP / HTTPS is also included for nGinx and there are sample config
files for HTTPS domains. All scripts are broken out into separate files if you
want to run them separately, but simply run `./install.sh <profile>` to fire
them all on a new machine. To run individual scripts use 
`./install.sh <profile> <script1.sh> <script2.sh>...`. 
These scripts are optimized to run ona clean Debian 7 installation and tested 
heavily on Rackspace Cloud in particular. If you have any issues at all, 
please add them here or message me directly @mikegioia
(http://twitter.com/mikegioia).

## Extremely important SSH notes

SSH is set to run on port 30000 in this setup. If you want to use a different
port (like 22) then edit line 5 of `/src/sshd_config`. 

This SSH config looks in `./ssh/authorized_keys` for SSH keys. Edit the
`/src/authorized_keys` file to include any SSH keys for your local machines
to connect directly. **Password authentication is currently enabled** but in
my experience this is unwise. If you want to disable password authentication
then edit line 50 of `/src/sshd_config` to be `PasswordAuthentication no`
and then restart SSH by running `sudo /etc/init.d/ssh restart`. You can include
an `sshd_config` file in any of your environments to overwrite the default
`sshd_config` that will be copied.

## Run the configuration script for each profile

To create a new default profile, run `./configure.sh <profile>` where
`<profile>` is the path hierarchy you want in the `/conf` directory. For
example, to create a new profile named 'development', simply run
`./configure.sh development`. The folder 'development' will be created in 
the `/conf` directory with all of the default configuration files.

To create a profile with more context, you could run something like
`./configure.sh dev/app/db1` which would create that path in the `/conf`
directory. In this case, db1 would be the folder with the configuration files.

The main configuration file created will be named `config` which has a few
variables you can set:

* **username**: user account on the web server
* **{%program%}_version**: version to install for the given software 
* **ip_public**: machine's public IP address (optional)
* **ip_internal**: machines internal network IP address (optional)
* **scripts**: array of scripts to run by default

Additional options you can set are:

* **sites**: array of websites to automatically configure for nginx
* **ssl_sites**: array of SSL websites to automatically configure for nginx
* **fpm_sites**: array of FPM pools to create
* **git**: array of git repositories to download to the user's `repos/` folder
* **hg**: array of mercurial repositories to download to the user's `repos/`
  folder

## Edit the server configuration files

Inside `/conf/<profile>` are a collection of configuration files and source
files that the applications will use.

@TODO -- write out info on these

## Run the installer

When you're ready to install run the command `./install.sh <profile>`
**AS ROOT**. These scripts assume root so please `sudu su` before running them. 

##Notes about this installation

* This script will `apt-get update` and `apt-get upgrade` your system. This
  could take a while so be sure to watch over it.
* You will be prompted to set passwords for MySQL and MariaDB. Keep those handy
  and watch when it prompts.
* You will be asked to install PHP Mongo extension if you run the PHP script.
* You will be asked if you want to overwrite the SSH config each time the
  profile script runs. It will default to NO but it's best to copy this over the
  first time you run it.
* It's best to scp these files to `/root` and you should definitely run the
  installer as root.
* I've timed the entire install process and it averages to about 8 minutes on a
  512MB machine!
