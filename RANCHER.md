
---

````md
# 🐳 Rancher Installation Manual on RKE2 Cluster with External NGINX (AWS)

This guide documents the complete installation of Rancher on a Kubernetes cluster based on **RKE2** in **AWS**, including:

- Prerequisites  
- Rancher installation using Helm  
- External NGINX configuration as a reverse proxy with TLS  
- Validation and initial access  
- Command to retrieve the admin password  

You can use this as internal documentation or for formal delivery.

---

## 🧱 1. Prerequisites

### Infrastructure

- RKE2 cluster on AWS with:
  - 3 master nodes
  - 2 worker nodes
- Ingress NGINX installed on the cluster
- External EC2 instance running NGINX as a reverse proxy

### Software

- Helm installed and configured on your local machine  
- `kubectl` configured and connected to the cluster (`~/.kube/config`)  
- Domain pointing to the public IP of the external NGINX  
  - Example: `rancher.genialholdinggroup.com`

### Certificates

TLS certificates available on the external NGINX instance under `/etc/nginx/ssl/`:

```bash
/etc/nginx/ssl/fullchain.pem
/etc/nginx/ssl/privkey.pem
````

---

## 🚀 2. Installing Rancher on RKE2 Cluster

### 2.1 Create Namespace

```bash
kubectl create namespace cattle-system
```

### 2.2 Add Rancher Helm Repo

```bash
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
```

### 2.3 Install Rancher with Helm

Since TLS will be handled by the external NGINX, use the `secret` source:

```bash
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.genialholdinggroup.com \
  --set replicas=3 \
  --set ingress.ingressClassName=nginx \
  --set ingress.tls.source=secret
```

### 2.4 Validate Pods and Ingress

```bash
kubectl -n cattle-system get pods
kubectl -n cattle-system get ingress
```

---

## 🌐 3. External NGINX Reverse Proxy Configuration

Performed on the EC2 instance **outside** the Kubernetes cluster.

### 3.1 Full `/etc/nginx/nginx.conf` Example

```nginx
worker_processes auto;

events {
    worker_connections 1024;
}

# TCP Load Balancing for RKE2
stream {
    log_format basic '$remote_addr [$time_local] $protocol '
                     '$status $bytes_sent $bytes_received '
                     '$session_time';

    access_log /var/log/nginx/rke2_api.log basic;

    upstream rke2_api {
        least_conn;
        server 10.0.1.41:6443;
        server 10.0.1.88:6443;
        server 10.0.1.68:6443;
    }

    upstream rke2_control {
        least_conn;
        server 10.0.1.41:9345;
        server 10.0.1.88:9345;
        server 10.0.1.68:9345;
    }

    server {
        listen 6443;
        proxy_pass rke2_api;
    }

    server {
        listen 9345;
        proxy_pass rke2_control;
    }
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout 65;

    proxy_connect_timeout 30s;
    proxy_send_timeout    60s;
    proxy_read_timeout    60s;
    send_timeout          60s;

    resolver 8.8.8.8;

    # HTTP to HTTPS Redirect
    server {
        listen 80;
        server_name rancher.genialholdinggroup.com;

        return 301 https://$host$request_uri;
    }

    # Rancher Backend (HTTPS Ingress)
    upstream rancher_backend {
        server 10.0.1.119:443;
        server 10.0.1.185:443;
    }

    server {
        listen 443 ssl http2;
        server_name rancher.genialholdinggroup.com;

        ssl_certificate     /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        location / {
            proxy_pass https://rancher_backend;
            proxy_ssl_verify off;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
        }
    }
}
```

### 3.2 Validate and Reload NGINX

```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## 🔐 4. Retrieve Initial Rancher Password

Run the following command:

```bash
kubectl get secret --namespace cattle-system bootstrap-secret \
  -o go-template='{{.data.bootstrapPassword | base64decode}}{{"\n"}}'
```

Use the output to log into:
🔗 `https://rancher.genialholdinggroup.com`

---

## ✅ 5. First Access & Setup

* Log in with the bootstrap password
* Set a new admin password
* (Optional) Disable telemetry
* Access the Rancher Dashboard
* (Recommended) Set up external authentication and backups

---

## 🎯 6. Final Validation

### Rancher Web Access

```bash
curl -k https://rancher.genialholdinggroup.com
```

### Check Ingress Status

```bash
kubectl -n cattle-system get ingress
```

---

## 📌 Additional Considerations

| Component    | Description                                                      |
| ------------ | ---------------------------------------------------------------- |
| **TLS**      | Terminates at the external NGINX (Let's Encrypt or custom certs) |
| **DNS**      | Must point to the external NGINX public IP                       |
| **Ingress**  | Listens on port 443 inside the cluster                           |
| **Security** | Use WAF or Security Groups in production to restrict access      |

---

## 📬 Contact

For support or questions:
📧 **[jmartinez@arkhadia.net](mailto:jmartinez@arkhadia.net)**
📱 **+507 6363-6738**
🌐 **@genialcorpholding**

---

