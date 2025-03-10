Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/focal64"
  config.vm.box_version = "20240821.0.1"

#   config.vm.box = "bento/ubuntu-24.04"
#   config.vm.box_version = "202502.21.0"
  config.vm.boot_timeout = 1200
#   config.vm.network "private_network", type: "dhcp"
  config.vm.provision "shell", inline: $script
  config.ssh.insert_key = false
  config.ssh.private_key_path = "~/.vagrant.d/insecure_private_key"


  # Master Node
  config.vm.define "control-plane" do |controlplane|
    controlplane.vm.hostname = "control-plane"
    controlplane.vm.network "private_network", ip: "192.168.56.2"  #,  bridge:"enp0s8"
    controlplane.vm.provider "virtualbox" do |v1|
        v1.cpus = 2
        v1.memory = 2048
        v1.customize ["modifyvm", :id, "--uartmode1", "disconnected"]

    end

      controlplane.vm.provision "shell", inline: $control_script
  end


  # Worker Node 1
  config.vm.define "node1" do |node1|
    node1.vm.hostname = "node1"
    node1.vm.network "private_network", ip: "192.168.56.3"
    node1.vm.provider "virtualbox" do |v2|
        v2.cpus = 1
        v2.memory = 2048
        v2.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
    end
  end


  # Worker Node 2
  config.vm.define "node2" do |node2|
    node2.vm.hostname = "node2"
    node2.vm.network "private_network", ip: "192.168.56.4"
    node2.vm.provider "virtualbox" do |v3|
        v3.cpus = 1
        v3.memory = 2048
        v3.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
    end
  end
end


# cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
# net.bridge.bridge-nf-call-ip6tables = 1
# net.bridge.bridge-nf-call-iptables = 1
# net.ipv4.ip_forward = 1
# EOF
#
# sudo sysctl --system
# sed -i '^/disabled_plugins = ["cri"]*/d' ./etc/containerd/config.toml
# kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
# config.vm.box = "bento/ubuntu-24.04"
# config.vm.box_version = "202502.21.0"

$script = <<-SCRIPT
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt install net-tools
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
sudo install -m 0755 -d /etc/apt/keyrings
sudo swapoff -a && sudo sed -i '/swap/d' /etc/fstab
curl -O https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/containerd.io_1.7.25-1_amd64.deb
sudo dpkg -i containerd.io_1.7.25-1_amd64.deb
sudo sed -i '/disabled_plugins/d' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo sysctl -w net.ipv4.ip_forward=1
sudo echo "alias k=kubectl" >> /home/vagrant/.bashrc
SCRIPT

# https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/containerd.io_1.7.25-1_amd64.deb

$control_script = <<-script
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=192.168.56.2
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/custom-resources.yaml
mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chmod 0777 /home/vagrant/.kube/config
script

# sudo systemctl stop apparmor
# sudo systemctl disable apparmor
# sudo systemctl restart containerd
# kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
# scp -P 2222 vagrant@127.0.0.1:/home/vagrant/devstack/local.conf .
