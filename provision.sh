#!/usr/bin/env bash

arguments=$*
if [ $# -eq 0 ]; then
    noargs=1
fi

for i in "$@"
do
case $i in
    --rebuild)
    rebuild=1
    shift # past argument with no value
    ;;
    --global-containers)
    globalcontainers=1
    shift # past argument with no value
    ;;
    *)
            # unknown option
    ;;
esac
done

if [ "$(uname)" == "Darwin" ]; then
    echo "Darwin detected"
elif [ "$(expr substr $(uname -s) 1 5 2>/dev/null)" == "Linux" ]; then
    echo "Linux detected"
elif [ "$(expr substr $(uname -s) 1 6 2>/dev/null)" == "CYGWIN" ]; then
    echo "Windows detected"
fi


# If no parameters specified
if [ -n "$noargs" ]
then
    # Write DOCKER_HOST variable export to a matching .rc file based on the shell (bash or zsh)
    SOURCE_FILE=''
    DOCKER_HOST_EXPORT='\n# Docker (default for Vagrant based boxes)\nexport DOCKER_HOST=tcp://localhost:2375\n'

    # Detect shell to write to the right .rc file
    if [[ $SHELL == '/bin/bash' || $SHELL == '/bin/sh' ]]; then SOURCE_FILE=".bash_profile"; fi
    if [[ $SHELL == '/bin/zsh' ]]; then	SOURCE_FILE=".zshrc"; fi

    if [ "$(expr substr $(uname -s) 1 5 2>/dev/null)" != "Linux" ]; then
        if [[ $SOURCE_FILE ]]; then
            # See if we already did this and skip if so
            grep -q "export DOCKER_HOST=tcp://localhost:2375" $HOME/$SOURCE_FILE
            if [[ $? -ne 0 ]]; then
                echo -e "${green}Adding automatic DOCKER_HOST export to $HOME/$SOURCE_FILE${NC}"
                echo -e $DOCKER_HOST_EXPORT >> $HOME/$SOURCE_FILE
            fi
        else
            echo -e "${red}Cannot detect your shell. Please manually add the following to your respective .rc or .profile file:${NC}"
            echo -e "$DOCKER_HOST_EXPORT"
        fi
    fi

    # Only for Linux set docker parameters
    if [ "$(expr substr $(uname -s) 1 5 2>/dev/null)" == "Linux" ]; then
        # Update docker daemon options and restart
        if sudo grep -q "^DOCKER_OPTS=" /etc/default/docker
        then
            sudo sed -ri "s/^DOCKER_OPTS=.*$/DOCKER_OPTS=\"--bip=172.17.42.1\/24 --dns=172.17.42.1 --dns 8.8.8.8 --dns 8.8.4.4\"/" /etc/default/docker
        else
            echo "DOCKER_OPTS=\"--bip=172.17.42.1/24 --dns=172.17.42.1 --dns 8.8.8.8 --dns 8.8.4.4\""  | sudo tee --append /etc/default/docker
        fi

        if systemctl status docker >/dev/null 2>&1
        then
            echo "Ubuntu systemd detected. Adjusting configuration files."
            sudo mkdir -p /etc/systemd/system/docker.service.d

            cat <<'SCRIPT' | sudo tee /etc/systemd/system/docker.service.d/ubuntu.conf
[Service]
# workaround to include default options
EnvironmentFile=/etc/default/docker
ExecStart=
ExecStart=/usr/bin/docker daemon -H fd:// $DOCKER_OPTS
SCRIPT
            sudo systemctl daemon-reload
            sudo systemctl restart docker

        else
            sudo /etc/init.d/docker restart > /dev/null 2>&1 || sudo service docker restart
        fi
    fi

    if [ "$(expr substr $(uname -s) 1 5 2>/dev/null)" != "Linux" ]; then
        scp -q dockers/aliases.sh docker@192.168.10.10:/home/docker/scripts
    else
        #add some aliases
        if [[ $SOURCE_FILE ]]; then
            mkdir -p ~/scripts && cp dockers/aliases.sh ~/scripts/aliases.sh
            grep "source ~/scripts/aliases.sh" < ~/$SOURCE_FILE > /dev/null 2>&1 || echo 'source ~/scripts/aliases.sh' >> ~/$SOURCE_FILE
        fi
        sudo mkdir -p /ssl_certs
    fi
fi


docker rm -f dns > /dev/null 2>&1 || true
docker rm -f vhost-proxy > /dev/null 2>&1 || true
docker rm -f sinopia > /dev/null 2>&1 || true


if [ -n "$rebuild" ]
then
    docker rmi -f datasyntax/ansible > /dev/null 2>&1 || true
    docker rmi -f datasyntax/nginx-proxy > /dev/null 2>&1 || true
fi


if [ -n "$noargs" ] || [ -n "$globalcontainers" ] || [ -n "rebuild" ]
then

    echo "Building ansible image... "
    docker build -t datasyntax/ansible dockers/ansible/

    echo "Building nginx-proxy image... "
    docker build -t datasyntax/nginx-proxy dockers/nginx-proxy/

    echo "Starting system-wide DNS service... "
    docker run -d --name dns -p 172.17.42.1:53:53/udp --cap-add=NET_ADMIN \
    --restart always \
    --dns 8.8.8.8 -v /var/run/docker.sock:/var/run/docker.sock \
    jderusse/dns-gen > /dev/null

    if [ "$(uname)" == "Darwin" ]; then
        sudo mkdir -p /etc/resolver
        sudo tee /etc/resolver/dev >/dev/null <<EOF
nameserver 172.17.42.1
EOF
    fi

    # Setting DNS (only for Linux or inside docker-host
    if [ "$(expr substr $(uname -s) 1 5 2>/dev/null)" == "Linux" ]
    then
        sudo grep "nameserver 172.17.42.1" < /etc/resolv.conf > /dev/null 2>&1 || (echo "nameserver 172.17.42.1" | sudo cat - /etc/resolv.conf > temp && sudo mv temp /etc/resolv.conf)
    else
        ssh -q docker@192.168.10.10 "sudo grep \"nameserver 172.17.42.1\" < /etc/resolv.conf > /dev/null 2>&1 || (echo 'nameserver 172.17.42.1' | sudo cat - /etc/resolv.conf > temp && sudo mv temp /etc/resolv.conf)"
    fi

    echo "Starting system-wide HTTP reverse proxy bound to :80... "
    docker run -d --name vhost-proxy -p  80:80 -p 443:443 \
    --restart always \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    -v /ssl_certs:/etc/nginx/certs \
    datasyntax/nginx-proxy > /dev/null

    echo "Starting Sinopia Docker... "
    docker run -d --name sinopia -p 4873:4873 \
    --restart always \
    keyvanfatehi/sinopia:latest > /dev/null
fi