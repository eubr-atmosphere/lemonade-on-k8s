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

##
# Change the following variables accordingly
##
if [ -z $1 ]; then
    echo "NAMESPACE argument not set. You need to inform a NAMESPACE as an argument."
    echo "Example:  ./setup.sh lemonade-dev"
    exit 1
fi
NAMESPACE=$1

# Where data files required by Lemonade are going to be stored. 
# In a cluster deployment, it must be a distributed file system.
STORAGE_PATH=/srv/lemonade

# Path for kubectl program
KUBECTL=kubectl

# MySQL port is exposed in host (verify K8s supported range: 30000-32767)
# If you don't want to expose this port, edit the file ./k8s/mysql-deployment.yaml
MYSQL_NODE_PORT=31006 

# Lemonade Citrus port. This is the port exposed in nodes (verify K8s supported range: 30000-32767)
# and that allows access to Lemoande web interface
CITRUS_PORT=31001

# Lemonade Secret is used by services to authenticate when calling APIs
# Please, use a different token, otherwise, it can open to attacks
AUTH_TOKEN=9740600

export NAMESPACE STORAGE_PATH KUBECTL MYSQL_NODE_PORT CITRUS_PORT AUTH_TOKEN

cecho "GREEN"  "Installing 🍋 Lemonade in the namespace ${NAMESPACE}"
cecho "GREEN" "Creating namespace ${NAMESPACE} in Kubernetes"
envsubst < ./k8s/namespace.yaml | $KUBECTL apply -f -

cecho "GREEN"  "Creating persistent volume mysql-data-$NAMESPACE-pv used by MySQL (base path ${STORAGE_PATH}). Please, be sure that the path is correct and it points to a distributed filesystem!"
envsubst < ./k8s/mysql-data-pv.yaml | $KUBECTL apply -n $NAMESPACE -f -

cecho "GREEN" "Creating MySQL persistent volume clain mysql-data-pvc in mysql-data-${NAMESPACE}-pv"
envsubst < ./k8s/mysql-data-pvc.yaml | $KUBECTL apply -n $NAMESPACE -f -

cecho "GREEN"  "Installing MySQL service port=${MYSQL_NODE_PORT}"
envsubst < ./k8s/mysql-deployment.yaml | $KUBECTL apply -n $NAMESPACE -f -

cecho "GREEN"  "Installing Redis service"
envsubst < ./k8s/redis-deployment.yaml | $KUBECTL apply -n $NAMESPACE -f -

cecho "GREEN"  "Mapping many services config files"
# Used by Juicer
$KUBECTL create configmap hdfs-site --from-file config/hdfs-site.xml -n ${NAMESPACE} -o yaml --dry-run | $KUBECTL replace -f -
# Used by Citrus
$KUBECTL create configmap nginx-config --from-file config/nginx.conf -n ${NAMESPACE} -o yaml --dry-run | $KUBECTL replace -f -

# Creates or replaces configmaps. See https://stackoverflow.com/a/38216458/1646932
envsubst < ./config/caipirinha-config.yaml > /tmp/caipirinha-config.yaml && $KUBECTL create configmap caipirinha-config --from-file /tmp/caipirinha-config.yaml -n ${NAMESPACE} -o yaml --dry-run | $KUBECTL replace -f -
envsubst < ./config/juicer-config.yaml > /tmp/juicer-config.yaml && $KUBECTL create configmap juicer-config --from-file /tmp/juicer-config.yaml -n ${NAMESPACE} -o yaml --dry-run | $KUBECTL replace -f -
envsubst < ./config/limonero-config.yaml > /tmp/limonero-config.yaml &&  $KUBECTL create configmap limonero-config --from-file /tmp/limonero-config.yaml -n ${NAMESPACE} -o yaml --dry-run | $KUBECTL replace -f -
envsubst < ./config/stand-config.yaml > /tmp/stand-config.yaml && $KUBECTL create configmap stand-config --from-file /tmp/stand-config.yaml -n ${NAMESPACE} -o yaml --dry-run | $KUBECTL replace -f -
envsubst < ./config/tahiti-config.yaml > /tmp/tahiti-config.yaml && $KUBECTL create configmap tahiti-config --from-file /tmp/tahiti-config.yaml -n ${NAMESPACE} -o yaml --dry-run | $KUBECTL replace -f -
$KUBECTL create configmap thorn-config --from-file ./config/database.yml -n ${NAMESPACE} -o yaml --dry-run | $KUBECTL replace -f -

cecho "GREEN"  "Creating persistent volume hdfs-${NAMESPACE}-pv used by HDFS (base path ${STORAGE_PATH})"
envsubst < ./k8s/hdfs-pv.yaml | $KUBECTL apply -n $NAMESPACE -f -
cecho "GREEN" "Creating HDFS persistent volume clain limonero-data-pvc"
envsubst < ./k8s/hdfs-pvc.yaml | $KUBECTL apply -n $NAMESPACE -f -

cecho "GREEN"  "Installing Lemonade Citrus + nginx services using port ${CITRUS_PORT}"
envsubst < ./k8s/citrus-deployment.yaml | $KUBECTL apply -n $NAMESPACE -f -

cecho "GREEN"  "Installing Lemonade Caipirinha service"
envsubst < ./k8s/caipirinha-deployment.yaml | $KUBECTL apply -n $NAMESPACE -f -

cecho "GREEN"  "Installing Lemonade Juicer service"
envsubst < ./k8s/juicer-deployment.yaml | $KUBECTL apply -n $NAMESPACE -f -

cecho "GREEN"  "Installing Lemonade Limonero service"
envsubst < ./k8s/limonero-deployment.yaml | $KUBECTL apply -n $NAMESPACE -f -

# Under development
# cecho "GREEN"  "Installing Lemonade Seed service"
# envsubst < ./k8s/seed-deployment.yaml | $KUBECTL apply -n $NAMESPACE -f -

cecho "GREEN"  "Installing Lemonade Stand service"
envsubst < ./k8s/stand-deployment.yaml | $KUBECTL apply -n $NAMESPACE -f -

cecho "GREEN"  "Installing Lemonade Tahiti service"
envsubst < ./k8s/tahiti-deployment.yaml | $KUBECTL apply -n $NAMESPACE -f -

cecho "GREEN"  "Installing Lemonade Thorn service"
envsubst < ./k8s/thorn-deployment.yaml | $KUBECTL apply -n $NAMESPACE -f -

HOSTNAME=`hostname -A`
cecho "GREEN"  "Done. You may access Lemonade by this URL: http://${HOSTNAME%% }:${CITRUS_PORT}"

cecho "RED" "Thanks for flying with us! Hope to see you soon!"

