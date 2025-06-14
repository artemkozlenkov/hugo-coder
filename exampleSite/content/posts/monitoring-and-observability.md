+++
authors = ["Artem Kozlenkov"]
title = "Monitoring and Observability in Cloud Environments"
date = "2025-03-18"
description = "Approaches to effective monitoring and observability using Prometheus, Grafana, and Azure-native tools."
tags = ["monitoring", "observability", "prometheus", "grafana", "azure"]
categories = ["Cloud", "Monitoring"]
series = []
+++

## Use Case: End-to-End Monitoring for Azure Kubernetes Microservices

### Scenario

A SaaS company migrated its core applications to Azure Kubernetes Service (AKS) and needed full-stack observability across microservices, infrastructure, and cloud resources. The goal was to proactively detect issues, visualize performance, and alert on anomalies.

### Solution Overview

1. **Deploy Prometheus and Grafana** to AKS using Helm.
2. **Configure Prometheus** to scrape metrics from Kubernetes workloads and system components.
3. **Export custom application metrics** using Prometheus client libraries.
4. **Integrate Azure Monitor** for cloud-native insights.
5. **Create Grafana dashboards and alerting rules** for real-time visibility.

#### Step 1: Deploy Prometheus and Grafana via Helm

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
```

#### Step 2: Configure Prometheus Scrape for Custom App Metrics

Example `ServiceMonitor` to scrape metrics from a Python app on port 8000:

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

#### Step 3: Expose Application Metrics

Sample Python (Flask) app instrumented with `prometheus_client`:

```python
from flask import Flask
from prometheus_client import start_http_server, Counter

app = Flask(__name__)
REQUESTS = Counter('http_requests_total', 'Total HTTP Requests')

@app.route("/")
def hello():
    REQUESTS.inc()
    return "Hello, World!"

if __name__ == "__main__":
    start_http_server(8000)
    app.run(host="0.0.0.0", port=5000)
```

#### Step 4: Grafana Dashboard Example

Import a dashboard JSON or use the built-in Kubernetes/Prometheus dashboards. Example metric: `http_requests_total` visualized as a line graph.

#### Step 5: Alerting Example

Configure alert rules in Prometheus or Grafana, e.g.:

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
          summary: "High HTTP request rate detected"
```

### Key Benefits

- **Unified observability** across cloud and Kubernetes.
- **Proactive alerting** on performance and reliability.
- **Custom dashboards** for engineering and operations.

This approach enabled rapid troubleshooting and improved uptime for the organization’s cloud-native services.