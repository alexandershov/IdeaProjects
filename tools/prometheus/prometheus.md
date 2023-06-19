## Prometheus

Prometheus is a monitoring system.

Metric is a central concept in Prometheus.

Metric has a name and an attached list of key-value pairs (e.g. host=X, endpoint=Y, response_code=Z) 

Run prometheus using docker and local config
```shell
docker run -v /Users/aershov/IdeaProjects/tools/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml -p 9090:9090 prom/prometheus
```

Prometheus pulls metrics from the configured sources. See prometheus.yml for an example.

You can create alerts based on the values of metrics.

Self-scraping metrics are exposed on http://localhost:9090/metrics

Prometheus web-interface is running on http://localhost:9090

You can use PromQL (Prometheus query language) to look at metrics.

E.g: `prometheus_target_interval_length_seconds{quantile="0.99"}` and click "Execute".
This will show a list of values. Graph is available in the "Graph" tab.

