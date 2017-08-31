#!/bin/bash

# Show command before executing
set -x

# Exit on error
set -e

# Export needed vars
for var in GIT_COMMIT DEVSHIFT_USERNAME DEVSHIFT_PASSWORD DEVSHIFT_TAG_LEN; do
  export $(grep ${var} jenkins-env | xargs)
done
export BUILD_TIMESTAMP=`date -u +%Y-%m-%dT%H:%M:%S`+00:00

# We need to disable selinux for now, XXX
/usr/sbin/setenforce 0

# Get all the deps in
yum -y install docker
yum clean all
service docker start

# Build the app

IMAGE="launchpad-proxy"
REGISTRY="push.registry.devshift.net"
REPOSITORY="${REGISTRY}/openshiftio"

docker build -t ${IMAGE} -f Dockerfile .

TAG=$(echo $GIT_COMMIT | cut -c1-${DEVSHIFT_TAG_LEN})

if [ -n "${DEVSHIFT_USERNAME}" -a -n "${DEVSHIFT_PASSWORD}" ]; then
  docker login -u ${DEVSHIFT_USERNAME} -p ${DEVSHIFT_PASSWORD} ${REGISTRY}
else
  echo "Could not login, missing credentials for the registry"
fi

docker tag ${IMAGE} ${REPOSITORY}/${IMAGE}:$TAG && \
docker push ${REPOSITORY}/${IMAGE}:$TAG && \
docker tag ${IMAGE} ${REPOSITORY}/${IMAGE}:latest && \
docker push ${REPOSITORY}/${IMAGE}:latest
if [ $? -eq 0 ]; then
  echo 'CICO: image pushed, ready to update deployed app'
  exit 0
else
  echo 'CICO: Image push to registry failed'
  exit 2
fi
