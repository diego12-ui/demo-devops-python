# Arquitectura para presentación

Este documento presenta la arquitectura del proyecto en un formato más ejecutivo, orientado a reuniones técnicas, revisión de diseño o entregables de infraestructura.

## 1. Objetivo del sistema

La aplicación es un servicio REST en Django que expone operaciones para gestionar usuarios mediante API. Su arquitectura está diseñada para permitir:

- desarrollo local rápido
- contenedorización con Docker
- integración y despliegue continuo con GitHub Actions
- ejecución en Kubernetes con escalabilidad y observabilidad básica

## 2. Componentes principales

### Aplicación
- Framework: Django + Django REST Framework
- Servidor: Gunicorn
- Endpoints principales:
  - `GET /api/health/`
  - `GET /api/users/`
  - `POST /api/users/`
  - `GET /api/users/<id>/`

### Infraestructura
- Contenedor Docker para ejecutar la app de forma consistente
- Kubernetes para orquestación y alta disponibilidad
- Persistencia con SQLite sobre PVC
- Balanceo de tráfico mediante Service e Ingress

## 3. Arquitectura de CI/CD

```mermaid
flowchart TD
  Dev[Desarrollador] --> Repo[Repositorio GitHub]
  Repo --> CI[GitHub Actions]
  CI --> Lint[ruff]
  CI --> Tests[pytest + pytest-cov]
  CI --> Cover[coverage.xml]
  CI --> Sonar[SonarQube]
  CI --> Build[Construcción de imagen Docker]
  Build --> Registry[Registro de imágenes]
  Build --> K8s[Despliegue en Kubernetes]
```

### Flujo de CI/CD
1. Se dispara un push o pull request.
2. GitHub Actions ejecuta lint, tests y cobertura.
3. Se genera un reporte de calidad y cobertura.
4. Se construye la imagen Docker.
5. Se despliega la aplicación en Kubernetes.

## 4. Arquitectura de ejecución en Kubernetes

```mermaid
flowchart LR
  Client[Cliente] --> Ingress[Ingress]
  Ingress --> Service[Service]
  Service --> Deployment[Deployment]
  Deployment --> PodA[Pod 1]
  Deployment --> PodB[Pod 2]
  PodA --> AppA[Aplicación Django]
  PodB --> AppB[Aplicación Django]
  Deployment --> HPA[HPA]
  Deployment --> VPA[VPA]
  Deployment --> Quota[ResourceQuota]
  Deployment --> PVC[PVC]
  PVC --> DB[(SQLite)]
```

## 5. Seguridad

### Medidas implementadas
- Variables sensibles gestionadas con `Secret` en Kubernetes
- Configuración no sensible separada en `ConfigMap`
- TLS preparado para Ingress mediante un `Secret` de tipo TLS
- Health probes para detectar fallas de forma temprana
- Namespace aislado para controlar recursos y permisos

### Consideraciones recomendadas
- Usar un registro privado para imágenes en producción
- Rotar secretos de forma periódica
- Proteger el acceso al cluster mediante RBAC
- Usar HTTPS real con un certificado emitido por una autoridad certificadora

## 6. Escalabilidad y disponibilidad

### Escalabilidad horizontal
- El `HorizontalPodAutoscaler` ajusta el número de réplicas según uso de CPU y memoria.
- El despliegue está preparado para escalar desde 2 hasta 6 réplicas.

### Escalabilidad vertical
- El `VerticalPodAutoscaler` ajusta los recursos del contenedor cuando el cluster soporta el CRD.

### Gestión de recursos
- `ResourceQuota` limita consumo de CPU, memoria, pods y servicios por namespace.
- `PersistentVolumeClaim` permite persistencia de la base de datos SQLite.

## 7. Operación y despliegue

### Local
- Se puede ejecutar con Python, Docker o Docker Compose.

### Kubernetes
- Se aplica con `kubectl apply -k k8s`.
- El namespace se centraliza en `k8s/kustomization.yaml`.
- Los recursos se despliegan como una unidad lógica y reproducible.

## 8. Resumen ejecutivo

La solución combina una API Django simple con prácticas modernas de DevOps:

- calidad automática con Ruff y SonarQube
- pruebas automatizadas con pytest
- cobertura de pruebas con pytest-cov
- contenedorización con Docker
- despliegue reproducible en Kubernetes
- escalabilidad con HPA/VPA y control de recursos con ResourceQuota
