#!/usr/bin/env bash
# Crée les groupes de directions dans le realm sisegpc et ajoute le protocol mapper
# "direction" sur le client sisegpc_frontend.
# Idempotent : ne recrée pas ce qui existe déjà.
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

# ---------------------------------------------------------------------------
# 1. Créer les groupes de directions (idempotent)
# ---------------------------------------------------------------------------
DIRECTIONS="DCE-APD DCM DCB DSPF DAJA DP-ONG DCFD AUTRES_SERVICES"

# Récupère la liste JSON des groupes existants une seule fois
EXISTING_GROUPS="$(docker exec dgcoop_keycloak /opt/keycloak/bin/kcadm.sh get groups \
  --realm sisegpc 2>/dev/null || true)"

for DIR in $DIRECTIONS; do
  # Vérifie la présence du nom du groupe dans la réponse JSON
  if echo "$EXISTING_GROUPS" | grep -q "\"$DIR\""; then
    echo "Groupe $DIR : déjà existant"
  else
    docker exec dgcoop_keycloak /opt/keycloak/bin/kcadm.sh create groups \
      --realm sisegpc \
      -s "name=$DIR" >/dev/null
    echo "Groupe $DIR : créé"
  fi
done

# ---------------------------------------------------------------------------
# 2. Récupérer l'UUID du client sisegpc_frontend
# ---------------------------------------------------------------------------
CLIENT_JSON="$(docker exec dgcoop_keycloak /opt/keycloak/bin/kcadm.sh get clients \
  --realm sisegpc \
  -q clientId=sisegpc_frontend 2>/dev/null)"

# Extrait la valeur de "id" : première occurrence de "id" dans le JSON
CLIENT_UUID="$(echo "$CLIENT_JSON" | grep '"id"' | head -n1 | awk -F'"' '{print $4}')"

if [[ -z "$CLIENT_UUID" ]]; then
  echo "Client sisegpc_frontend introuvable dans le realm sisegpc" >&2
  exit 1
fi

echo "Client sisegpc_frontend UUID : $CLIENT_UUID"

# ---------------------------------------------------------------------------
# 3. Vérifier / créer le protocol mapper "direction"
# ---------------------------------------------------------------------------
MAPPERS_JSON="$(docker exec dgcoop_keycloak /opt/keycloak/bin/kcadm.sh get \
  "clients/$CLIENT_UUID/protocol-mappers/models" \
  --realm sisegpc 2>/dev/null || true)"

if echo "$MAPPERS_JSON" | grep -q '"direction"'; then
  echo "Protocol mapper 'direction' : déjà existant"
else
  docker exec dgcoop_keycloak /opt/keycloak/bin/kcadm.sh create \
    "clients/$CLIENT_UUID/protocol-mappers/models" \
    --realm sisegpc \
    -s 'name=direction' \
    -s 'protocol=openid-connect' \
    -s 'protocolMapper=oidc-group-membership-mapper' \
    -s 'consentRequired=false' \
    -s 'config."full.path"=false' \
    -s 'config."id.token.claim"=true' \
    -s 'config."access.token.claim"=true' \
    -s 'config."introspection.token.claim"=true' \
    -s 'config."claim.name"=direction' \
    -s 'config."multivalued"=true' \
    >/dev/null
  echo "Protocol mapper 'direction' : créé"
fi

echo "init-directions.sh terminé avec succès"
