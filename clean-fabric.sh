#!/bin/bash

# This script removes the services that constitute the Blue Audit application
# logic.

echo "========== Removing Fabric Network Services ============"


for S_FABRIC_SERVICE in  fabric-peer0-org1.yaml            \
	                 fabric-peer1-org1.yaml            \
			 fabric-peer0-org2.yaml           \
                         fabric-peer1-org2.yaml            \
			 fabric-couchdb.yaml               \
			 fabric-orderer.yaml            \
                         fabric-kafka0-service.yaml         \
                         fabric-kafka0-deployment.yaml      \
                         fabric-kafka1-service.yaml         \
                         fabric-kafka1-deployment.yaml      \
                         fabric-kafka2-service.yaml         \
                         fabric-kafka2-deployment.yaml      \
                         fabric-kafka3-service.yaml         \
                         fabric-kafka3-deployment.yaml      \
			 fabric-zookeeper0-service.yaml     \
			 fabric-zookeeper0-deployment.yaml  \
                         fabric-zookeeper1-service.yaml     \
                         fabric-zookeeper1-deployment.yaml  \
                         fabric-zookeeper2-service.yaml     \
                         fabric-zookeeper2-deployment.yaml  \
                         fabric-cli-job.yaml 
do
    echo "- Removing ${S_FABRIC_SERVICE}: kubectl delete -f ${S_FABRIC_SERVICE}"
    kubectl delete -f ${S_FABRIC_SERVICE}
done


echo "- Cleaning Other Fabric Images..."

# Workaround to clean ccenv image
DOCKER_IMAGE_IDS=$(docker images | grep "dev-peer" | awk '{print $3}')
if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" = " " ]; then
        echo "---- No images available for deletion ----"
else
        docker rmi -f $DOCKER_IMAGE_IDS
fi

sleep 5s
echo "======================= [DONE] ========================="
echo ""
kubectl get pods 
