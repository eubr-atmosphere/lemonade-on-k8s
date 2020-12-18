#!/bin/bash
set -e
cecho(){
    RED="\033[0;31m"
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    # ... ADD MORE COLORS
    NC='\033[0m' # No Color

    printf "${!1}${2} ${NC}\n"
}
if [ -z $1 ]; then
    echo "NAMESPACE argument not set. You need to inform a NAMESPACE as an argument."
    echo "Example:  ./accounts.sh lemonade-dev"
    exit 1
fi

NAMESPACE=$1
export NAMESPACE
# Path for kubectl program
KUBECTL=kubectl

cecho "GREEN" "Creating namespace ${NAMESPACE} in Kubernetes"
envsubst < ./k8s/namespace.yaml | $KUBECTL apply -f -

cecho "GREEN" "Creating accounts"

kubectl create serviceaccount jumppod -n $NAMESPACE
kubectl create rolebinding jumppod-rb --clusterrole=admin --serviceaccount=$NAMESPACE:jumppod -n $NAMESPACE
kubectl create serviceaccount spark-sa -n $NAMESPACE
kubectl create rolebinding spark-sa-rb --clusterrole=edit --serviceaccount=$NAMESPACE:spark-sa -n $NAMESPACE
kubectl create clusterrolebinding spark-sa-ra --clusterrole=edit --serviceaccount=$NAMESPACE:spark-sa -n $NAMESPACE
