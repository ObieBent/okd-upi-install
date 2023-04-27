#!/bin/bash 

CODEBUG=X509ignoreCN=0
OCP_RELEASE='4.10.52'
LOCAL_REGISTRY='local-registry.caas.eazytraining.lab:5000'
LOCAL_REPOSITORY='ocp-4-10-52'
PRODUCT_REPO='openshift-release-dev'
LOCAL_SECRET_JSON='/data/pull-secret.json'
RELEASE_NAME='ocp-release'
ARCHITECTURE='x86_64'

CODEBUG=${CODEBUG} oc adm release mirror --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} --to=${LOCAL_REGISTRY} \
        --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE} --registry-config=${LOCAL_SECRET_JSON}