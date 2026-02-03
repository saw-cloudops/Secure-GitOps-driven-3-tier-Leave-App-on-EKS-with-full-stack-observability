/* instrumentation.js */
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { PrometheusExporter } = require('@opentelemetry/exporter-prometheus');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http'); // OTLP exporter for Tempo
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');


// Metrics: Prometheus Exporter listening on port 9464
const metricsExporter = new PrometheusExporter({
    port: 9464,
    endpoint: '/metrics',
}, () => {
    console.log('Prometheus metrics ready at :9464/metrics');
});

// Tracing: OTLP Exporter (Sends to Tempo/Jaeger)
// Default URL is http://localhost:4318/v1/traces (Configurable via OTEL_EXPORTER_OTLP_ENDPOINT)
const traceExporter = new OTLPTraceExporter();

const sdk = new NodeSDK({
    serviceName: 'leave-backend',
    metricReader: metricsExporter,
    traceExporter: traceExporter,
    instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();

// Graceful shutdown
process.on('SIGTERM', () => {
    sdk.shutdown()
        .then(() => console.log('Tracing/Metrics terminated'))
        .catch((error) => console.log('Error terminating', error))
        .finally(() => process.exit(0));
});

module.exports = sdk;
