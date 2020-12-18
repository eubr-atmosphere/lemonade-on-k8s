# lemonade-on-k8s
Configuration files to install Lemonade on Kubernetes

This installation is using namespaces. By using them, we may have multiple instances of Lemonade deployed in a Kubernetes cluster without worrying about names collision. 
Please, have a look into the setup.sh file. Some parameters must be defined in it. In order to execute it, please run:

```
$ ./accounts.sh <NAMESPACE>
$ ./setup.sh <NAMESPACE>
```

Theoretically, you can run the script with same namespace because it just replace the previous configuration, except for the accounts. 
If a pod fails to start, try to delete it. The deployment creates it again.
Some services require access to a storage. For example, MySQL, Juicer and Limonero. Ideally, a distributed file system (DFS) would be recommended, otherwise, when a pod restarts, 
if it is allocated to a different node, it would not find the path and would recreate it. 
In the case of Limonero and Juicer, if they are in different nodes without a DFS, Juicer would not find files uploaded in Limonero. 
