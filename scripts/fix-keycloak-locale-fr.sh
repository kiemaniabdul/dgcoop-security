#!/usr/bin/env bash
# Force le realm sisegpc en français uniquement.
# Déployé sur /opt/dgcoop/scripts/ par le pipeline dgcoop-security (branche deploy).
set -euo pipefail

DEPLOY_DIR="${DEPLOY_DIR:-/opt/dgcoop}"
ENV_FILE="${ENV_FILE:-$DEPLOY_DIR/.env}"
ADMIN_USER="${KEYCLOAK_ADMIN_USER:-admin}"
ADMIN_PASS="${KEYCLOAK_ADMIN_PASSWORD:-}"

if [[ -z "$ADMIN_PASS" && -f "$ENV_FILE" ]]; then
  ADMIN_PASS="$(grep '^KEYCLOAK_ADMIN_PASSWORD=' "$ENV_FILE" | cut -d= -f2- | tr -d '\r' || true)"
fi

if [[ -z "$ADMIN_PASS" ]]; then
  echo "Définir KEYCLOAK_ADMIN_PASSWORD dans $ENV_FILE ou l'environnement" >&2
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q '^dgcoop_keycloak$'; then
  echo "Conteneur dgcoop_keycloak absent — démarrer Keycloak avant ce script" >&2
  exit 1
fi

# Keycloak peut mettre quelques secondes à accepter kcadm après un recreate
for i in $(seq 1 30); do
  if docker exec dgcoop_keycloak /opt/keycloak/bin/kcadm.sh config credentials \
    --server "http://localhost:8081" --realm master \
    --user "$ADMIN_USER" --password "$ADMIN_PASS" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

docker exec dgcoop_keycloak /opt/keycloak/bin/kcadm.sh update realms/sisegpc \
  -s internationalizationEnabled=false \
  -s 'supportedLocales=["fr"]' \
  -s defaultLocale=fr

echo "Realm sisegpc : locale par défaut = fr"
