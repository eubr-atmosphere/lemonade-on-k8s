#!/bin/bash
NAMESPACE=$1

kubectl create serviceaccount jumppod -n $NAMESPACE
kubectl create rolebinding jumppod-rb --clusterrole=admin --serviceaccount=$NAMESPACE:jumppod -n $NAMESPACE
kubectl create serviceaccount spark-sa -n $NAMESPACE
kubectl create rolebinding spark-sa-rb --clusterrole=edit --serviceaccount=$NAMESPACE:spark-sa -n $NAMESPACE
kubectl create clusterrolebinding spark-sa-ra --clusterrole=edit --serviceaccount=$NAMESPACE:spark-sa -n $NAMESPACE
