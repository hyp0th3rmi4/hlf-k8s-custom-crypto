# Hyperledger Fabric v1.2 on Kubernetes with Custom TLS 

This repository contains the example code on how to setup the Hyperledger Fabric v1.2 on Kubernetes with custom Transport Layer Security.

The sample code is of support to the DeveloperWorks article that discusses in details how to setup the environment on a single Kubernetes cluster (with one of more nodes) and establish communication among the peers and the different services with transport layer security and import your own SSL certificates.

## Setup Instructions

The installation process is discussed in detail in the associated [DeveloperWorks Article](TBD) but here are some quick steps on how to setup your own environment. The setup instructions are based on a RedHat Enterprise Linux operating systems.

### Installation of Docker Enterprise 

1. Remove any previous docker installation.

```
sudo yum remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-selinux \
                docker-engine-selinux \
                docker-engine \
                docker-ce
```

2. Locate your own license in the Docker Store for Docker Enterprise and replace it to *<DOCKER_REPO_URL>* in the script below.

```
# remove existing docker repositories
sudo rm /etc/yum.repos.d/docker*.repo

# store the url to the docker repository as a YUM variable
export DOCKER_URL="<DOCKER_REPO_URL>"
sudo -E sh -c 'echo "$DOCKER_URL/rhel" > /etc/yum/vars/dockerurl'

# store the OS version string as a YUM variable. We assume here that RHEL
# version is 7. You can also use a more specific version.
sudo -E sh -c 'echo "7" > /etc/yum/vars/dockerosversion'

# install the additional packages required by the devicemapper storage driver
sudo yum install yum-utils \
                 device-mapper-persistent-data \ 
                 lvm2 

# enable the extras RHEL repository. This provides access to the 
# container-selinux package required by docker-ee
sudo yum-config-manager --enable rhel-7-server-extras-rpms

# add the Docker EE stable repository
sudo -E yum-config-manager --add-repo "$DOCKER_URL/rhel/docker-ee.repo"
```

3. Install Docker Enterprise Edition.

```
sudo yum install docker-ee
sudo systemctl start docker
```

4. Verify Fingerprint (77FE DA13 1A83 1D29 A418 D3E8 99E5 FF2E 7668 2BC9) and test your docker installation with the following command:

```
sudo docker run hello-world
```

### Install Kubernetes

1. Configure the Kubernetes reposutories, and install the base Kubernetes components

```
# configure YUM to access the Kubernetes repository
sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# disable SELinux, we need to do this in order to allow containers to access 
# th file system, this is needed for instance by pod networks
sudo setenforce 0

# install the packages
sudo yum install -y kubelet kubeadm kubectl

# enable the kubelet service
sudo systemctl enable kubelet
```

2. Configure the `cgroup` driver for Docker. This is to ensure that both Kubernetes and Docker Enterprise use the same cgroup driver. The commands to verify that the driver is the same are the following:

```
docker info | grep -i cgroup
cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# run the following commands if the drivers do not match
#
# sudo sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
#
# after the update kubelet restart is needed.
#
# sudo systemctl daemon-reload
# sudo systemctl restart kubelet
```

3. Configure Kubernetes to run on single node cluster. We will be using the `kubeadm`command to automatically configure the cluster according to the best practices.

```
sudo kubeadm init --pod-network-cidr=192.168.0.16
```

4. Copy the Kubernetes configuration into your home directory.

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

5. Install a networking plugin (example shown for Calico)

```
# install the etcd service...
kubectl apply -f https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/etcd.yaml

# install the role-based access control (RBAC) roles...
kubectl apply -f https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/rbac.yaml

# install the role-based access control (RBAC) roles...
kubectl apply -f https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/calico.yaml
```
6. Verify your installation of Calico. If the installation is successful, you should see something similar to the following output:

```
NAMESPACE    NAME                                READY  STATUS   RESTARTS  AGE
kube-system  calico-etcd-x2482                   1/1    Running  0         2m
kube-system  calico-kube-controllers-6f8d4-tgb   1/1    Running  0         2m
kube-system  calico-node-24h85                   2/2    Running  0         2m
kube-system  etcd                                1/1    Running  0         6m
kube-system  kube-apiserver                      1/1    Running  0         6m
kube-system  kube-controller-manager             1/1    Running  0         6m
kube-system  kube-dns-545bc4bfd4-67qqp           3/3    Running  0         5m
kube-system  kube-proxy-8fzp2                    1/1    Running  0         5m
kube-system  kube-scheduler                      1/1    Running  0         5m
```

7. Remove the restriction on the master node to allow scheduling of containers on it.

```
kubectl taint nodes –all node-role.kubernetes.io/master-
```

8. Verify that you now have one node available in the cluster for scheduling container by executing `kubectl get nodes`.

9. Test your Kubernetes installation by running and NginX deployment (optional). The deployment will create two pods with NginX that are load-balanced automatically, when the solution is running on port 80.

```
kubectl run my-nginx --image=nginx --replicas=2 --port=80

# if the cluster is working correctly you should see th following output
# if you run (the name of the pods in the deployment may be different): 

kubectl get deployments

NAME       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
my-nginx   2         2         2            2           15s

kubectl get pods

NAME                       READY     STATUS        RESTARTS   AGE
my-nginx-568fcc5c7-2p22n   1/1       Running       0          20s
my-nginx-568fcc5c7-d6j6x   1/1       Running       0          20s
```
10. Remove your nginx deployment by doing `kubectl delete deployment my-nginx`.

### Download and Install Hyperledger Fabric






