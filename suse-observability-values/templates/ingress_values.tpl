ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
  hosts:
    - host: ${baseUrl}
  tls:
    - hosts:
        - ${baseUrl}
      secretName: tls-secret
opentelemetry-collector:
  ingress:
    enabled: true
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
      nginx.ingress.kubernetes.io/proxy-body-size: "50m"
      nginx.ingress.kubernetes.io/backend-protocol: GRPC
    hosts:
      - host: otlp-${baseUrl}
        paths:
          - path: /
            pathType: Prefix
            port: 4317
    tls:
      - hosts:
          - otlp-${baseUrl}
        secretName: otlp-tls-secret
    additionalIngresses:
      - name: otlp-http
        annotations:
          cert-manager.io/cluster-issuer: letsencrypt-prod
          nginx.ingress.kubernetes.io/proxy-body-size: "50m"
        hosts:
          - host: otlp-http-${baseUrl}
            paths:
              - path: /
                pathType: Prefix
                port: 4318
        tls:
          - hosts:
              - otlp-http-${baseUrl}
            secretName: otlp-http-tls-secret