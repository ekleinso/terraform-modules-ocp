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
apiVersion: v1
data:
  password: ${password}
  username: ${username}
kind: Secret
metadata:
  name: targetd-account
  namespace: ${project}
type: Opaque
---
kind: ClusterRole
apiVersion: authorization.openshift.io/v1
metadata:
  labels:
    app: iscsi-provisioner
  name: iscsi-provisioner-runner
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
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
kind: ClusterRoleBinding
apiVersion: authorization.openshift.io/v1
metadata:
  labels:
    app: iscsi-provisioner
  name: run-iscsi-provisioner
subjects:
  - kind: ServiceAccount
    name: iscsi-provisioner
    namespace: ${project}
roleRef:
  kind: ClusterRole
  name: iscsi-provisioner-runner
  apiGroup: v1
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: iscsi-provisioner
  name: iscsi-provisioner
  namespace: ${project}
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  labels:
    app: iscsi-provisioner
  name: ${storage_class}
provisioner: ${cluster_name}/iscsi
parameters:
  targetPortal: ${server}:${port}
  iqn: ${wwn}
  iscsiInterface: default
  volumeGroup: ${volumegroup}
  initiators: ${initiators}
  fsType: ${fstype}
  chapAuthDiscovery: "false"
  chapAuthSession: "false"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: iscsi-provisioner
  name: iscsi-provisioner
  namespace: ${project}
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: iscsi-provisioner
  template:
    metadata:
      labels:
        app: iscsi-provisioner
    spec:
      containers:
        - name: iscsi-provisioner
          imagePullPolicy: Always
          image: ${image}
          args:
            - "start"
          env:
            - name: PROVISIONER_NAME
              value: ${cluster_name}/iscsi
            - name: LOG_LEVEL
              value: debug
            - name: TARGETD_USERNAME
              valueFrom:
                secretKeyRef:
                  name: targetd-account
                  key: username
            - name: TARGETD_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: targetd-account
                  key: password
            - name: TARGETD_ADDRESS
              value: ${server}
      nodeSelector:
        node-role.kubernetes.io/master: ""
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
      serviceAccount: iscsi-provisioner
