+++
authors = ["Artem Kozlenkov"]
title = "Monitoring und Observability in Cloud-Umgebungen"
date = "2025-03-18"
description = "Ansätze für effektives Monitoring und Observability mit Prometheus, Grafana und Azure-nativen Tools."
tags = ["monitoring", "observability", "prometheus", "grafana", "azure"]
categories = ["Cloud", "Monitoring"]
series = []
+++

## Anwendungsfall: End-to-End Monitoring für Azure Kubernetes Microservices

### Szenario

Ein SaaS-Unternehmen hat seine Kernanwendungen auf Azure Kubernetes Service (AKS) migriert und benötigte vollständige Observability über Microservices, Infrastruktur und Cloud-Ressourcen hinweg. Das Ziel war, Probleme proaktiv zu erkennen, die Leistung zu visualisieren und Anomalien zu alarmieren.

### Lösungsübersicht

1. **Prometheus und Grafana** mit Helm auf AKS bereitstellen.
2. **Prometheus konfigurieren**, um Metriken von Kubernetes-Workloads und Systemkomponenten zu sammeln.
3. **Eigene Anwendungsmetriken exportieren** mit Prometheus-Client-Bibliotheken.
4. **Azure Monitor integrieren** für Cloud-native Einblicke.
5. **Grafana-Dashboards und Alarmregeln erstellen** für Echtzeit-Überwachung.

#### Schritt 1: Prometheus und Grafana via Helm bereitstellen

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
```

#### Schritt 2: Prometheus Scrape für eigene App-Metriken konfigurieren

Beispiel `ServiceMonitor` zum Erfassen von Metriken einer Python-App auf Port 8000:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: python-app
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app: python-app
  endpoints:
    - port: http
      path: /metrics
      interval: 30s
```

#### Schritt 3: Anwendungsmetriken veröffentlichen

Beispiel einer Python (Flask) App, instrumentiert mit `prometheus_client`:

```python
from flask import Flask
from prometheus_client import start_http_server, Counter

app = Flask(__name__)
REQUESTS = Counter('http_requests_total', 'Gesamtanzahl HTTP-Anfragen')

@app.route("/")
def hello():
    REQUESTS.inc()
    return "Hallo, Welt!"

if __name__ == "__main__":
    start_http_server(8000)
    app.run(host="0.0.0.0", port=5000)
```

#### Schritt 4: Grafana Dashboard Beispiel

Importieren Sie ein Dashboard-JSON oder verwenden Sie die integrierten Kubernetes/Prometheus-Dashboards. Beispiel-Metrik: `http_requests_total` visualisiert als Liniendiagramm.

#### Schritt 5: Alarmierungsbeispiel

Konfigurieren Sie Alarmregeln in Prometheus oder Grafana, z.B.:

```yaml
groups:
  - name: app-alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{job="python-app"}[5m]) > 100
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Hohe HTTP-Anfrage-Rate erkannt"
```

### Wichtige Vorteile

- **Vereinheitlichte Observability** über Cloud und Kubernetes.
- **Proaktive Alarmierung** bei Leistungs- und Zuverlässigkeitsproblemen.
- **Eigene Dashboards** für Entwicklung und Betrieb.

Dieser Ansatz ermöglichte schnelle Fehlerbehebung und verbesserte die Verfügbarkeit der cloud-nativen Dienste der Organisation.