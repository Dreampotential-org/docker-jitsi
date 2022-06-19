#!/bin/bash
CONFIG_FOLDER=$HOME/.jitsi-meet-cfg
CONFERENCE_CLONE_PATH=$CONFIG_FOLDER/web

remove_containers() {
    docker-compose down --remove-orphans
    rm -rf $CONFIG_FOLDER
}

dependency_setup() {
    cp env.example .env
    ./gen-passwords.sh
    mkdir -p $CONFIG_FOLDER/{web,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}
}

repos_setup() {
    echo checking ssh keys
    testssh=$(ls -lah ~/.ssh)
    if [ $? -eq 0 ]; then
        echo -e $'\e[91mssh keys present\e[0m'
        cd $CONFERENCE_CLONE_PATH && git clone git@github.com:aaronorosen/conference-base.git
        if [ $? -eq 0 ]; then
            echo OK! Cool.
        else
            echo -e $'\e[91msomething wrong with your github setup. Could you please verify that you have the necessary permissions and then continue with the further steps?\e[0m' && cd ~/
            return
        fi
        cd $CONFERENCE_CLONE_PATH/conference-base
        git checkout master
        cp interface_config.js $CONFERENCE_CLONE_PATH
    else
        echo -e $'\e[91mssh keys not present please create and add to github\e[0m'
    fi
}

remove_containers
dependency_setup
docker-compose -f docker-compose.yml -f jibri.yml up -d
repos_setup
