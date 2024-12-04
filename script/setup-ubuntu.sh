# apt-get update && apt-get upgrade -y
# apt-get install -y vim
# apt install curl apt-transport-https vim git nfs-common wget software-properties-common lsb-release ca-certificates -y
# swapoff -a; sed -i '/swap/d' /etc/fstab
# modprobe overlay
# modprobe br_netfilter
# echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
# echo 'br_netfilter' > /etc/modules-load.d/k8s.conf
# cat << EOF | tee /etc/sysctl.d/kubernetes.conf
# net.bridge.bridge-nf-call-ip6tables = 1
# net.bridge.bridge-nf-call-iptables = 1
# net.ipv4.ip_forward = 1
# EOF
# sysctl -p


# mkdir -p /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --batch --yes -o /etc/apt/keyrings/docker.gpg

# echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


VERSION_k8s=$1
VERSION_PATCH=$2

echo $VERSION_k8s
echo $VERSION_PATCH

#############


#############
# apt-get update && apt-get install containerd.io -y
# containerd config default | tee /etc/containerd/config.toml
# sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
# systemctl restart containerd

#############
curl -fsSL https://pkgs.k8s.io/core:/stable:/v$VERSION_k8s/deb/Release.key | sudo gpg --dearmor --batch --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$VERSION_k8s/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#############
apt-get update
apt-get install -y kubeadm=$VERSION_k8s.$VERSION_PATCH kubelet=$VERSION_k8s.$VERSION_PATCH kubectl=$VERSION_k8s.$VERSION_PATCH --allow-change-held-packages
apt-mark hold kubelet kubeadm kubectl

############

wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v$VERSION_k8s.0/crictl-v$VERSION_k8s.0-linux-amd64.tar.gz

tar zxvf crictl-v$VERSION_k8s.0-linux-amd64.tar.gz

mv crictl /usr/local/bin

cat <<EOF | tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
EOF
#############
wget https://storage.googleapis.com/gvisor/releases/nightly/latest/containerd-shim-runsc-v1 -O /usr/local/bin/containerd-shim-runsc-v1
chmod +x /usr/local/bin/containerd-shim-runsc-v1

wget https://storage.googleapis.com/gvisor/releases/nightly/latest/runsc -O /usr/local/bin/runsc
chmod +x /usr/local/bin/runsc