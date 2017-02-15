#!/bin/bash
source /etc/profile

if [ "${environmentAccount}" = "Non" ];
then
   export GLUSTER_SHARE='gluster.uat.ogsp.bfsonlinebanking.syd.non.c1.macquarie.com';
elif [ "${environmentAccount}" = "Prod" ];
then
   export GLUSTER_SHARE='gluster.prod.ogsp.bfsonlinebanking.syd.c1.macquarie.com';
fi
export GUID="$(/usr/local/bin/pipeline_dns -c ansible | cut -d '.' -f 2)";
oc create -f - <<API
apiVersion: v1
kind: PersistentVolume
metadata:
  name: prometheus-${GUID}
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    endpoints: glusterfs-cluster 
    server: ${GLUSTER_SHARE}
    path: /gluster/${GUID}/prometheus
    readOnly: false
API


oc create -f - <<API
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: prometheus-claim
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
API

oc volume dc/prometheus \
          --add --overwrite --name=data-volume \
          --type=persistentVolumeClaim --claim-name=prometheus-claim 2>&1 | tee -a $LOGFILE
