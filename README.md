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





