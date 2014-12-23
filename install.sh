#!/bin/bash
#
# Debian Server Installation Manager
#
# @author   Mike Gioia <mike@particlebits.com>
# @name:    install.sh
# @about:   Install or update packages, update configuration files and dot 
#           files.
##

## Set up the base path, flags, and variables
basepath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
updateFlag=''
upgradeFlag=''
allFlag=''
scriptArgs=()
profile=''
config=''

## Set up config defaults
username="trunk"
nginxVersion=''
mongodbVersion=''
opensslVersion=''
redisVersion=''
redisphpVersion=''
scripts=()
sites=()
sslSites=()
fpmSites=()
git=()
hg=()

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
    echo "  $0 [options] profile [scripts]"
    echo ""
    echo -e "${yellow}Options:${NC}"
    echo -e "  ${green}--help      -h${NC} Display this help message"
    echo -e "  ${green}--update    -u${NC} Run apt-get update"
    echo -e "  ${green}--upgrade   -g${NC} Run apt-get upgrade"
    echo ""
    echo -e "${yellow}Available Scripts:${NC}"
    echo -e "  ${green}all           ${NC} Runs all scripts specified in config"
    echo -e "  ${green}app           ${NC} Sets up your application code"
    echo -e "  ${green}fail2ban      ${NC} Intalls Fail2Ban and config files"
    echo -e "  ${green}firewall      ${NC} Copies firewall script and loads on boot"
    echo -e "  ${green}mariadb       ${NC} Installs MariaDB v10.0"
    echo -e "  ${green}mongodb       ${NC} Compiles and installs MongoDB from source"
    echo -e "  ${green}monit         ${NC} Installs Monit via apt"
    echo -e "  ${green}mysql         ${NC} Installs MySQL via apt"
    echo -e "  ${green}nginx         ${NC} Compiles and installs nginx from source"
    echo -e "  ${green}openssl       ${NC} Compiles and installs OpenSSL from source"
    echo -e "  ${green}php           ${NC} Installs PHP from the DotDeb repository"
    echo -e "  ${green}profile       ${NC} Sets up your bash profile"
    echo -e "  ${green}redis         ${NC} Compiles and installs Redis from source"
    echo -e "  ${green}user          ${NC} Creates shell account and configures environment"
    echo -e "  ${green}xtrabackup    ${NC} Installs Percona XtraBackup via apt"
    echo ""
    echo -e "Default command is ${green}all${NC} if none is specified."
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
        -u | --update )
            updateFlag=1
            ;;
        -g | --upgrade )
            upgradeFlag=1
            ;;
        all )
            ## Run all scripts
            allFlag=1
            ;;
        app | fail2ban | firewall | mariadb | mongodb | monit | mysql )
            ## Add to scripts array
            scriptArgs+=$1
            ;;
        nginx | openssl | php | profile | redis | user | xtrabackup )
            ## Add to scripts array
            scriptArgs+=$1
            ;;
        * )
            ## Set the profile path
            profile=$i
            ;;
    esac
    done
}

## Check if logged in user is root
function checkRoot {
    if ! [[ $(id -u) -eq 0 ]] ; then
        echo -e "\n${redBgWhiteBold}You are not the root user!${NC}"
        exit 1
    fi
}

## Check if the profile path is to a valid profile
function checkProfile {
    config="$basepath/conf/$profile/config"
    if ! [[ -f "$config" ]] ; then
        echo -e "\n${redBgWhiteBold}Could not find the profile you entered: ${profile}${NC}"
        echo -e -n "Make sure to run ./configure.sh <profile> in the deploy directory "
        echo -e "or ./configure --help for more info.${NC}\n"
        exit 1
    fi
}

## Prompt the user to continue with the installation
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will update software and configuration files on your server.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Read in the config variables and export vars
function readConfig {
    . $config
    export basepath
    export profile
    export username
    export nginxVersion
    export mongodbVersion
    export opensslVersion
    export redisVersion
    export redisphpVersion
    export sites
    export sslSites
    export fpmSites
    export git
    export hg
}

## Update the system if flag set
function update {
    if [[ "$updateFlag" ]] ; then
        apt-get update
    fi
}

## Upgrade the system if flag set
function upgrade {
    if [[ "$upgradeFlag" ]] ; then
        apt-get upgrade --show-upgraded
    fi
}

## Export colors
function exportColors {
    export black
    export red
    export green
    export yellow
    export blue
    export magenta
    export cyan
    export white
    export redBgWhite
    export redBgWhiteBold
    export blueBgWhite
    export blueBgWhiteBold
    export greenBgWhite
    export greenBgWhiteBold
    export blackBold
    export redBold
    export greenBold
    export yellowBold
    export blueBold
    export magentaBold
    export cyanBold
    export whiteBold
    export NC
}

## Run the scripts
function runScripts {
    if ! [[ "${#scriptArgs[@]}" -eq 0 ]] ; then
        for script in "${scriptArgs[@]}"
        do
            if [[ -f "$basepath/conf/$profile/scripts/$script.sh" ]] ; then
                $basepath/conf/$profile/scripts/$script.sh
            else
                $basepath/scripts/$script.sh
            fi
        done
    else
        for script in "${scripts[@]}"
        do
            if [[ -f "$basepath/conf/$profile/scripts/$script.sh" ]] ; then
                $basepath/conf/$profile/scripts/$script.sh
            else
                $basepath/scripts/$script.sh
            fi
        done
    fi
}

## Finish
function finish {
    echo -e "\n${greenBgWhiteBold}Done!${NC}"
    echo -e "Make sure to restart your server for all changes to take effect!${NC}\n"
}

## Run the program
getArgs $@
checkRoot
checkProfile
promptInstall
readConfig
update
upgrade
exportColors
runScripts
finish
exit 0