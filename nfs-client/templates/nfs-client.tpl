---
apiVersion: v1
kind: Namespace
metadata:
  name: ${project} 
  annotations:
    openshift.io/node-selector: ""
  labels:
    openshift.io/cluster-monitoring: "true"
---
allowHostDirVolumePlugin: true
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups: []
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'hostmount-anyuid provides all the features of the
      restricted SCC but allows host mounts and any UID by a pod.  This is primarily
      used by the persistent volume recycler. WARNING: this SCC allows host file system
      access as any UID, including UID 0.  Grant with caution.'
  name: ${cluster_name}-hostmount-anyuid
readOnlyRootFilesystem: false
requiredDropCapabilities:
- MKNOD
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users:
- system:serviceaccount:${project}:nfs-client-provisioner
volumes:
- configMap
- downwardAPI
- emptyDir
- hostPath
- nfs
- persistentVolumeClaim
- projected
- secret
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: nfs-client-provisioner
  name: nfs-client-provisioner
  namespace: ${project}
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    app: nfs-client-provisioner
  name: nfs-client-provisioner-runner
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    app: nfs-client-provisioner
  name: run-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    namespace: ${project}
roleRef:
  kind: ClusterRole
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    app: nfs-client-provisioner
  name: leader-locking-nfs-client-provisioner
  namespace: ${project}
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    app: nfs-client-provisioner
  name: leader-locking-nfs-client-provisioner
  namespace: ${project}
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    namespace: ${project}
roleRef:
  kind: Role
  name: leader-locking-nfs-client-provisioner
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-client-provisioner
  labels:
    app: nfs-client-provisioner
  namespace: ${project}
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nfs-client-provisioner
  template:
    metadata:
      annotations:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          image: ${provisioner_image}
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: ${cluster_name}/nfs-client-provisioner
            - name: NFS_SERVER
              value: ${nfs_server}
            - name: NFS_PATH
              value: ${nfs_server_path}/${cluster_name}
      volumes:
        - name: nfs-client-root
          nfs:
            server: ${nfs_server}
            path: ${nfs_server_path}/${cluster_name}
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  labels:
    app: nfs-client-provisioner
  name: nfs-client
  annotations:
    storageclass.kubernetes.io/is-default-class: "${is_default_class}"
provisioner: ${cluster_name}/nfs-client-provisioner
allowVolumeExpansion: true
reclaimPolicy: Delete
parameters:
  archiveOnDelete: "false"

