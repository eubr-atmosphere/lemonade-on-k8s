kubectl create configmap hdfs-site-dev --from-file /home/ubuntu/kubernetes/hdfs-site.xml
kubectl create configmap caipirinha-config-dev --from-file /home/ubuntu/docker-lemonade/config/caipirinha-config.yaml -n lemonade-dev
kubectl create configmap nginx-config-dev --from-file /home/ubuntu/docker-lemonade/config/nginx.conf -n lemonade-dev
kubectl create configmap thorn-dev --from-file /home/ubuntu/docker-lemonade/config/database.yml -n lemonade-dev
kubectl create configmap thorn-config-dev --from-file /home/ubuntu/docker-lemonade/config/database.yml -n lemonade-dev
kubectl create configmap juicer-config-dev --from-file /home/ubuntu/docker-lemonade/config/juicer-config.yaml -n lemonade-dev
