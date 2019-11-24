# Tradebot

Tradebot is a tiny web api made with Go that takes array of stock prices and returns the best profit one could have made from 1 purchase and 1 sale using best practices of running microservices in Kubernetes.

## Features

- Health checks (readiness and liveness)
- Graceful shutdown on interrupt signals
- File watcher for secrets and configmaps
- Instrumented with Prometheus
- Tracing with Istio and Jaeger
- Linkerd service profile
- Structured logging with zap
- 12-factor app with viper
- Fault injection (random errors and latency) for chaos engineering
- Helm and Kustomize installers
- End-to-End testing with Kubernetes Kind and Helm
- Kustomize testing with GitHub Actions and Open Policy Agent
- Expose Kubernetes services over HTTPS with Ngrok
- Managing Helm releases the GitOps way
- Swagger docs
- Web Socket implementation (Since this is a trading API, I thought web socket implementation should be made available. So added a sample implmentation)

### API Documentation
![API Swagger Docs](https://raw.githubusercontent.com/praveensastry/tradebot/master/assets/swagger_screenshot.png)
Web API:

- `GET /trade/profit` calculates max profit for given prices
- `GET /version` prints tradebot version and git commit hash
- `GET /metrics` return HTTP requests duration and Go runtime metrics
- `GET /healthz` used by Kubernetes liveness probe
- `GET /readyz` used by Kubernetes readiness probe
- `POST /readyz/enable` signals the Kubernetes LB that this instance is ready to receive traffic
- `POST /readyz/disable` signals the Kubernetes LB to stop sending requests to this instance
- `GET /configs` returns a JSON with configmaps and/or secrets mounted in the `config` volume
- `GET /ws/echo` echos content via websockets `cli ws ws://localhost:9898/ws/echo`
- `GET /swagger.json` returns the API Swagger docs, used for Linkerd service profiling and Gloo routes discovery

gRPC API:

- `/grpc.health.v1.Health/Check` health checking

### Test

Docker:

```bash
docker run -dp 9898:9898 praveensastry/tradebot

curl -X POST \
  http://localhost:9898/trade/profit \
  -H 'Cache-Control: no-cache' \
  -H 'Postman-Token: 01d1b1da-64cf-406f-b7f7-ce08859382f1' \
  -d '{
"prices": [10, 7, 5, 8, 11, 9]
}'
```

Local:

```bash
# Clone the source
# In the project root directory run the below command
go run cmd/tradebot/main.go

curl -X POST \
  http://localhost:9898/trade/profit \
  -H 'Cache-Control: no-cache' \
  -H 'Postman-Token: 01d1b1da-64cf-406f-b7f7-ce08859382f1' \
  -d '{
"prices": [10, 7, 5, 8, 11, 9]
}'
```

P.S. While testing you might have approve access if you see the below dialog
![Permission Dialog](https://raw.githubusercontent.com/praveensastry/tradebot/master/assets/permission.png)

### Install on Kubernetes

Helm:

```bash
helm repo add tradebot https://praveensastry.github.io/tradebot

helm upgrade --install --wait frontend \
--namespace test \
--set replicaCount=2 \
--set backend=http://backend-tradebot:9898/echo \
tradebot/tradebot

helm test frontend --cleanup

helm upgrade --install --wait backend \
--namespace test \
--set hpa.enabled=true \
tradebot/tradebot
```

Kustomize:

```bash
kubectl apply -k github.com/praveensastry/tradebot//kustomize
```
