# terraform-modules-ocp
This is a collection of terraform modules that configure OCP.

| module | function        |
|----------------|--------------|
| [certs](certs/README.md)   | Configures certificates for the cluster with self-signed certificates. A root CA or intermediate certificate and key are needed |
| [dyndns](dyndns/README.md)  | Updates DNS with entries for API and Ingress VIPs as well as cluster hosts |
| [htpasswd](httpasswd/README.md) | Configures an HTPasswd oAuth identity provider     |
| [iscsi](iscsi/README.md) | Configures the opensource [iscsi/targetd provisioner](https://github.com/kubernetes-retired/external-storage/tree/master/iscsi/targetd) |
| [ldap](ldap/README.md) | Configures an LDAP/MSAD oAuth identity provider |
| [nfs](nfs/README.md) | Configures the opensource [nfs ganesha provisioner](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner) |
| [nfs-client](nfs-client/README.md) | Configures the opensource [nfs subdir provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) |
| [wait-for](wait-for/README.md) | Runs openshift-install wait-for tasks to check OpenShift installation status |

As with most modules you would look at the variables.tf file to determine what the inputs are for the module. Two other inputs of note:
- The source points to where the module source is located. It can be a local directory or a git source repo.
- The depends_on variable allows you to create dependencies between resources in scenarios where one resource depends on another but there is no built in dependency through output variables. If dependencies are not needed the parameter can be removed. 
