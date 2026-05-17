#!/usr/bin/env python3
"""Regénère les bundles de messages du thème login DGCoop (UTF-8, français)."""
import urllib.request
from pathlib import Path

MSG_DIR = Path(__file__).resolve().parents[1] / "themes" / "dgcoop" / "login" / "messages"
URL = (
    "https://raw.githubusercontent.com/keycloak/keycloak/main/"
    "themes/src/main/resources-community/theme/base/login/messages/messages_fr.properties"
)

base = urllib.request.urlopen(URL, timeout=60).read().decode("utf-8")
if "# --- Surcharges" in base:
    base = base.split("# --- Surcharges")[0].rstrip() + "\n"

overrides = """
# --- Surcharges thème DGCoop (français uniquement) ---
loginTitle=Connexion - DGCoop
loginAccountTitle=Portail DGCoop
loginTitleHtml=Portail DGCoop
brandTagline=Système intégré de suivi et d''évaluation
brandSubtitle=Direction générale de la coopération (DGCooP) - République du Burkina Faso
brandFooter=© DGCooP - Accès réservé aux utilisateurs habilités
loginWelcomeMessage=Connectez-vous avec votre compte professionnel pour accéder à l''application.
username=Adresse e-mail professionnelle
usernameOrEmail=Adresse e-mail professionnelle
email=E-mail professionnel
password=Mot de passe
doLogIn=Se connecter
doForgotPassword=Mot de passe oublié ?
rememberMe=Se souvenir de moi
noAccount=Pas encore de compte ?
"""

content = base + overrides

for name in ("messages.properties", "messages_fr.properties", "messages_en.properties"):
    path = MSG_DIR / name
    path.write_text(content, encoding="utf-8", newline="\n")
    print(f"wrote {name} ({path.stat().st_size} bytes)")

for line in content.splitlines():
    if line.startswith("brandTagline="):
        print("OK", line[:80])
