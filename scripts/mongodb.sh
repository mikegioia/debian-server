#!/bin/bash
#
# Installs MongoDB from a binary
##

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will install MongoDB from a pre-compiled binary.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Copy tar file, unpack and create symlinks
function installMongodb {
    MONGODB_OK=$(/opt/mongodb/bin/mongo --version 2>&1 | grep "${mongodbVersion}")
    if [[ "" == "$MONGODB_OK" ]] ; then
        echo -e "${green}Installing MongoDB to /opt/mongodb${NC}"
        ## Get the binaries
        wget -P /opt/ http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-${mongodbVersion}.tgz
        tar -xzf /opt/mongodb-linux-x86_64-${mongodbVersion}.tgz -C /opt

        if [[ -d "/opt/mongodb" ]] ; then
            rm -rf /opt/mongodb
        fi

        mv /opt/mongodb-linux-x86_64-${mongodbVersion} /opt/mongodb
    else
        echo -e "${yellow}MongoDB already updated to version ${mongodbVersion}${NC}"
    fi

    ## Create symlinks
    MONGODB_BINARIES="/opt/mongodb/bin/*"
    for b in $MONGODB_BINARIES
    do
        binaryFilename=$(basename $b)
        if ! [[ -h "/usr/local/bin/$binaryFilename" ]] ; then
            ln -s /opt/mongodb/bin/$binaryFilename /usr/local/bin/$binaryFilename
        fi
    done
}

## Create directories
function createDirectories {
    if ! [[ -d "/data" ]] ; then
        mkdir /data
    fi
    if ! [[ -d "/data/mongodb" ]] ; then
        mkdir /data/mongodb
    fi
    if ! [[ -d "/var/log/mongodb" ]] ; then
        mkdir /var/log/mongodb
    fi
}

## Create the user
function createUser {
    egrep "^mongod" /etc/passwd >/dev/null
    if ! [[ $? -eq 0 ]] ; then
        echo '  --> creating new user mongod'
        echo -e "${green}Creating new user mongod${NC}"
        adduser --system --no-create-home --disabled-login --disabled-password --group mongod
    fi

    chown -R mongod:mongod /data/mongodb
    chown -R mongod:mongod /var/log/mongodb
}

## Copy the init script
function copyInit {
    cp $basepath/src/mongodb/mongodb_init /etc/init.d/mongodb
    chmod +x /etc/init.d/mongodb
}

## Copy the config file
function copyConfig {
    if [[ -f "$basepath/conf/$profile/mongodb.conf" ]] ; then
        echo -e "${green}Copying over mongodb.conf to /etc${NC}"
        cp $basepath/conf/$profile/mongodb.conf /etc/mongodb.conf
    fi
}

## Add mongodb to startup
function systemStart {
    read -p "Do you want to add mongodb to system startup [y/N]? " wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        /usr/sbin/update-rc.d -f mongodb defaults
    fi
}

## Start the process if it isn't
function startRestartMongodb {
    if ! [[ -f "/etc/mongodb.conf" ]] ; then
        echo -e "${redBgWhiteBold}No config file found at /etc/mongodb.conf! Did you forget to add one to conf/${profile}?${NC}"
        echo -e "${yellowBold}Try running './configure.sh ${profile}' again to generate a new mongodb.conf file.${NC}"
        return
    fi
    if [[ $( pidof mongod) ]] ; then
        read -p "MongoDB is running, do you want to restart it? [y/N]? " wish
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            /etc/init.d/mongodb restart
        fi
    else
        read -p "Do you want to start MongoDB? [y/N]? " wish
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            /etc/init.d/mongodb start
        fi
    fi
}

promptInstall
installMongodb
createDirectories
createUser
copyInit
copyConfig
systemStart
startRestartMongodb
exit 0