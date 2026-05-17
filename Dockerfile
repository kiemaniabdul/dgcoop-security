# Étape de build : pré-compile la configuration optimisée pour la production.
# KC_DB=postgres est figé dans l'image ; les autres valeurs (URL, password, hostname)
# sont passées en variables d'environnement au démarrage via docker-compose.
FROM quay.io/keycloak/keycloak:26.4.7 AS builder

ENV KC_DB=postgres
ENV KC_HTTP_ENABLED=true
ENV KC_HTTP_PORT=8081
ENV KC_HTTP_MANAGEMENT_PORT=9090
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_HTTP_MANAGEMENT_ENABLED=true
# Obligatoire au build pour start --optimized derrière Nginx (sinon redirects :8081)
ENV KC_PROXY_HEADERS=xforwarded

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:26.4.7

USER root
RUN microdnf install -y curl && microdnf clean all
USER 1000

COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY themes/ /opt/keycloak/themes/

EXPOSE 8081 9090

# ENTRYPOINT = le binaire, CMD = arguments par défaut.
# docker-compose peut surcharger CMD pour ajouter --import-realm sans réécrire toute la commande.
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]
