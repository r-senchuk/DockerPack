#!/bin/sh

#TODO: we do not need this staff
#alias docker-compose='docker run \
#-it \
#--rm \
#-v /var/run/docker.sock:/var/run/docker.sock \
#-v $(pwd):/app \
#datasyntax/compose'
#
#alias docker-compose-nontty='docker run \
#--rm \
#-v /var/run/docker.sock:/var/run/docker.sock \
#-v $(pwd):/app \
#datasyntax/

# Kill all running containers.
alias dockerkillall='docker kill $(docker ps -q)'

# Delete all stopped containers.
alias dockercleanc='printf "\n>>> Deleting stopped containers\n\n" && docker rm $(docker ps -a -q)'

# Delete all untagged images.
alias dockercleani='printf "\n>>> Deleting untagged images\n\n" && docker rmi $(docker images -q -f dangling=true)'

# Delete all stopped containers and untagged images.
alias dockerclean='dockercleanc || true && dockercleani'

# Restart docker
alias restart-docker='sudo /etc/init.d/docker stop && sleep 2 && sudo /etc/init.d/docker start'
