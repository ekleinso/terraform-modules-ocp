until [ $(( $(binaries/oc get clusteroperators -o json | jq -r ' .items[] | .status.conditions[] | select(.type == "Degraded") | .status ' | uniq | grep -c True) + $(binaries/oc get clusteroperators -o json | jq -r ' .items[] | .status.conditions[] | select(.type == "Progressing") | .status ' | uniq | grep -c True) + $(binaries/oc get clusteroperators -o json | jq -r ' .items[] | .status.conditions[] | select(.type == "Available") | .status ' | uniq | grep -c False) )) == 0 ]
do
  sleep 10
done
