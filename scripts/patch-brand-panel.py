#!/usr/bin/env python3
from pathlib import Path
import re

D = chr(100) + chr(105) + chr(118)  # HTML element name

path = Path(__file__).resolve().parents[1] / "themes" / "dgcoop" / "login" / "template.ftl"
text = path.read_text(encoding="utf-8")
text = text.replace("motion", D)

new_brand = f"""    <aside class="dgcoop-brand-panel">
        <{D} class="dgcoop-brand-inner">
            <{D} class="dgcoop-brand-top">
            <#if properties.logo?has_content>
                <img class="dgcoop-logo" src="${{url.resourcesPath}}/${{properties.logo}}" alt="DGCoop" />
            <#else>
                <{D} class="dgcoop-logo-text">DGCoop</{D}>
            </#if>
            </{D}>
            <{D} class="dgcoop-brand-copy">
                <p class="dgcoop-brand-tagline">Syst\u00e8me int\u00e9gr\u00e9 de suivi et d\u2019\u00e9valuation</p>
                <p class="dgcoop-brand-sub">Direction g\u00e9n\u00e9rale de la coop\u00e9ration (DGCooP)</p>
                <p class="dgcoop-brand-country">Burkina Faso</p>
            </{D}>
            <footer class="dgcoop-brand-footer">
                <span>\u00a9 DGCooP \u2014 Acc\u00e8s r\u00e9serv\u00e9 aux utilisateurs habilit\u00e9s</span>
            </footer>
        </{D}>
    </aside>"""

text, n = re.subn(
    r'<aside class="dgcoop-brand-panel">.*?</aside>',
    new_brand,
    text,
    count=1,
    flags=re.DOTALL,
)
if n != 1:
    raise SystemExit(f"aside block not replaced (n={n})")
path.write_text(text, encoding="utf-8", newline="\n")
print("ok", path)
