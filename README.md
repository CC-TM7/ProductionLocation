● Kernlogik des Projekts

  Hauptzweck:
  Automatische Übernahme von Lagerort- und Lagerplatzdaten aus Arbeitsplänen (Work Center/Machine Center) in Fertigungsaufträge und deren Komponenten.

  Die 3 Hauptprozesse:

  1. Fertigungsauftrag-Zeilen aktualisieren

   - Ermittelt die letzte Operation im Arbeitsplan einer FA-Zeile
   - Holt Lagerort & "From-Production Bin" vom Work Center/Machine Center
   - Setzt diese Werte auf die FA-Zeile (fertiges Produkt landet dort)

  2. Arbeitsplan-Zeilen synchronisieren

   - Aktualisiert alle Operationen einer FA-Zeile mit Lagerdaten aus WC/MC:
    - Location Code
    - Open Shop Floor Bin
    - To-Production Bin (Materialentnahme)
    - From-Production Bin (Ausgangslager)

  3. Komponenten intelligent zuordnen

   - Wenn Komponente einen Routing Link Code hat → sucht passende Operation
   - Sonst: Fallback auf erste Operation
   - Setzt Lagerort & "To-Production Bin" der Operation (Material wird dort entnommen)

  Zusatzfeatures:

   - "Exclude from Planning" Flag für Bestellungen & Umlagerungen → hält sie aus der Produktionsplanung raus
   - Feature-Toggle in Manufacturing Setup aktiviert/deaktiviert die gesamte Logik
   - Manuelle Aktion "Lagerorte aktualisieren" im Fertigungsauftrag + automatische Trigger bei Routing-Änderungen
