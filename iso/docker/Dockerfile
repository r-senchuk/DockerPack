FROM boot2docker/boot2docker

ADD . $ROOTFS/data/

ENV TCZ_DEPS_ADDITIONAL    file nano \
                           acl attr rsync \
                           readline bash

# Install the TCZ dependencies
RUN for dep in $TCZ_DEPS_ADDITIONAL; do \
    echo "Download $TCL_REPO_BASE/tcz/$dep.tcz" &&\
        curl -fL -o /tmp/$dep.tcz $TCL_REPO_BASE/tcz/$dep.tcz && \
        unsquashfs -f -d $ROOTFS /tmp/$dep.tcz && \
        rm -f /tmp/$dep.tcz ;\
    done

RUN /make_iso.sh

CMD ["cat", "boot2docker.iso"]