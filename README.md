# Patata-Bollente

# Patata-Bollente



kubectl get nodes --context kind-patata-bollente
kubectl port-forward svc/argocd-server -n argocd 8080:8080 --context kind-patata-bollente
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" --context kind-patata-bollente | base64 -d; echo