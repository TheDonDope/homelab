# Homelab

> Don't pay money to use services, host them yourself.

This repository provides the configuration to deploy a collection of useful
services to your own local Kubernetes cluster.
For an easier deployment [helmfile](https://github.com/helmfile/helmfile) is
used.

## Requirements

To use this, you need a local kubernetes cluster installed (for example through
minikube or k3s), and the following tools:

- kubectl
- helmfile
- helm
- git

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

## Service specific configuration

Some services might have additional requirements, be it installed tools, or
deployed resources.

### Bitnami ExternalDNS

- [Bitnami Helm Repo](https://charts.bitnami.com/bitnami)

### Ingress-Nginx

- [Kubernetes Helm Repo](https://kubernetes.github.io/ingress-nginx)

### Jellyfin

- [Jellyfin Helm Repo](https://jellyfin.github.io/jellyfin-helm)

### Longhorn

- [Longhorn Helm Repo](https://charts.longhorn.io)

Install `iscsi` to your cluster:

```bash
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.9.0/deploy/prerequisite/longhorn-iscsi-installation.yaml
```

Check the installer pods status with (or alternatively with `k9s`):

```bash
kubectl -n longhorn-system get pod | grep longhorn-iscsi-installation
```

### MetalLB

- [MetalLB Helm Repo](https://metallb.github.io/metallb)

### Nextcloud

- [Nextcloud Helm Repo](https://nextcloud.github.io/helm)

### Pi-hole

- [Pi-hole Helm Repo](https://mojo2600.github.io/pihole-kubernetes)

Update the default password:

```bash
kubectl create secret generic pihole-password \
  --from-literal=password='new_password_here' \
  --namespace=pihole-system \
  --dry-run=client -o yaml | kubectl apply -f -
```

Temporarily accessing the GUI is possible with port-forwarding:

```bash
kubectl port-forward -n pihole-system svc/pihole-web 8080:80
```

Open the Browser at <http://localhost:8080/admin>

### VaultWarden

- [VaultWarden Helm Repo](https://guerzon.github.io/vaultwarden)

## Deploying to a cluster

Deploying to a cluster is as simple as running:

```bash
helmfile apply -f ./helm/helmfile.yaml
```

Or `cd`-ing into the `helm` directory before and running:

```bash
helmfile apply
```

**Important**: Afterwards also apply the kustomizations by running:

```bash
kubectl apply -k kustomize/
```

## Using a development cluster with minikube

Install [Minikube](https://minikube.sigs.k8s.io/docs/) following the
instructions in the [minikube start](https://minikube.sigs.k8s.io/docs/start/)
documentation.

Then fire up a cluster (This example uses [Podman](https://podman.io) as a
driver):

```bash
minikube start --driver podman
```

Tearing down a cluster is as easy as running:

```bash
minikube delete
```

To get a Web GUI with a dashboard for your cluster, run:

```bash
minikube dashboard
```

Alternatively, you can use [k9s](https://k9scli.io) as a CLI:

```bash
k9s --namespace longhorn-system
```

## Using a production cluster with k3s

Install [K3s](https://k3s.io/) following the instructions in the
[K3s Installation](https://docs.k3s.io/installation) documentation:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="\
  --write-kubeconfig-mode '0644' \
  --cluster-init \
  --disable servicelb \
  --disable traefik \
  --disable local-storage" sh -
```
