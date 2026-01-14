# Dockerfile pour Keycloak avec thèmes personnalisés
# Utilise l'image officielle Keycloak et ajoute les thèmes personnalisés

FROM quay.io/keycloak/keycloak:26.4.7

# Copier les thèmes personnalisés
COPY themes/ /opt/keycloak/themes/

# Les thèmes seront disponibles dans Keycloak après le démarrage
# Pour activer un thème, allez dans Keycloak Admin > Realm Settings > Themes
