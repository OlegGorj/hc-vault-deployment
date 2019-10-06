# Hashicorp Vault deployment

Repo hosts deployment code for Hashicorp Vault with `ETCD` as backend on K8s cluster

## Prerequisites Details

 - Kubernetes 1.6+


## Deployment instructions

Helm tiller initialized.

```
helm init --upgrade --wait
kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
```

Create Vault service account called `vault-auth`

```
kubectl apply -f service-account.yaml
```

This installation uses Vault Operator provided by Banzaicloud - `banzaicloud-stable/vault-operator`, it's quite stable and well-tested operator.

Step 1: Initialize Helm repo

```
helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
helm repo update
```

Install actual Operator:

```
helm upgrade --install --set image.tag=0.4.17 --set etcd-operator.enabled=false vault-operator banzaicloud-stable/vault-operator
```

Step 2: Apply RBAC settings

```
kubectl apply -f vault/rbac.yaml
```

Step 3: Create Vault cluster

The following will create 3-nodes Vault cluster.

Note: keep in mind this command will also spin up 3-node `etcd` cluster.

To change this, edit file `vault.yaml`, the `spec` part:

```
spec:
  size: 3
  etcdSize: 3
```

Now, apply the changes and create the clusters:

```
kubectl apply -f vault/vault.yaml
```

Step 4: Verify installation

```
kubectl get po -l app=vault
```

Step 5: Get Vault's token and certificate

```
export VAULT_TOKEN=$(kubectl get secrets vault-unseal-keys -o json | jq -r '.data["vault-root"]' | base64 --decode)
```

```
kubectl get secrets vault-tls -o json | jq -r '.data["ca.crt"]' | base64 --decode | sudo tee ~/vault-tls-ca.pem
export VAULT_CACERT=~/vault-tls-ca.pem
```

Hope all this worked well for you. Happy `Vaulting`!


### Some helpful references

https://github.com/banzaicloud/bank-vaults/issues/105
