#!/bin/bash

hostnamectl set-hostname k8s-master

dnf update -y
dnf install -y docker git
systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user


####################################################
# CREATE K8S INSTALL SCRIPT
####################################################

cat <<'EOF' > /home/ec2-user/k8s-install.sh
#!/bin/bash

set -e

echo "===== Disable Swap ====="

swapoff -a

sed -i '/swap/d' /etc/fstab

echo "===== Kernel Modules ====="

cat <<EOT | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOT

modprobe overlay
modprobe br_netfilter

echo "===== Sysctl Settings ====="

cat <<EOT | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOT

sysctl --system

echo "===== Install Containerd ====="

dnf install -y containerd

mkdir -p /etc/containerd

containerd config default | tee /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl enable containerd
systemctl restart containerd

echo "===== Add Kubernetes Repo ====="

cat <<EOT | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
EOT

echo "===== Install Kubernetes Packages ====="

dnf install -y kubelet kubeadm kubectl

systemctl enable kubelet

echo "===== Install Extra Packages ====="

dnf install -y conntrack-tools iproute-tc

echo "===== Finished Successfully ====="
EOF

####################################################
# MAKE SCRIPT EXECUTABLE
####################################################

chmod +x /home/ec2-user/k8s-install.sh

chown ec2-user:ec2-user /home/ec2-user/k8s-install.sh


####################################################
# CREATE CLUSTER INIT SCRIPT
####################################################

cat <<'EOF' > /home/ec2-user/init-cluster.sh
#!/bin/bash
set -e
echo "===== Initialize Kubernetes Cluster ====="
kubeadm init --pod-network-cidr=192.168.0.0/16
# kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml

EOF

####################################################
# MAKE SCRIPT EXECUTABLE
####################################################

chmod +x /home/ec2-user/init-cluster.sh

chown ec2-user:ec2-user /home/ec2-user/init-cluster.sh