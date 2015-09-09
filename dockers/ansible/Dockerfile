FROM python:2.7

MAINTAINER Ross Ivantsiv <ross@datasyntax.ua>

# Install docker-compose with dependencies
RUN pip install ansible

# This image is made to run docker-compose
ENTRYPOINT ["ansible-playbook"]

# Some default ansible configuratio and keys
RUN mkdir -p /etc/ansible
RUN mkdir -p /keys
ADD config/ansible.cfg /etc/ansible/ansible.cfg
ADD keys/vagrant /keys/vagrant
RUN chmod 600 /keys/vagrant

# put the docker-compose.yml into the /app dir
WORKDIR /app

ENV ANSIBLE_HOST_KEY_CHECKING=False
ENV PYTHONUNBUFFERED=1

# Print version as default
CMD ["--version"]