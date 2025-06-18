---

# Project: RKE2 Kubernetes Cluster on AWS with Argo CD, NGINX, and Node.js Apps

This project sets up a **Kubernetes cluster based on RKE2** running on **AWS EC2 instances**, using **Terraform** for infrastructure provisioning, **Ansible** for NGINX load balancer configuration, and **Argo CD** for GitOps-based deployment of Node.js applications.

---

## 📦 Project Architecture

```
+-------------------+     +----------------------+     +---------------------+
|     User (web)    | <-> |  NGINX (LB - EC2)    | <-> |   RKE2 Kubernetes   |
|                   |     |  Public IP: x.x.x.x  |     | (3 masters, 2 workers) |
+-------------------+     +----------------------+     +---------------------+
                             |       |       |
                             |       |       +--> Port 9080 -> Node.js App 1  
                             |       +----------> Port 9081 -> Node.js App 2  
                             +---------------> Port 9443 -> Argo CD (UI)
```

---

## ☁️ AWS Infrastructure

* VPC with public and private subnets
* 6 EC2 Instances (Ubuntu 24.04 LTS):

  * 1 Load Balancer: NGINX in TCP mode
  * 3 Masters: RKE2 server nodes
  * 2 Workers: RKE2 agent nodes
* Security Groups allow access on ports: 22, 6443, 9345, 9080, 9081, and 9443

---

## ⚙️ Tools Used

* [Terraform](https://www.terraform.io/) – Infrastructure as Code
* [Ansible](https://www.ansible.com/) – NGINX Configuration Automation
* [RKE2](https://docs.rke2.io/) – Rancher's enterprise Kubernetes distribution
* [Argo CD](https://argo-cd.readthedocs.io/) – GitOps deployment for Kubernetes
* [NGINX](https://nginx.org/) – TCP/HTTP Load Balancer
* [DockerHub](https://hub.docker.com/) – Image registry

---

## 🚀 Deployed Applications

### Node.js App 1

* Deployed via Argo CD
* Access: `http://<LB_IP>:9080`
* Image: `jrmartinezreluz/nodejs-app:latest`

### Node.js App 2

* Deployed via Argo CD
* Access: `http://<LB_IP>:9081`
* Image: `jrmartinezreluz/nodejs-app2:latest`

---

## 🧩 Repository Structure

```
rke2/
├── ansible/              # NGINX configuration automation
├── apps/                 # Argo CD declarative manifests
│   ├── nodejs-app.yaml
│   └── nodejs-app2.yaml
├── docker/               # Dockerfiles for the apps
│   ├── nodejs-app/
│   │   ├── Dockerfile
│   │   ├── index.js
│   │   └── package.json
│   └── nodejs-app2/
│       ├── Dockerfile
│       ├── index.js
│       └── package.json
├── terraform/            # AWS infrastructure code
│   ├── main.tf
│   └── variables.tf
└── README.md
```

---

## 🔐 Argo CD Access

* URL: `https://<LB_IP>:9443`
* Username: `admin`
* Password: retrieve using:

  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
  ```

---

## 📦 GitOps Deployment

Argo CD continuously monitors the YAML manifests in the `apps/` folder and keeps the cluster in sync with the defined state.

---

## 🧪 Validation

From the Load Balancer (locally):

```bash
curl http://localhost:9080   # Node.js App 1  
curl http://localhost:9081   # Node.js App 2
```

From outside the environment:

```bash
curl http://<LB_IP>:9080  
curl http://<LB_IP>:9081
```

---

## 📬 Contact

We’d love to hear from you:
📧 [jmartinez@arkhadia.net](mailto:jmartinez@arkhadia.net)
📱 +507 6363-6738
🌐 @genialcorpholding

---

¿Deseas que también genere un `README.md` en archivo o agregar un badge de estado del proyecto?
