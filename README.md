# terraform-modules-ocp
This is a collection of terraform modules that configure OCP.

| module | function        |
|----------------|--------------|
| certs   | Configures certificates for the cluster with self-signed certificates. A root CA or intermediate certificate and ke arer neededd |
| dyndns  | Updates DNS with entries for API and Ingress VIPs as well as cluster hosts |
| htpasswd | Configures an HTPasswd oAuth identity provider     |
| iscsi | Configures the opensource [iscsi/targetd provisioner](https://github.com/kubernetes-retired/external-storage/tree/master/iscsi/targetd) |
| ldap | Configures an LDAP/MSAD oAuth identity provider |
| nfs | Configures the opensource [nfs ganesha provisioner](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner) |
| nfs-client | Configures the opensource [nfs subdir provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) |
| wait-for | Runs openshift-install wait-for tasks to check OpenShift installation status |