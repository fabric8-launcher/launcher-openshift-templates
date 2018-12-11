#!/bin/bash

echo This script will install the Launcher in Minishift. Make sure that:
echo 
echo  - Minishift is running 
echo  - You have run oc login previously
echo  - Your GitHub Username is correct [found from git config github.user]: $(git config github.user)
echo  - Your GitHub Token is correct [found from git config github.token]: *REDACTED*
echo 
echo Press any key to continue ...
read 

echo Creating launcher project ...
oc new-project launcher

echo Processing the template and installing ...
oc process --local -f openshift/launcher-template.yaml \
   LAUNCHER_KEYCLOAK_URL= \
   LAUNCHER_KEYCLOAK_REALM= \
   LAUNCHER_MISSIONCONTROL_GITHUB_USERNAME=$(git config github.user) \
   LAUNCHER_MISSIONCONTROL_GITHUB_TOKEN=$(git config github.token) \
   LAUNCHER_MISSIONCONTROL_OPENSHIFT_CONSOLE_URL=$(minishift console --url | sed 's/\/console//') \
   --param-file=released.properties -o yaml | oc create -f -

echo Enabling Launcher Creator
oc set env dc/launcher-frontend LAUNCHER_CREATOR_ENABLED=true

echo All set! Enjoy!
