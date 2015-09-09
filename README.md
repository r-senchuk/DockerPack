# DockerPack
DockerPack is a toolbox for developer, which helps managing multiple dockerized projects, supporting all major OSes (Windows, OSX, Linux) and virtual environments (VirtualBox, Parallels etc).

Inside DockerPack some core containers are included:
* jwilder/nginx-proxy  - provides HTTP and HTTPS proxy for multiple running containers
* jderusse/dns-gen     - provides dynamic DNS resolution for containers & docker host
* keyvanfatehi/sinopia - private nodejs repository for caching nodejs modules (makes npm install ultra-fast in docker)


# Setup Instructions

## Linux Users

Since Linux is the native enviroment for docker it's the most easy way if setup. Just run provision.sh script and all of your core containers will be setup. No virtualized environment is engaged in this.
