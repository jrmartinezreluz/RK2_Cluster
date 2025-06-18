
---

````md
# 🛠 Installation Manual: Ingress NGINX on RKE2 with External NGINX (F5 or EC2)

This manual outlines the steps required to deploy Ingress NGINX in an RKE2 cluster and expose services via an external NGINX instance (F5 or EC2) using TLS.

---

## 📌 1. Disable Traefik (Default Ingress in RKE2)

On **all nodes** in the cluster, edit the file:

```bash
/etc/rancher/rke2/config.yaml
````

Add the following:

```yaml
disable:
  - rke2-ingress
```

Restart services:

* On **master nodes**:

  ```bash
  systemctl restart rke2-server
  ```
* On **worker nodes**:

  ```bash
  systemctl restart rke2-agent
  ```

---

## 🧷 2. Label Worker Nodes

Label the nodes that will act as workers:

```bash
kubectl label node ip-10-0-1-119 node-role.kubernetes.io/worker=worker
kubectl label node ip-10-0-1-185 node-role.kubernetes.io/worker=worker
```

---

## 📦 3. Install Ingress NGINX via Helm

Add the official Helm repo:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

Install Ingress NGINX with NodePort (no hostNetwork):

```bash
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.replicaCount=2 \
  --set controller.nodeSelector."node-role\.kubernetes\.io/worker"=worker \
  --set controller.tolerations[0].key="CriticalAddonsOnly" \
  --set controller.tolerations[0].operator="Exists" \
  --set controller.tolerations[1].key="node-role.kubernetes.io/master" \
  --set controller.tolerations[1].operator="Exists" \
  --set controller.tolerations[1].effect="NoSchedule" \
  --set controller.service.type=NodePort \
  --set controller.service.nodePorts.http=30080 \
  --set controller.service.nodePorts.https=30443 \
  --set controller.admissionWebhooks.enabled=false
```

---

## 🌐 4. Configure External NGINX (F5 or EC2)

Edit the file:

```bash
/etc/nginx/nginx.conf
```

Minimal configuration block for `demo.genialholdinggroup.com`:

```nginx
server {
    listen 443 ssl http2;
    server_name demo.genialholdinggroup.com;

    ssl_certificate     /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass https://10.0.1.185:30443;
        proxy_ssl_verify off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 🔐 5. Load TLS Certificates Manually

```bash
cat /home/ubuntu/certificate.crt /home/ubuntu/ca_bundle.crt > /etc/nginx/ssl/fullchain.pem
cp /home/ubuntu/private.key /etc/nginx/ssl/privkey.pem
chmod 600 /etc/nginx/ssl/*
chown root:root /etc/nginx/ssl/*
systemctl restart nginx
```

---

## 🚢 6. Deploy Demo NGINX on the Cluster

Create a file named `demo-nginx.yaml` with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-nginx
  template:
    metadata:
      labels:
        app: demo-nginx
    spec:
      containers:
        - name: nginx
          image: nginx:alpine
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: demo-nginx
spec:
  selector:
    app: demo-nginx
  ports:
    - port: 80
      targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-nginx-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: demo.genialholdinggroup.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: demo-nginx
                port:
                  number: 80
```

Apply the manifest:

```bash
kubectl apply -f demo-nginx.yaml
```

---

## ✅ 7. Final Validation

From an external terminal or the machine running NGINX:

```bash
curl -vk https://demo.genialholdinggroup.com
```

You should see the default NGINX welcome HTML.

---

## 🎉 Result

Traffic flow:

```
Internet → External NGINX (TLS) → NodePort 30443 → Ingress NGINX → Service → Pod demo-nginx
```

✔ Stack successfully deployed and validated.

---

## 📬 Contact

For support or questions:
📧 **[jmartinez@arkhadia.net](mailto:jmartinez@arkhadia.net)**
📱 **+507 6363-6738**
🌐 **@genialcorpholding**

---
