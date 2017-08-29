#!/bin/bash

# Show command before executing
set -x

# Exit on error
set -e

# Export needed vars
for var in BUILD_NUMBER BUILD_URL GIT_COMMIT DEVSHIFT_USERNAME DEVSHIFT_PASSWORD DEVSHIFT_TAG_LEN; do
  export $(grep ${var} jenkins-env | xargs)
done
export BUILD_TIMESTAMP=`date -u +%Y-%m-%dT%H:%M:%S`+00:00

# We need to disable selinux for now, XXX
/usr/sbin/setenforce 0

# Get all the deps in
yum -y install docker
yum clean all
service docker start

# Build builder image
#mkdir -p dist && docker run --detach=true --name=launchpad-proxy -t -v $(pwd)/dist:/dist:Z -e BUILD_NUMBER -e BUILD_URL -e BUILD_TIMESTAMP launchpad-proxy
docker build -t launchpad-proxy -f Dockerfile . && \

TAG=$(echo $GIT_COMMIT | cut -c1-${DEVSHIFT_TAG_LEN})
REGISTRY="push.registry.devshift.net"

if [ -n "${DEVSHIFT_USERNAME}" -a -n "${DEVSHIFT_PASSWORD}" ]; then
  docker login -u ${DEVSHIFT_USERNAME} -p ${DEVSHIFT_PASSWORD} ${REGISTRY}
else
  echo "Could not login, missing credentials for the registry"
fi

docker tag launchpad-proxy ${REGISTRY}/openshiftio/launchpad-proxy:$TAG && \
docker push ${REGISTRY}/openshiftio/launchpad-proxy:$TAG && \
docker tag launchpad-proxy ${REGISTRY}/openshiftio/launchpad-proxy:latest && \
docker push ${REGISTRY}/openshiftio/launchpad-proxy:latest
if [ $? -eq 0 ]; then
  echo 'CICO: image pushed, ready to update deployed app'
  exit 0
else
  echo 'CICO: Image push to registry failed'
  exit 2
fi
#  else
#    echo 'CICO: app tests Failed'
#    exit 1
#  fi
#else
#  echo 'CICO: functional tests FAIL'
#  exit 1
#fi
