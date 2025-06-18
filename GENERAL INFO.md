---

# 🛠️ Manual Configuration – RKE2 Cluster on AWS

This guide describes the manual steps to configure:

* Master and Worker nodes for the RKE2 Kubernetes cluster
* NGINX as a TCP load balancer
* Argo CD for GitOps-based application deployment

---

## 🔹 Master Nodes Setup

### 🔧 Prerequisites (on each master node)

```bash
sudo hostnamectl set-hostname masterX
sudo apt update && sudo apt upgrade -y
```

### 📥 Install RKE2 Server (master1)

```bash
curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_TYPE="server" sh -
sudo mkdir -p /etc/rancher/rke2
```

Create `/etc/rancher/rke2/config.yaml` with:

```yaml
token: <SHARED_TOKEN>
tls-san:
  - <PUBLIC_LB_IP>
```

Start the service:

```bash
sudo systemctl enable rke2-server
sudo systemctl start rke2-server
```

### 🔐 Retrieve Cluster Token (master1)

```bash
sudo cat /var/lib/rancher/rke2/server/node-token
```

### 🧩 Configure master2 and master3

Same steps as `master1`, but modify the `config.yaml` with:

```yaml
server: https://<PRIVATE_LB_IP>:9345
token: <SHARED_TOKEN>
tls-san:
  - <PUBLIC_LB_IP>
```

---

## 🔹 Worker Nodes Setup

### ⚙️ Preparation and RKE2 Agent Installation

```bash
sudo hostnamectl set-hostname workerX
sudo apt update && sudo apt upgrade -y
curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_TYPE="agent" sh -
```

Create `/etc/rancher/rke2/config.yaml` with:

```yaml
server: https://<PRIVATE_LB_IP>:9345
token: <TOKEN_FROM_MASTER1>
```

Start the agent service:

```bash
sudo systemctl enable rke2-agent
sudo systemctl start rke2-agent
```

---

## 🔹 NGINX Load Balancer

NGINX is installed using an Ansible playbook:

```bash
ansible-playbook -i inventory.ini nginx-install.yml
```

Configured to load balance TCP traffic on ports:

* `9345` for RKE2 cluster join
* `6443` for Kubernetes API
* `9080`, `9081` for Node.js apps
* `9443` for Argo CD

---

## 🔹 Argo CD Installation

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Retrieve the admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Access Argo CD Web UI:
`https://<LB_IP>:9443`

---

## 🔹 Argo CD Applications

Applications declared in Git and synced via Argo CD:

* `apps/nodejs-app.yaml`
* `apps/nodejs-app2.yaml`

Each app exposes a Node.js service:

* App 1: `http://<LB_IP>:9080`
* App 2: `http://<LB_IP>:9081`

---

## ✅ Final Test

Verify both applications:

```bash
curl http://localhost:9080   # Node.js App 1
curl http://localhost:9081   # Node.js App 2
```

Both should return a welcome message from the respective Node.js apps.

---

## 📬 Contact

For questions, suggestions, or support:
📧 **[jmartinez@arkhadia.net](mailto:jmartinez@arkhadia.net)**
📱 **+507 6363-6738**
🌐 **@genialcorpholding**

---
