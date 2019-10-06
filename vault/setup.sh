#!/usr/bin/env bash

helm init --upgrade --wait

kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default

helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
helm repo update

helm upgrade --install --set image.tag=0.4.17 --set etcd-operator.enabled=false vault-operator banzaicloud-stable/vault-operator

kubectl apply -f rbac.yaml

kubectl apply -f vault.yaml

kubectl get po -l app=vault

export VAULT_TOKEN=$(kubectl get secrets vault-unseal-keys -o json | jq -r '.data["vault-root"]' | base64 --decode)

kubectl get secrets vault-tls -o json | jq -r '.data["ca.crt"]' | base64 --decode | sudo tee ~/vault-tls-ca.pem
export VAULT_CACERT=~/vault-tls-ca.pem
