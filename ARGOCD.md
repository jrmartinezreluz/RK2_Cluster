
---

````md
# 🚀 Installation Manual: Argo CD on RKE2 with External NGINX (F5 or EC2)

This guide explains how to install and expose **Argo CD** on a **Kubernetes RKE2** cluster, using an **external NGINX (F5 or EC2)** instance as a reverse proxy with TLS.

---

## 📋 Table of Contents

1. Prerequisites  
2. Argo CD Installation  
3. Ingress Exposure  
4. External NGINX Configuration  
5. Web UI Access  
6. Recommended Next Steps  

---

## 1. Prerequisites

- Operational RKE2 Kubernetes cluster  
- Ingress NGINX installed and functional  
- External NGINX instance (F5 or EC2) with valid certificates:

```bash
/etc/nginx/ssl/fullchain.pem
/etc/nginx/ssl/privkey.pem
````

* Public domain pointing to external NGINX

  * Example: `argocd.genialholdinggroup.com`

---

## 2. Argo CD Installation

### 2.1 Create the Namespace

```bash
kubectl create namespace argocd
```

### 2.2 Apply Official Manifests

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

This installs the following components:

* `argocd-server`
* `argocd-repo-server`
* `argocd-application-controller`
* `argocd-dex-server` *(optional for SSO)*

---

## 3. Create Argo CD Ingress

Create a file named `argocd-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: argocd.genialholdinggroup.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  number: 443
```

Apply the manifest:

```bash
kubectl apply -f argocd-ingress.yaml
```

Verify the ingress:

```bash
kubectl -n argocd get ingress
```

---

## 4. External NGINX Configuration

Edit the file `/etc/nginx/nginx.conf`.

### 4.1 Add Argo CD Upstream and Server Block

```nginx
upstream argocd_backend {
    server 10.0.1.119:443;
    server 10.0.1.185:443;
}

server {
    listen 443 ssl http2;
    server_name argocd.genialholdinggroup.com;

    ssl_certificate     /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass https://argocd_backend;
        proxy_ssl_verify off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
    }
}
```

Ensure that `10.0.1.119` and `10.0.1.185` are nodes running Ingress NGINX.

### 4.2 Optional: HTTP to HTTPS Redirect

```nginx
server {
    listen 80;
    server_name argocd.genialholdinggroup.com;

    return 301 https://$host$request_uri;
}
```

### 4.3 Reload NGINX

```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## 5. Web UI Access

### Get the Initial Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

### Access the UI

Go to:
🔗 `https://argocd.genialholdinggroup.com`

* **Username**: `admin`
* **Password**: *(retrieved above)*

---

## 6. Recommended Next Steps

### 🔐 Enable External Authentication (Optional)

Argo CD supports authentication via:

* GitHub
* GitLab
* LDAP
* OIDC (Google, Azure AD, etc.)

*Need a guide for GitHub or Google SSO? Just ask!*

---

### 📁 Connect to a Git Repository

Add repositories via **Settings > Repositories** or use the CLI:

```bash
argocd repo add <REPO_URL>
```

---

### ⚙️ GitOps Deployment Example

```bash
argocd app create nginx-demo \
  --repo https://github.com/your-org/your-repo.git \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default
```

---

### 🔄 Enable Auto Sync

```bash
argocd app set nginx-demo --sync-policy automated
```

---

### 📌 Check Application Status

```bash
argocd app list
argocd app get nginx-demo
```

---

## 🎉 Final Result

Your architecture will look like this:

```
Internet
   │
   ▼
[ External NGINX ] ← TLS → (443)
   │
   ▼
[ Ingress NGINX on RKE2 ] ← HTTPS → (443)
   │
   ▼
[ ArgoCD Service → Pod ]
```

---

## 📬 Contact

For support or questions:
📧 **[jmartinez@arkhadia.net](mailto:jmartinez@arkhadia.net)**
📱 **+507 6363-6738**
🌐 **@genialcorpholding**

```
---

