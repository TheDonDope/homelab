.PHONY: all k3s-install k3s-uninstall k3s-config helm-deps helm-install kustomize delete

all: helm-deps helm-install kustomize

k3s-install:
	curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="\
	  --write-kubeconfig-mode '0644' \
	  --cluster-init \
	  --disable servicelb \
	  --disable traefik \
	  --disable local-storage" sh -

k3s-uninstall:
	sudo /usr/local/bin/k3s-uninstall.sh

k3s-config:
	cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && \
	chown $(shell whoami):$(shell whoami) ~/.kube/config

helm-deps:
	helmfile deps -f ./helm/helmfile.yaml

helm-install:
	helmfile apply -f ./helm/helmfile.yaml

kustomize:
	kubectl apply -k kustomize/

delete:
	helmfile destroy -f ./helm/helmfile.yaml
