# DockerPack
DockerPack is a toolbox for developer, which helps managing multiple dockerized projects, supporting all major OSes (Windows, OSX, Linux) and virtual environments (VirtualBox, Parallels etc).

Inside DockerPack some global containers are included:
* nginx-proxy  - provides HTTP and HTTPS proxy for multiple running containers
* jderusse/dns-gen     - provides dynamic DNS resolution for containers & docker host
* sinopia - private nodejs repository for caching nodejs modules (makes npm install ultra-fast in docker)

### Installation

Differs depending on the OS. Please refer to wiki.

### Provision script usage

* `provision.sh`  run everything
* `provision.sh --global-containers` restart global containers (nginx-proxy, dns, sinopia)
* `provision.sh --rebuild` rebuild docker images and restart global containers (nginx-proxy, dns, sinopia)


