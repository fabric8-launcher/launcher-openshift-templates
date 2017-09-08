FROM registry.centos.org/kbsingh/openshift-nginx:latest
MAINTAINER "Aditya Konarde <akonarde@redhat.com>"

#Set LANG
ENV LANG=en_US.utf8

# Set user to root
USER root

# Clear out the default nginx config and HTML content
RUN rm -rf /etc/nginx/conf.d/default.conf &&\
    rm /usr/share/nginx/html/*

# Copy the entrypoint script
ADD cico/scripts/run.sh /usr/bin/

# Copy the nginx.conf to the image
ADD cico/root /

RUN chgrp -R 0 /var/log/nginx &&\
    chmod -R g+rw /var/log/nginx &&\
    chmod +x /usr/bin/run.sh

USER 1001

ENTRYPOINT ["/usr/bin/run.sh"]
