#!/bin/bash

#
# This script can be used to generate the unified template for the entire Launch application
#
# Just run it and pipe its output to "openshift/launch-template.yaml".
# It is required to have the missioncontrol, backend and frontend modules available
# as sibling folders of this "launchpad-templates" project.
#

main() {
    DIR=$(dirname $(readlink -f $0))
    cat $DIR/../openshift/split/launchpad-header.yaml
    echo "parameters:"
    printTemplateParams $DIR/../openshift/split/launchpad-configmap.yaml
    printTemplateParams $DIR/../../launchpad-missioncontrol/openshift/template.yaml "MISSIONCONTROL"
    printTemplateParams $DIR/../../launchpad-backend/openshift/template.yaml "BACKEND"
    printTemplateParams $DIR/../../launchpad-frontend/openshift/template.yaml "FRONTEND"
    printTemplateParams $DIR/../openshift/proxy/nginx.yaml "PROXY"
    echo "objects:"
    printTemplateObjects $DIR/../openshift/split/launchpad-configmap.yaml
    printTemplateObjects $DIR/../openshift/split/launchpad-imagestreams.yaml
    printTemplateObjects $DIR/../../launchpad-missioncontrol/openshift/template.yaml "MISSIONCONTROL"
    printTemplateObjects $DIR/../../launchpad-backend/openshift/template.yaml "BACKEND"
    printTemplateObjects $DIR/../../launchpad-frontend/openshift/template.yaml "FRONTEND"
    printTemplateObjects $DIR/../openshift/proxy/nginx.yaml "PROXY"
}

printTemplateParams() {
    export modulename=$2
    perl < $1 -e '
    use strict;
    use warnings;
    my $modname=$ENV{"modulename"};
    my $start=0;
    while (my $line = <>) {
        if ($start == 1) {
            if ($line =~ /^[\s-]/) {
                $line =~ s/IMAGE/${modname}_IMAGE/g;
                print $line;
            } else {
                exit;
            }
        }
        if ($line =~ /parameters:/) {
            $start=1;
        }
    }'
}

printTemplateObjects() {
    export modulename=$2
    perl < $1 -e '
    use strict;
    use warnings;
    my $modname=$ENV{"modulename"};
    my $start=0;
    while (my $line = <>) {
        if ($start == 1) {
            if ($line =~ /^[\s-]/) {
                $line =~ s/\$\{IMAGE}/\${${modname}_IMAGE}/g;
                $line =~ s/\$\{IMAGE_TAG}/\${${modname}_IMAGE_TAG}/g;
                print $line;
            } else {
                exit;
            }
        }
        if ($line =~ /objects:/) {
            $start=1;
        }
    }'
}

main"$@"

