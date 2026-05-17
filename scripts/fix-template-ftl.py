#!/usr/bin/env python3
"""Textes marque en dur dans template.ftl (évite clés i18n non résolues)."""
from pathlib import Path

path = Path(__file__).resolve().parents[1] / "themes" / "dgcoop" / "login" / "template.ftl"
text = path.read_text(encoding="utf-8")

replacements = [
    (
        '<p class="dgcoop-brand-tagline">${msg("brandTagline")}</p>',
        "<p class=\"dgcoop-brand-tagline\">Système intégré de suivi et d\u2019évaluation</p>",
    ),
    (
        '<p class="dgcoop-brand-sub">${msg("brandSubtitle")}</p>',
        "<p class=\"dgcoop-brand-sub\">Direction générale de la coopération (DGCooP) \u2014 République du Burkina Faso</p>",
    ),
    (
        '<span>${msg("brandFooter")}</span>',
        "<span>\u00a9 DGCooP \u2014 Accès réservé aux utilisateurs habilités</span>",
    ),
    (
        '<p class="dgcoop-welcome">${msg("loginWelcomeMessage")}</p>',
        "<p class=\"dgcoop-welcome\">Connectez-vous avec votre compte professionnel pour accéder à l\u2019application.</p>",
    ),
]
for old, new in replacements:
    if old in text:
        text = text.replace(old, new)
    else:
        print("skip (already patched?):", old[:50])

path.write_text(text, encoding="utf-8", newline="\n")
print("done", path)
