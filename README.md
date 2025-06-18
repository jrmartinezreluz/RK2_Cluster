# Proyecto: Clúster Kubernetes RKE2 en AWS con Argo CD, NGINX y Node.js Apps

Este proyecto implementa un clúster de Kubernetes basado en **RKE2** sobre instancias EC2 en **AWS**, utilizando Terraform para la infraestructura, Ansible para la configuración del balanceador NGINX y Argo CD para el despliegue GitOps de aplicaciones Node.js.

## 📦 Arquitectura del Proyecto

+-------------------+ +----------------------+ +---------------------+
| Usuario (web) | <---> | NGINX (LB - EC2) | <---> | Kubernetes RKE2 |
| | | IP Pública: x.x.x.x | | (3 masters + 2 workers)|
+-------------------+ +----------------------+ +---------------------+
|
|--> Puerto 9080 -> App Node.js 1
|--> Puerto 9081 -> App Node.js 2
|--> Puerto 9443 -> Argo CD (UI)


## ☁️ Infraestructura AWS

- VPC con subred pública y privada
- 6 Instancias EC2 (Ubuntu 24.04 LTS):
  - 1 LB: NGINX como balanceador TCP
  - 3 Masters: RKE2 server
  - 2 Workers: RKE2 agent
- Security Groups configurados para habilitar puertos 22, 6443, 9345, 9080, 9081 y 9443

## ⚙️ Herramientas Utilizadas

- [Terraform](https://www.terraform.io/) – Infraestructura como código
- [Ansible](https://www.ansible.com/) – Configuración de NGINX
- [RKE2](https://docs.rke2.io/) – Kubernetes empresarial de Rancher
- [Argo CD](https://argo-cd.readthedocs.io/) – GitOps para Kubernetes
- [NGINX](https://nginx.org/) – Balanceador de carga TCP/HTTP
- [DockerHub](https://hub.docker.com/) – Almacenamiento de imágenes

## 🚀 Aplicaciones Desplegadas

### Node.js App 1

- Desplegada vía Argo CD
- Acceso: `http://<IP_LB>:9080`
- Imagen: `jrmartinezreluz/nodejs-app:latest`

### Node.js App 2

- Desplegada vía Argo CD
- Acceso: `http://<IP_LB>:9081`
- Imagen: `jrmartinezreluz/nodejs-app2:latest`

## 🧩 Estructura del Repositorio

rke2/
├── ansible/ # Configuración automática de NGINX
├── apps/ # Manifiestos declarativos de Argo CD
│ ├── nodejs-app.yaml
│ └── nodejs-app2.yaml
├── docker/ # Archivos Docker de las apps
│ ├── nodejs-app/
│ │ ├── Dockerfile
│ │ ├── index.js
│ │ └── package.json
│ └── nodejs-app2/
│ ├── Dockerfile
│ ├── index.js
│ └── package.json
├── terraform/ # Infraestructura en AWS
│ ├── main.tf
│ └── variables.tf
└── README.md

## 🔐 Acceso a Argo CD

- URL: `https://<IP_LB>:9443`
- Usuario: `admin`
- Contraseña: obtenida desde:
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
  
📦 Deploy GitOps
Argo CD detecta cambios en los manifiestos YAML ubicados en apps/ y los sincroniza automáticamente con el clúster.

🧪 Validación
Desde el LB puedes validar los servicios:
curl http://localhost:9080     # Node.js App 1
curl http://localhost:9081     # Node.js App 2

O desde fuera del entorno:
curl http://<IP_LB>:9080
curl http://<IP_LB>:9081

📬 Contacto
We would love to hear from you:
📧 jmartinez@arkhadia.net
📱 +507 6363-6738
🌐 @genialcorpholding
