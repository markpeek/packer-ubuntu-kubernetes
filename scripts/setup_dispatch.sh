#!/bin/sh

if [ `id -u` -ne 0 ] ; then echo "Please run as root using sudo" ; exit 1 ; fi

echo '>>>> Running kubeadm'
kubeadm init --pod-network-cidr=10.244.0.0/16

# Setup config for kubectl
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown kube:kube $HOME/.kube/config

# Install Flannel
echo '>>>> Installing Flannel'
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml

# Allow scheduling pods on Master Node
kubectl taint nodes --all node-role.kubernetes.io/master-

# Initialize Helm
echo '>>>> Installing Helm'
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
# kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' 
helm init --service-account tiller --wait

# Setup install config
export DISPATCH_HOST=dispatch.example.com
cat << EOF > config.yaml
apiGateway:
  host: $DISPATCH_HOST
dispatch:
  host: $DISPATCH_HOST
  debug: true
  skipAuth: true
kafka:
 chart:
   version: 0.8.5
   opts:
     persistence.enabled: false
     replicas: 1
dockerRegistry:
  chart:
    version: 1.5.1
EOF

# timeout:1200 If network is slow, the image pulls may be slower and hence the large timeout
echo '>>>> Installing Dispatch'
dispatch install --file config.yaml --debug --timeout 1200

cat << EOF > /etc/docker/daemon.json
{
  "insecure-registries": ["10.96.0.0/12"]
}
EOF

chown -R kube.kube config.yaml .dispatch .helm .kube
