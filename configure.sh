#!/bin/bash
#
# Debian Server Installation Manager
#
# @author   Mike Gioia <mike@particlebits.com>
# @name:    configure.sh
# @about:   Create the configuration files for a new install. This creates a 
#           new folder in the conf/ directory with all of the skeleton files 
#           for a new environment.
##

## Set up the base path, flags, and variables
basepath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
profile=''

## Source the colors
. $basepath/src/inc/colors

## Help message
function showHelp {
    echo -e "${redBold}      ____                                        ${NC}"
    echo -e "${redBold}   .mgg\$\$\$\$gg.    ______     _     _              ${NC}"
    echo -e "${redBold} ,g\$\"    _ \`\$\$b.  |  _  \   | |   (_)             ${NC}"
    echo -e "${redBold}\"\$\$    ,gs  \`\$\$.  | | | |___| |__  _  __ _ _ __   ${NC}"
    echo -e "${redBold}\"Y\$.  ,\$\"  \`\$b.   | | | / _ \ '_ \| |/ _\` | '_ \  ${NC}" 
    echo -e "${redBold}\`\"b.   _\$\$,d.     | |/ /  __/ |_) | | (_| | | | | ${NC}"
    echo -e "${redBold} \`Yb.             |___/ \___|_.__/|_|\__,_|_| |_| ${NC}"
    echo -e "${redBold}   \`\"Y._                                          ${NC}"
    echo -e "${redBold}     \`'\"\"\"              Server Installation       ${NC}"
    echo ""                               
    echo -e "${yellow}Usage:${NC}"
    echo "  $0 [options] profile"
    echo ""
    echo -e "${yellow}Options:${NC}"
    echo -e "  ${green}--help      -h${NC} Display this help message"
    echo ""
    echo -e "${yellow}Help:${NC}"
    echo -e "  ${green}profile${NC} is the full profile path that will be set up in the ${green}/conf${NC} directory. "
    echo -e "  You can specify a single hostname like ${green}dev_sql_1${NC} or a full path like ${green}dev/db/sql1${NC}. "
    echo -e "  This is entirely up to you in how you wish to manage profiles."
}

## Read the remaining arguments from the CLI
function getArgs {
    ## Loop through command parameters
    for i
    do
    case $i in
        -\? | -h | --help | help )
            showHelp
            exit 0
            ;;
        * )
            ## Set the profile path
            profile=$i
            ;;
    esac
    done
}

## Prompt the user to continue with the installation
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will copy configuration files to $profile${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Create the profile directory if it doesn't exist
function createProfile {
    if ! [[ -d "$basepath/conf/$profile" ]] ; then
        echo -e "${green}Creating new profile${NC}"
        mkdir -p $basepath/conf/$profile
    fi
}

## Create blank authorized keys if none exists
function copyAuthorizedKeys {
    if ! [[ -f "$basepath/conf/$profile/authorized_keys" ]] ; then
        echo -e "  - ${green}Adding${NC} authorized_keys\n"
        cp $basepath/src/authorized_keys $basepath/conf/$profile/authorized_keys
    else
        echo -e "  - ${yellow}Skipping${NC} authorized_keys, file already exists\n"
    fi
}

## Create blank hosts if none exists
function copyHosts {
    if ! [[ -f "$basepath/conf/$profile/hosts" ]] ; then
        echo -e "  - ${green}Adding${NC} hosts file\n"
        cp $basepath/src/hosts $basepath/conf/$profile/hosts
    else
        echo -e "  - ${yellow}Skipping${NC} hosts file, file already exists\n"
    fi
}

## Copy banner if none exists
function copyBanner {
    if ! [[ -f "$basepath/conf/$profile/banner" ]] ; then
        echo -e "  - ${green}Adding${NC} banner\n"
        cp $basepath/src/banner $basepath/conf/$profile/banner
    else
        echo -e "  - ${yellow}Skipping${NC} banner, file already exists\n"
    fi
}

## Create default config file if none exists
function copyConfig {
    if ! [[ -f "$basepath/conf/$profile/config" ]] ; then
        echo -e "  - ${green}Adding${NC} default config\n"
        cp $basepath/src/config $basepath/conf/$profile/config
    else
        echo -e "  - ${yellow}Skipping${NC} config, file already exists\n"
    fi
}

## Create private bash file
function copyPrivateBash {
    if ! [[ -f "$basepath/conf/$profile/bash_private" ]] ; then
        echo -e "  - ${green}Adding${NC} bash_private\n"
        cp $basepath/src/dotfiles/private $basepath/conf/$profile/bash_private
    else
        echo -e "  - ${yellow}Skipping${NC} bash_private, file already exists\n"
    fi
}

## Create firewall
function copyFirewall {
    if ! [[ -f "$basepath/conf/$profile/firewall.sh" ]] ; then
        echo -e "  - ${green}Adding${NC} firewall.sh\n"
        cp $basepath/src/firewall.sh $basepath/conf/$profile/firewall.sh
    else
        echo -e "  - ${yellow}Skipping${NC} firewall.sh, file already exists\n"
    fi
}

## Create nginx folder and default site config
function createNginx {
    if ! [[ -d "$basepath/conf/$profile/nginx" ]] ; then
        echo -e "  - ${green}Creating${NC} nginx directory\n"
        mkdir $basepath/conf/$profile/nginx
    else
        echo -e "  - ${yellow}Skipping${NC} nginx, directory already exists\n"
    fi
}

## Set up default nginx config file
function copyNginx {
    if ! [[ -f "$basepath/conf/$profile/nginx/example.conf" ]] ; then
        echo -e "  - ${green}Copying${NC} example nginx config\n"
        cp $basepath/src/nginx_conf/example.conf $basepath/conf/$profile/nginx/example.conf
        cp $basepath/src/nginx_conf/conf_readme.md $basepath/conf/$profile/nginx/README.md
    else
        echo -e "  - ${yellow}Skipping${NC} nginx example config, files already exists\n"
    fi
}

## Copy over my.cnf
function copyMysql {
    if ! [[ -f "$basepath/conf/$profile/my.cnf" ]] ; then
        echo -e "  - ${green}Copying${NC} MySQL my.cnf\n"
        cp $basepath/src/my.cnf $basepath/conf/$profile/my.cnf
    else
        echo -e "  - ${yellow}Skipping${NC} my.cnf, file already exists\n"
    fi
}

## Copy over mongodb.conf
function copyMongodb {
    if ! [[ -f "$basepath/conf/$profile/mongodb.conf" ]] ; then
        echo -e "  - ${green}Copying${NC} MongoDB mongodb.conf\n"
        cp $basepath/src/mongodb.conf $basepath/conf/$profile/mongodb.conf
    else
        echo -e "  - ${yellow}Skipping${NC} mongodb.conf, file already exists\n"
    fi
}

## Copy over monitrc
function copyMonit {
    if ! [[ -f "$basepath/conf/$profile/monitrc" ]] ; then
        echo -e "  - ${green}Copying${NC} monitrc\n"
        cp $basepath/src/monitrc $basepath/conf/$profile/monitrc
    else
        echo -e "  - ${yellow}Skipping${NC} monitrc, file already exists\n"
    fi
}

## Run the copy files scripts
function copyFiles {
    echo -e "${green}Copying new configuration files${NC}"
    copyAuthorizedKeys
    copyHosts
    copyBanner
    copyConfig
    copyPrivateBash
    copyFirewall
    createNginx
    copyNginx
    copyMysql
}

## Finish
function finish {
    echo -e "${greenBgWhiteBold}Done!${NC}"
    echo -e "Default config files generated. Please edit, manage, or remove the files "
    echo -e "in $basepath/conf/$profile/!\n"
}

getArgs $@
promptInstall
createProfile
copyFiles
finish
exit 0