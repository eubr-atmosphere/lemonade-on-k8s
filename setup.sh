#!/bin/bash
set -e
cecho(){
    RED="\033[0;31m"
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    # ... ADD MORE COLORS
    NC='\033[0m' # No Color

    printf "${!1}${2} ${NC}\n"
    read
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

# MySQL port is exposed in host
MYSQL_NODE_PORT=33070 

# Lemonade Citrus port. This is the port exposed in nodes
# and that allows access to Lemoande web interface
CITRUS_PORT=35001

# Lemonade Secret is used by services to authenticate when calling APIs
# Please, use a different token, otherwise, it can open to attacks
AUTH_TOKEN=9740600

export NAMESPACE STORAGE_PATH KUBECTL MYSQL_NODE_PORT CITRUS_PORT AUTH_TOKEN

cecho "GREEN"  "Installing 🍋 Lemonade in the namespace ${NAMESPACE}"
cecho "GREEN" "Creating namespace ${NAMESPACE} in Kubernetes"
cat ./config/namespace.yaml | envsubst #| $KUBECTL apply -f -

cecho "GREEN"  "Creating persistent volume ${NAMESPACE}-pv used by MySQL (base path ${STORAGE_PATH})"
cat ./config/mysql-data-pv.yaml | envsubst #| $KUBECTL apply -f -n $NAMESPACE -

cecho "GREEN" "Creating MySQL persistent volume clain mysql-data-pvc"
cat ./config/mysql-data-pvc.yaml | envsubst # | $KUBECTL apply -f -n $NAMESPACE -

cecho "GREEN"  "Installing MySQL service port=${MYSQL_NODE_PORT}"
cat ./config/mysql-deployment.yaml | envsubst #| $KUBECTL apply -f -n $NAMESPACE -

cecho "GREEN"  "Installing Redis service"
cat ./config/redis-deployment.yaml | envsubst #| $KUBECTL apply -f -n    $NAMESPACE -

cecho "GREEN"  "Mapping many services config files"

# Used by Limonero and Juicer
##$KUBECTL create configmap hdfs-site --from-file extra/hdfs-site.xml -n ${NAMESPACE}
# Used by Citrus
##$KUBECTL create configmap nginx-config --from-file extra/nginx.conf -n ${NAMESPACE}

cat ./extra/caipirinha-config.yaml  | envsubst #| $KUBECTL create configmap caipirinha-config --from-file -n ${NAMESPACE} -
cat ./extra/juicer-config.yaml  | envsubst #| $KUBECTL create configmap juicer-config --from-file -n ${NAMESPACE} -
cat ./extra/limonero-config.yaml  | envsubst #| $KUBECTL create configmap limonero-config --from-file -n ${NAMESPACE} -
cat ./extra/stand-config.yaml  | envsubst #| $KUBECTL create configmap stand-config --from-file -n ${NAMESPACE} -
cat ./extra/tahiti-config.yaml  | envsubst #| $KUBECTL create configmap tahiti-config --from-file -n ${NAMESPACE} -
cat ./extra/database.yml | envsubst #| $KUBECTL create configmap thorn-config --from-file extra/database.yml -n ${NAMESPACE} -

cecho "GREEN"  "Creating persistent volume hdfs-${NAMESPACE}-pv used by HDFS (base path ${STORAGE_PATH})"
cat ./config/hdfs-pv.yaml | envsubst #| $KUBECTL apply -f -n $NAMESPACE -
cecho "GREEN" "Creating HDFS persistent volume clain limonero-data-pvc"
cat ./config/hdfs-pvc.yaml | envsubst # | $KUBECTL apply -f -n $NAMESPACE -

cecho "GREEN"  "Installing Lemonade Citrus + nginx services using port ${CITRUS_PORT}"
cat ./config/citrus-deployment.yaml | envsubst #| $KUBECTL apply -f -n    $NAMESPACE -

cecho "GREEN"  "Installing Lemonade Caipirinha service"
cat ./config/caipirinha-deployment.yaml | envsubst #| $KUBECTL apply -f -n    $NAMESPACE -

cecho "GREEN"  "Installing Lemonade Juicer service"
cat ./config/juicer-deployment.yaml | envsubst #| $KUBECTL apply -f -n    $NAMESPACE -

cecho "GREEN"  "Installing Lemonade Limonero service"
cat ./config/limonero-deployment.yaml | envsubst #| $KUBECTL apply -f -n    $NAMESPACE -

# cecho "GREEN"  "Installing Lemonade Seed service"
# cat ./config/seed-deployment.yaml | envsubst #| $KUBECTL apply -f -n    $NAMESPACE -

cecho "GREEN"  "Installing Lemonade Stand service"
cat ./config/stand-deployment.yaml | envsubst #| $KUBECTL apply -f -n    $NAMESPACE -

cecho "GREEN"  "Installing Lemonade Tahiti service"
cat ./config/tahiti-deployment.yaml | envsubst #| $KUBECTL apply -f -n    $NAMESPACE -

cecho "GREEN"  "Installing Lemonade Thorn service"
cat ./config/thorn-deployment.yaml | envsubst #| $KUBECTL apply -f -n    $NAMESPACE -

HOSTNAME=`hostname -A`
cecho "GREEN"  "Done. You may access Lemonade by this URL: http://${HOSTNAME%% }:${CITRUS_PORT}"

cecho "RED" "Thank you for flying with us!"
