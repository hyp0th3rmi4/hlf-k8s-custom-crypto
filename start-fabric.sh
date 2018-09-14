#!/bin/bash

# This script brings up a local version of the Hyperledger Fabric Network.


echo "============== Starting Fabric Services ================"



echo "- Creating Fabric Supporting Services"
echo ""
echo "  - Zookepeer Services: kubectl create -f fabric-zookeeper0-service.yaml"
kubectl create -f fabric-zookeeper0-service.yaml
echo "  - Zookeeper Deployments: kubectl create -f fabric-zookeeper0-deployment.yaml"
kubectl create -f fabric-zookeeper0-deployment.yaml

echo "  - Zookepeer Services: kubectl create -f fabric-zookeeper1-service.yaml"
kubectl create -f fabric-zookeeper1-service.yaml
echo "  - Zookeeper Deployments: kubectl create -f fabric-zookeeper1-deployment.yaml"
kubectl create -f fabric-zookeeper1-deployment.yaml

echo "  - Zookepeer Services: kubectl create -f fabric-zookeeper2-service.yaml"
kubectl create -f fabric-zookeeper2-service.yaml
echo "  - Zookeeper Deployments: kubectl create -f fabric-zookeeper2-deployment.yaml"
kubectl create -f fabric-zookeeper2-deployment.yaml

echo "  - [waiting 5s]"
sleep 5

echo "  - Kafka Services: kubectl create -f fabric-kafka0-service.yaml"
kubectl create -f fabric-kafka0-service.yaml
echo "  - Kafka Deployments: kubectl create -f fabric-kafka0-deployment.yaml"
kubectl create -f fabric-kafka0-deployment.yaml

echo "  - Kafka Services: kubectl create -f fabric-kafka1-service.yaml"
kubectl create -f fabric-kafka1-service.yaml
echo "  - Kafka Deployments: kubectl create -f fabric-kafka1-deployment.yaml"
kubectl create -f fabric-kafka1-deployment.yaml

echo "  - Kafka Services: kubectl create -f fabric-kafka2-service.yaml"
kubectl create -f fabric-kafka2-service.yaml
echo "  - Kafka Deployments: kubectl create -f fabric-kafka2-deployment.yaml"
kubectl create -f fabric-kafka2-deployment.yaml

echo "  - Kafka Services: kubectl create -f fabric-kafka3-service.yaml"
kubectl create -f fabric-kafka3-service.yaml
echo "  - Kafka Deployments: kubectl create -f fabric-kafka3-deployment.yaml"
kubectl create -f fabric-kafka3-deployment.yaml

# Create couchdb
echo "  - CouchDb Service: kubectl create -f fabric-couchdb.yaml"
kubectl create -f fabric-couchdb.yaml

echo "  - [waiting 5s]"
sleep 5s

# Create Orderer 
echo "  - Orderer Service: kubectl create -f fabric-orderer.yaml"
kubectl create -f fabric-orderer.yaml

echo "  - [waiting 5s]"
sleep 5s

echo "- Creating Fabric Services..."
for S_FABRIC_SERVICE in fabric-peer0-org1.yaml   \
		        fabric-peer1-org1.yaml   \
		        fabric-peer0-org2.yaml   \
		        fabric-peer1-org2.yaml

do
    echo "  - Creating Service ${S_FABRIC_SERVICE}: kubectl create -f ${S_FABRIC_SERVICE}"
    kubectl create -f ${S_FABRIC_SERVICE}
done
echo ""

echo "  - [waiting 20s for Fabric network nodes to sync ]"
sleep 20s

kubectl create -f fabric-cli-job.yaml

echo "  - [waiting 10s for cli container to create ]"
sleep 10s

echo "======================= [DONE] ========================="

kubectl logs -f $(kubectl get pod --selector io.kompose.job=cli -o name)
