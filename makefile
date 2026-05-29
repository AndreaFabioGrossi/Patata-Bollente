CLUSTER_NAME=patata-bollente

help:
	@echo "Comandi per il cluster $(CLUSTER_NAME) con Helm:"
	@echo "  make up       - Crea cluster, installa ArgoCD con Helm e applica la Root App"
	@echo "  make down     - Cancella tutto il cluster"
	@echo "  make status   - Controlla lo stato di nodi e pod"
	@echo "  make port-argo- Avvia il port-forward per vedere ArgoCD nel browser"

## @ Avvio completo dell'infrastruttura
up:
	@echo "🚀 1. Creazione del cluster KinD '$(CLUSTER_NAME)'..."
	kind create cluster --name $(CLUSTER_NAME) --config kind-config.yaml
	
	@echo "📦 2. Aggiunta dei repository Helm e installazione di ArgoCD..."
	helm repo add argo https://github.io
	helm repo update
	helm install argocd argo/argo-cd --namespace argocd --create-namespace --set server.insecure=true
	
	@echo "⏳ 3. Attesa che ArgoCD sia pronto..."
	kubectl wait --namespace argocd --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=90s
	
	@echo "⚓ 4. Applicazione del manifest principale delle applicazioni..."
	kubectl apply -f root-app.yaml --context kind-$(CLUSTER_NAME)

## @ Spegnimento
down:
	@echo "❌ Rimozione del cluster KinD '$(CLUSTER_NAME)'..."
	kind delete cluster --name $(CLUSTER_NAME)

## @ Monitoraggio
status:
	@echo "🖥️  Stato dei Nodi:"
	kubectl get nodes --context kind-$(CLUSTER_NAME)
	@echo "\n📦 Stato di tutti i Pod (Helm + App):"
	kubectl get pods -A --context kind-$(CLUSTER_NAME)

## @ Accesso alla Dashboard di ArgoCD
port-argo:
	@echo "🖥️  ArgoCD sarà accessibile su: http://localhost:8080"
	kubectl port-forward svc/argocd-server -n argocd 8080:80
