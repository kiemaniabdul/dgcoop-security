# Directions SISEGPC — Groupes Keycloak

## Quand et comment exécuter le script

Exécuter `init-directions.sh` **une seule fois après le premier déploiement** de Keycloak,
ou après un `docker compose down -v` (réinitialisation complète de la base).
Le script est **idempotent** : il peut être relancé sans danger.

```bash
# Depuis le serveur de déploiement :
bash /opt/dgcoop/scripts/init-directions.sh
```

Les variables `KEYCLOAK_ADMIN_USER` et `KEYCLOAK_ADMIN_PASSWORD` sont lues
automatiquement depuis `/opt/dgcoop/.env` si elles ne sont pas exportées.

## Assigner un utilisateur à une direction (console Keycloak Admin)

1. Ouvrir `https://<hôte>/auth/admin` → realm **sisegpc**.
2. Menu **Users** → sélectionner l'utilisateur.
3. Onglet **Groups** → cliquer **Join Group**.
4. Choisir la direction (ex. `DCE-APD`) → **Join**.

Un utilisateur peut appartenir à plusieurs groupes si nécessaire.

## Le claim `direction` dans le JWT

Après connexion, le JWT d'accès contient un tableau `direction` :

```json
{ "direction": ["DCE-APD"] }
```

**Vérifier avec jwt.io** : coller le token dans <https://jwt.io> et lire la
section *Payload*. On peut aussi décoder manuellement la partie centrale
(base64url) :

```bash
echo "<partie_payload>" | base64 -d 2>/dev/null | python3 -m json.tool
```

## Impact sur les droits applicatifs

| Situation | Valeur du claim | Accès |
|---|---|---|
| Utilisateur AGENT avec groupe assigné | `["DCE-APD"]` | Saisie + consultation pour sa direction |
| Utilisateur AGENT **sans** groupe | `[]` | Consultation uniquement |
| Rôle ADMIN | _(non contraint par direction)_ | Accès complet |
