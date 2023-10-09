#!/bin/bash
CONFIG_FOLDER=$HOME/.jitsi-meet-cfg
CONFERENCE_CLONE_PATH=$CONFIG_FOLDER/web
DOCKER_JITSI_FOLDER=$HOME/docker-jitsi

remove_containers() {
    sudo docker-compose down 
    rm -rf $CONFIG_FOLDER
}

dependency_setup() {
    cp env.example .env
    ./gen-passwords.sh
    mkdir -p $CONFIG_FOLDER/{web,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}
}

repos_setup() {
    rm -fr conference-base
    echo checking ssh keys
    testssh=$(ls -lah ~/.ssh)
    if [ $? -eq 0 ]; then
        echo -e $'\e[91mssh keys present\e[0m'
           git clone git@github.com:Dreampotential-org/conference-base.git
        if [ $? -eq 0 ]; then
            echo OK! Cool.
        else
            echo -e $'\e[91msomething wrong with your github setup. Could you please verify that you have the necessary permissions and then continue with the further steps?\e[0m' && cd ~/
            return
        fi
        cd conference-base
        git checkout master
    else
        echo -e $'\e[91mssh keys not present please create and add to github\e[0m'
    fi
}

ssh-add "/users/arosen/.ssh/github"
remove_containers
dependency_setup
repos_setup
cd $DOCKER_JITSI_FOLDER
sudo docker-compose -f docker-compose.yml up -d
#$sudo docker-compose -f docker-compose.yml -f jibri.yml up -d
cd
ls
pwd
echo $CONFERENCE_CLONEPATH
echo $DOCKER_JITSI_FOLDER
cp conference-base/interface_config.js $DOCKER_JITSI_FOLDER
