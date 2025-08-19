helm repo add longhorn https://charts.longhorn.io
helm repo add cert-manager https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set crds.enabled=true
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    privateKeySecretRef:
      name: letsencrypt-prod
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
kubectl create ns longhorn-system && kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.8.0/deploy/prerequisite/longhorn-nfs-installation.yaml -n longhorn-system
kubectl wait --for condition=ready pod -l app=longhorn-nfs-installation -n longhorn-system --timeout 900s
helm install longhorn longhorn/longhorn --namespace longhorn-system --set defaultSettings.deletingConfirmationFlag=true
