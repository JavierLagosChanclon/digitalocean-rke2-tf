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