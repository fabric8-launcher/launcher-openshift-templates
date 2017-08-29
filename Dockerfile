FROM registry.centos.org/kbsingh/openshift-nginx:latest
MAINTAINER "Aditya Konarde <akonarde@redhat.com>"

#Set LANG
ENV LANG=en_US.utf8

# Set user to root
USER root

# Clear out the default config
RUN rm -rf /etc/nginx/conf.d/default.conf

# Clear out the existing HTML content
RUN rm /usr/share/nginx/html/*

# Copy the entrypoint script
ADD scripts/run.sh /usr/bin/

# Copy the nginx.conf to the image
ADD root /

RUN chmod -R +r /usr/share/nginx/html
RUN chmod -R +rw /var/log/nginx
RUN chmod -R a+rw /etc/nginx

USER 1001

ENTRYPOINT ["/usr/bin/run.sh"]
