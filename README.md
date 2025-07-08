# Homelab

> Don't pay money to use services, host them yourself.

This repository provides the configuration to deploy a collection of useful
services to your own local [Kubernetes](https://kubernetes.io) cluster.
For an easier deployment [helmfile](https://github.com/helmfile/helmfile) is
used.

## Requirements

To use this, you need a local kubernetes cluster installed (for example through
[minikube](https://minikube.sigs.k8s.io/docs/) or
[k3s](https://k3s.io/)), and the following tools:

- [kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [helmfile](https://github.io/helmfile/helmfile)
- [helm](https://helm.sh/)
- [git](https://git-scm.com/)

## Services provided

The services listed here are considered user-facing services, used by multiple
clients with different platforms (mobile, web, computer).

| Service                                                   | Description                    |
| --------------------------------------------------------- | ------------------------------ |
| [Jellyfin](https://jellyfin.org/)                         | The Free Software Media System |
| [Nextcloud](https://nextcloud.com)                        | Cloud Storage                  |
| [Pi-hole](https://pi-hole.net/)                           | Network-wide Ad Blocking       |
| [VaultWarden](https://github.com/dani-garcia/vaultwarden) | Bitwarden compatible server    |

## Internal services

The services listed here are used by the cluster to enable and manage
internal and external communication.

| Service                                                                                     | Description                                               |
| ------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| [Bitnami ExternalDNS](https://github.com/bitnami/containers/tree/main/bitnami/external-dns) | Automatic DNS for Pi-hole                                 |
| [Ingress-Nginx Controller](https://kubernetes.github.io/ingress-nginx)                      | Ingress for local network                                 |
| [Longhorn](https://longhorn.io)                                                             | Distributed block storage (used as storage for Nextcloud) |
| [MetalLB](https://metallb.io)                                                               | Load balancer                                             |

## Monitoring

For monitoring purposes, the PLTG Stack
([**P**rometheus](https://prometheus.io/),
[**L**oki](https://grafana.com/oss/loki/),
[**T**empo](https://grafana.com/oss/tempo/),
[**G**rafana](https://grafana.com/)) is provided, consisting of:

- Monitoring: Prometheus
- Log aggregation: Loki
- Tracing: Tempo
- Observability: Grafana

## Service specific configuration

Some services might have additional requirements, be it installed tools, or
deployed resources.

### Bitnami ExternalDNS

- [Bitnami Helm Repo](https://charts.bitnami.com/bitnami)
- [bitnami/external-dns Helmchart](https://github.com/bitnami/charts/blob/main/bitnami/external-dns/Chart.yaml#L33)

### Grafana

- [Grafana Helm Repo](https://grafana.github.io/helm-charts)
- [grafana/grafana Helmchart](https://github.com/grafana/helm-charts/blob/main/charts/grafana/Chart.yaml#L3)

### Ingress-Nginx

- [Kubernetes Helm Repo](https://kubernetes.github.io/ingress-nginx)
- [ingress-nginx/ingress-nginx Helmchart](https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/Chart.yaml#L23)

### Jellyfin

- [Jellyfin Helm Repo](https://jellyfin.github.io/jellyfin-helm)
- [jellyfin/jellyfin Helmchart](https://github.com/jellyfin/jellyfin-helm/blob/master/charts/jellyfin/Chart.yaml#L11)

### Loki

- [Grafana Helm Repo](https://grafana.github.io/helm-charts)
- [grafana/loki Helmchart](https://github.com/grafana/loki/blob/main/production/helm/loki/Chart.yaml#L6)

### Longhorn

- [Longhorn Helm Repo](https://charts.longhorn.io)
- [longhorn/longhorn Helmchart](https://github.com/longhorn/charts/blob/v1.9.x/charts/longhorn/Chart.yaml#L3)

### MetalLB

- [MetalLB Helm Repo](https://metallb.github.io/metallb)
- [metallb/metallb Helmchart](https://github.com/metallb/metallb/blob/main/charts/metallb/Chart.yaml)

### Nextcloud

- [Nextcloud Helm Repo](https://nextcloud.github.io/helm)
- [nextcloud/nextcloud Helmchart](https://github.com/nextcloud/helm/blob/main/charts/nextcloud/Chart.yaml#L3)

### Pi-hole

- [Pi-hole Helm Repo](https://mojo2600.github.io/pihole-kubernetes)
- [mojo2600/pihole Helmchart](https://github.com/MoJo2600/pihole-kubernetes/blob/main/charts/pihole/Chart.yaml#L7)

Update the default password:

```bash
kubectl create secret generic pihole-password \
  --from-literal=password='new_password_here' \
  --namespace=pihole-system \
  --dry-run=client -o yaml | kubectl apply -f -
```

### Prometheus

- [Prometheus Helm Repo](https://prometheus-community.github.io/helm-charts)
- [prometheus-community/kube-prometheus-stack Helmchart](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/Chart.yaml#L34)

### Tempo

- [Grafana Helm Repo](https://grafana.github.io/helm-charts)
- [grafana/tempo-distributed Helmchart](https://github.com/grafana/helm-charts/blob/main/charts/tempo-distributed/Chart.yaml#L5)

### VaultWarden

- [VaultWarden Helm Repo](https://guerzon.github.io/vaultwarden)
- [vaultwarden/vaultwarden Helmchart](https://github.com/guerzon/vaultwarden/blob/main/charts/vaultwarden/Chart.yaml#L16)

## Deploying to a cluster

Before you deploy to your cluster, you need to prepare it:

- Install / verify Helm dependencies:

```bash
make helm-deps
```

Deploying to a cluster is as simple as running:

```bash
make helm-install
```

**Important**: Afterwards also apply the kustomizations by running:

```bash
make kustomize
```

## Using a production cluster with k3s

To help you bootstrap a production-grade lightweight kubernetes cluster,
the [Makefile](./Makefile) provides three different targets:

Installing a minimal `k3s` cluster:

- `servicelb` is disabled in favour of using `metallb`
- `traefik` is disabled in favour of monitoring with `grafana`
- `local-storage` is disabled in favour of using `longhorn`

```bash
make k3s-install
```

---

Copying over the `kubeconfig` to your local `~/.kube/config`:

```bash
make k3s-config
```

---

Tearing down the installed `k3s` cluster and deleting all installed files:

```bash
make k3s-uninstall
```
