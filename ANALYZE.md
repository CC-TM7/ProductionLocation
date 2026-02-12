# Analyse: Extension vs. Business Central Standard

## Überblick
Diese Analyse bewertet, welche Funktionalitäten durch den **Business Central Standard** abgedeckt sind und wo eine **Extension** fachlich notwendig oder redundant erscheint.

---

# Feature 1: Lagerdaten aus Arbeitsplan → FA-Zeilen & Komponenten

## Vergleich

| Aspekt | BC-Standard | Diese Extension |
|--------|------------|----------------|
| **FA-Zeile Location Code** | Kommt vom Artikelstamm oder FA-Kopf | Kommt vom letzten Arbeitsgang (WC/MC) |
| **Routing-Zeilen Bins** | Standard-Refresh überträgt Bins vom WC/MC auf Routing-Zeilen ✅ | Macht dasselbe – redundant |
| **Komponenten Location** | Kommt von der Fertigungs-Stückliste oder vom Artikelstamm | Kommt von der passenden Routing-Zeile (via Routing Link Code) |
| **Komponenten Bin Code** | "To-Production Bin" vom Lagerort oder WC/MC | "To-Production Bin" von der zugeordneten Operation |

---

## Bewertung Feature 1

**Teilweise notwendig, teilweise redundant**

### ✅ Sinnvoll & nicht im Standard enthalten

**FA-Zeile Location aus letztem Arbeitsgang**  
Standard Business Central setzt die Location vom Artikel oder FA-Kopf.  

Bei **Multi-Standort-Fertigung** (z.B. Operation 10 in Standort A, Operation 20 in Standort B) entsteht jedoch die fachliche Erwartung, dass das Fertigprodukt am Standort der letzten Operation eingebucht wird.  

👉 Diese Logik bildet der Standard nicht ab.

---

**Intelligente Komponentenzuordnung via Routing Link Code**  
Komponenten werden automatisch dem Standort der zugehörigen Operation zugeordnet.

Standard BC nutzt hierfür:

- Stückliste  
- Artikelstamm  

Nicht jedoch den Arbeitsplan.

👉 Besonders wertvoll bei:

- verteilter Fertigung  
- standortübergreifenden Materialflüssen  
- höherer Automatisierung  

---

### ⚠️ Potenziell redundant

**UpdateRoutingLinesForProdLine**

Der Standard-Refresh überträgt bereits:

👉 Bin-Codes vom Work Center / Machine Center auf Routing-Zeilen.

Die Extension dupliziert hier vermutlich bestehende Standardlogik.

**Empfehlung:**  
Prüfen, ob diese Erweiterung entfernt werden kann, um:

- technische Schuld zu reduzieren  
- Upgrade-Risiken zu minimieren  
- Systemkomplexität zu senken  

---

# Feature 2: "Exclude from Planning"

## Vergleich

| Aspekt | BC-Standard | Diese Extension |
|--------|------------|----------------|
| **Bestellzeilen aus Planung ausschließen** | ❌ Nicht vorhanden | ✅ Boolean-Flag pro Zeile |
| **Umlagerungszeilen aus Planung ausschließen** | ❌ Nicht vorhanden | ✅ Boolean-Flag pro Zeile |

---

## Bewertung Feature 2

✅ **Klar notwendig**

Der Standard bietet **keine zeilenbasierte Steuerung**, um einzelne Bestell- oder Umlagerungszeilen gezielt aus der Produktionsplanung herauszunehmen.

Typische Use Cases:

- manuelle Dispositionsentscheidungen  
- Sonderbeschaffungen  
- Projektgeschäft  
- temporäre Engpasssteuerung  

👉 Hoher operativer Nutzen bei minimalem architektonischem Risiko.

---

# Fazit

| Feature | Notwendig? |
|--------|-------------|
| **FA-Zeile Location aus letztem Arbeitsgang** | ✅ Ja — kein Standard |
| **Komponenten-Location via Routing Link** | ✅ Ja — kein Standard |
| **Routing-Zeilen Bin-Sync** | ⚠️ Fraglich — Standard-Refresh deckt ähnliches ab |
| **Exclude from Planning** | ✅ Ja — kein Standard |

---

## Gesamtbewertung

Die Extension ist grundsätzlich **architektonisch gerechtfertigt**, insbesondere für Szenarien mit:

- standortübergreifender Fertigung  
- komplexen Materialflüssen  
- höherem Automatisierungsgrad  

**Optimierungspotenzial besteht jedoch bei redundanter Logik.**

Die Routing-Zeilen-Synchronisation (`UpdateRoutingLinesForProdLine`) sollte kritisch geprüft werden, da der Standard-Refresh diese Funktion möglicherweise bereits erfüllt.

---

## Architektonische Empfehlung

> **Standard, wo möglich — Extension, wo wertschöpfend.**

Gezielte Erweiterungen schaffen Differenzierung.  
Redundante Erweiterungen erzeugen dagegen langfristige Systemlast.
