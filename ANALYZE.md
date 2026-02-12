● Analyse: Extension vs. BC-Standard

  Feature 1: Lagerdaten aus Arbeitsplan → FA-Zeilen & Komponenten

  ┌────────────────────────┬─────────────────────────────────────────────────────────────────┬────────────────────────────────────────────────────────────
  ───┐
  │ Aspekt                 │ BC-Standard                                                     │ Diese Extension
     │
  ├────────────────────────┼─────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────
  ───┤
  │ FA-Zeile Location Code │ Kommt vom Artikelstamm oder FA-Kopf                             │ Kommt vom letzten Arbeitsgang (WC/MC)
     │
  ├────────────────────────┼─────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────
  ───┤
  │ Routing-Zeilen Bins    │ Standard-Refresh überträgt Bins vom WC/MC auf Routing-Zeilen ✅ │ Macht dasselbe – redundant
     │
  ├────────────────────────┼─────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────
  ───┤
  │ Komponenten Location   │ Kommt von der Fertigungs-Stückliste oder vom Artikelstamm       │ Kommt von der passenden Routing-Zeile (via Routing Link
  Code) │
  ├────────────────────────┼─────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────────
  ───┤
  │ Komponenten Bin Code   │ "To-Production Bin" vom Lagerort oder WC/MC                     │ "To-Production Bin" von der zugeordneten Operation
     │
  └────────────────────────┴─────────────────────────────────────────────────────────────────┴────────────────────────────────────────────────────────────
  ───┘

  Bewertung Feature 1:

  Teilweise notwendig, teilweise redundant:

   - ✅ Sinnvoll & nicht Standard: Die Zuordnung der FA-Zeile Location aus dem letzten Arbeitsgang. Standard BC setzt diese vom Artikel/Kopf — bei
  Multi-Standort-Fertigung (z.B. Operation 10 in Standort A, Operation 20 in Standort B) will man, dass das Fertigprodukt am Standort der letzten
  Operation landet. Das macht Standard nicht.
   - ✅ Sinnvoll & nicht Standard: Die intelligente Komponentenzuordnung via Routing Link Code — Komponenten werden dem Standort der zugehörigen Operation
   zugeordnet. Standard BC nutzt dafür die Stückliste oder den Artikelstamm, nicht den Arbeitsplan.
   - ⚠️ Redundant: UpdateRoutingLinesForProdLine — der Standard-Refresh überträgt Bin-Codes bereits vom WC/MC auf Routing-Zeilen. Diese Logik dupliziert
  im Wesentlichen Standard-Verhalten.

  -------------------------------------------------------------------------------------------------------------------------------------------------------

  Feature 2: "Exclude from Planning"

  ┌────────────────────────────────────────────┬────────────────────┬───────────────────────────┐
  │ Aspekt                                     │ BC-Standard        │ Diese Extension           │
  ├────────────────────────────────────────────┼────────────────────┼───────────────────────────┤
  │ Bestellzeilen aus Planung ausschließen     │ ❌ Nicht vorhanden │ ✅ Boolean-Flag pro Zeile │
  ├────────────────────────────────────────────┼────────────────────┼───────────────────────────┤
  │ Umlagerungszeilen aus Planung ausschließen │ ❌ Nicht vorhanden │ ✅ Boolean-Flag pro Zeile │
  └────────────────────────────────────────────┴────────────────────┴───────────────────────────┘

  Bewertung: ✅ Klar notwendig — Standard BC bietet keine zeilenbasierte Möglichkeit, einzelne Bestell- oder Umlagerungszeilen aus der Produktionsplanung
  herauszunehmen.

  -------------------------------------------------------------------------------------------------------------------------------------------------------

  Fazit

  ┌───────────────────────────────────────────┬────────────────────────────────────────────────┐
  │ Feature                                   │ Notwendig?                                     │
  ├───────────────────────────────────────────┼────────────────────────────────────────────────┤
  │ FA-Zeile Location aus letztem Arbeitsgang │ ✅ Ja — kein Standard                          │
  ├───────────────────────────────────────────┼────────────────────────────────────────────────┤
  │ Komponenten-Location via Routing Link     │ ✅ Ja — kein Standard                          │
  ├───────────────────────────────────────────┼────────────────────────────────────────────────┤
  │ Routing-Zeilen Bin-Sync                   │ ⚠️ Fraglich — Standard-Refresh macht ähnliches │
  ├───────────────────────────────────────────┼────────────────────────────────────────────────┤
  │ Exclude from Planning                     │ ✅ Ja — kein Standard                          │
  └───────────────────────────────────────────┴────────────────────────────────────────────────┘

  Die Extension ist grundsätzlich berechtigt, insbesondere für Szenarien mit standortübergreifender Fertigung. Die Routing-Zeilen-Synchronisation (
  UpdateRoutingLinesForProdLine) könnte jedoch überflüssig sein und sollte geprüft werden, ob der Standard-Refresh diese Arbeit nicht bereits erledigt.
