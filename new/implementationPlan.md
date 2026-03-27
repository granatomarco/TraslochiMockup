***

# Piano di Implementazione HTML — TDT IN & OUT (v2)
*4 file HTML — Ottimizzato per OpenCode + LLM — Vanilla HTML/CSS/JS*

***

## PREMESSA PER IL LLM

> **Regole assolute prima di iniziare:**
> - Leggi ogni file HTML esistente integralmente prima di modificarlo
> - Non ricreare da zero: espandi il DOM esistente
> - Nessun framework JS (jQuery, React, Vue, etc.) — solo vanilla
> - Nomi clienti inventati: **vanno bene**, mantienili o creane di plausibili
> - **Non inserire mai**: AML, Verifica Antiriciclaggio, export Excel, calcoli realtime, aggiornamenti automatici
> - Tutti gli stati mostrati devono corrispondere a stati reali del processo AEA/Salesforce
> - I bottoni azione nel cruscotto cambiano lo stato **nel DOM statico** (nessuna chiamata API)
> - Report mensile: sostituire con un link statico `[📊 Apri SAS Reports]` — nessuna generazione dinamica

***

## STRUTTURA FINALE: 4 FILE HTML

| File | Descrizione | Basato su |
|---|---|---|
| `tdtin-pratiche.html` | Lista pratiche TDT IN | `tdtin-11.html` (espandere) |
| `tdtin-isin.html` | Vista ISIN per singola pratica TDT IN | Nuovo da creare |
| `tdtout-pratiche.html` | Lista pratiche TDT OUT | `tdtout-12.html` (espandere) |
| `tdtout-isin.html` | Vista ISIN per singola pratica TDT OUT | Nuovo da creare |

Tutti e 4 condividono lo stesso sistema di navigazione e design system.

***

## SISTEMA DI DESIGN CONDIVISO

Definisci in un `<style>` comune (da copiare in tutti e 4 i file) questi token:

```css
:root {
  --color-bg:        #f8fafc;
  --color-surface:   #ffffff;
  --color-border:    #e2e8f0;
  --color-text:      #1e293b;
  --color-muted:     #64748b;

  /* Badge stati */
  --badge-attesa:    #f59e0b; /* giallo ambra */
  --badge-lavoraz:   #3b82f6; /* blu */
  --badge-ok:        #16a34a; /* verde */
  --badge-ko:        #dc2626; /* rosso */
  --badge-warn:      #ea580c; /* arancio */
  --badge-extra:     #7c3aed; /* viola */
  --badge-muted:     #94a3b8; /* grigio (archiviato) */

  --radius: 6px;
  --font: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}
```

**Layout struttura pagina (stessa in tutti i file):**
```
┌─────────────────────────────────────────────────┐
│  NAV: [📥 TDT IN ▾] [📤 TDT OUT ▾]  [Logo MB] │
├─────────────────────────────────────────────────┤
│  FILTRI BAR (collassabile)                      │
├─────────────────────────────────────────────────┤
│  TABELLA PRINCIPALE                             │
│  (righe con badge stato + bottoni azione)       │
├─────────────────────────────────────────────────┤
│  FOOTER: link SAS | data ultimo aggiornamento   │
└─────────────────────────────────────────────────┘
```

**Navigazione a dropdown:** Ogni menu `[📥 TDT IN ▾]` espande:
- → Lista Pratiche IN (`tdtin-pratiche.html`)
- → Dettaglio ISIN (`tdtin-isin.html`)

***

## FILE 1 — `tdtin-pratiche.html` (espandere da `tdtin-11.html`)

### Rimozioni obbligatorie [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/9e443b53-65e0-42b0-9566-7f0af2fcaea0/Analisi-funzionale-Traslochi-IN_-follow-up-3.docx)

Prima di ogni altra cosa, rimuovi dal DOM:
- **Qualsiasi riga o label con testo:** `"Verifica Antiriciclaggio"`, `"AML"`, `"Allarme Penale (90617)"` — **questo stato non esiste nel processo TDT IN**
- Sostituire il badge generico `"Scarto Controparte (90614)"` con etichetta corretta: `"KO – Penale a Credito"`
- Rimuovere qualsiasi riferimento a `"report mensile"` o `"export"` — al footer mettere solo link SAS

### Struttura filtri

Barra filtri sempre visibile (non collassabile nell'IN, ci sono poche opzioni):

```
[Stato ▾]  [Causale AEA ▾]  [Controparte ____]  [Data scad. da __] [a __]  [☐ Mostra archiviate]  [Reset]
```

Tutti i filtri agiscono via JS su `display:none/table-row` delle righe. **Nessun fetch, nessuna chiamata esterna.**

### Colonne tabella (ordine definitivo) [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/10455450-eb51-47d9-b722-be9cea8f58b1/PDD_MedioBanca_Traslochi-IN_v2.0.docx-9.pdf)

1. **Priorità** — icona sola: 🔴 se scadenza oggi o passata / 🟡 ≤ 3 gg / ◯ altro
2. **Pratica SF** — link testo (non aprire nulla, solo look cliccabile)
3. **NDG / Cliente** — nome + codice
4. **Banca Controparte** — nome banca (ABI)
5. **Causale AEA** — badge codice (vedi §stati)
6. **Fase corrente** — testo parlante **senza la parola "Step"** (es: `"Verifica Modulo"`, `"Inserimento in AEA"`, `"Verifica Trasferibilità"`)
7. **Stato lavorazione** — badge colorato
8. **Scadenza** — data (rosso se ≤ oggi, ◯ se futura, `-` se non presente)
9. **Reinserita** — `↺ Sì [→ pratica orig.]` oppure `-`
10. **Azioni** — bottoni contestuali (§azioni)

### Tabella stati — badge CSS [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/9e443b53-65e0-42b0-9566-7f0af2fcaea0/Analisi-funzionale-Traslochi-IN_-follow-up-3.docx)

Ogni `<tr>` ha `data-stato="..."` e `data-archiviata="si/no"`.

| Label visibile (testo badge) | data-stato | Colore var |
|---|---|---|
| Verifica Modulo | `verifica-modulo` | `--badge-attesa` |
| Inserimento in AEA | `inserimento-aea` | `--badge-lavoraz` |
| Attesa Risposta Controparte | `attesa-risposta` | `--badge-lavoraz` (opacity 0.7) |
| Verifica Trasferibilità | `verifica-trasf` | `--badge-attesa` |
| Trasferibile | `trasferibile` | `--badge-ok` |
| Non Trasferibile | `non-trasferibile` | `--badge-ko` |
| Da Verificare – Supporto | `da-verificare` | `--badge-attesa` |
| Contattare Advisory | `advisory` | `--badge-extra` |
| Carico AllFunds | `carico-allfunds` | `--badge-ok` |
| Invio Mail SIP | `invio-sip` | `--badge-lavoraz` |
| KO – Pratica Annullata | `ko-90165` | `--badge-ko` |
| KO – Penale a Credito | `ko-96114` | `--badge-ko` |
| KO – Penale a Debito | `ko-96115` | `--badge-ko` |
| KO – Retention Avvenuta | `ko-retention` | `--badge-extra` |
| Lavorazione Extra TDT | `extra-tdt` | `--badge-warn` |
| Esteri da Gestire | `esteri-90168` | `--badge-warn` |
| ⚠ Business Error | `business-error` | `--badge-ko` + icona ⚠ |
| 🔴 System Exception | `system-exception` | bordeaux `#7f1d1d` + icona 🔴 |
| ✅ Completata | `completata` | `--badge-muted` + archiviata |

**Regola archivio JS:** Le righe con `data-archiviata="si"` hanno `display:none` di default. Diventano visibili solo se `#filtro-archiviate` è spuntato. Sfondo `#f8fafc` sulle righe archiviate per distinguerle.

### Azioni per stato [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/10455450-eb51-47d9-b722-be9cea8f58b1/PDD_MedioBanca_Traslochi-IN_v2.0.docx-9.pdf)

La logica JS: `row.querySelector('.azioni').innerHTML = ...` in base al `data-stato`.

| Stato | Bottoni mostrati |
|---|---|
| `verifica-modulo` | `[📄 Visualizza Modulo]` → apre modal §modulo-IN + `[✓ Modulo OK]` + `[✗ KO Modulo]` |
| `business-error` / `system-exception` | `[✏ Modifica NDG]` (inline edit campo) + `[↺ Risubmit]` |
| `da-verificare` | `[✓ Trasferibile]` + `[✗ Non Trasferibile]` |
| `ko-96114` (prima occorrenza) | `[↺ Reinserisci]` |
| tutti gli stati attivi | `[→ Dettaglio ISIN]` (link a `tdtin-isin.html?pratica=XXX`) |
| `completata` / stati KO chiusi | `[👁 Dettaglio ISIN]` solo |

Ogni bottone che cambia stato mostra `confirm("Confermare l'azione?")` prima di aggiornare il DOM.

### Modal "Verifica Modulo" — TDT IN [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/9e443b53-65e0-42b0-9566-7f0af2fcaea0/Analisi-funzionale-Traslochi-IN_-follow-up-3.docx)

> **Differenza chiave vs OUT:** Nell'IN non si verifica la firma (la firma la controlla la controparte). Si controlla solo che il modulo sia **compilato e presente**. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/9e443b53-65e0-42b0-9566-7f0af2fcaea0/Analisi-funzionale-Traslochi-IN_-follow-up-3.docx)

Al click `[📄 Visualizza Modulo]`, apri `<dialog id="modal-modulo-in">`:

```
┌─────────────────────────────────────────────────────┐
│  Verifica Modulo TDT — [Nome Cliente] / [Pratica]   │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │                                              │  │
│  │        📄 Modulo TDT – Salesforce            │  │
│  │        (allegato al Case SF)                 │  │
│  │                                              │  │
│  │   [simulare con un rettangolo grigio         │  │
│  │    300px altezza, bordo tratteggiato,        │  │
│  │    testo centrato "Modulo TDT Firmato"       │  │
│  │    e icona PDF 📄]                           │  │
│  │                                              │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  ⚠ Verificare che il modulo sia compilato in       │
│  tutte le sue parti e che sia presente la firma.    │
│  La verifica della validità della firma è a        │
│  carico della controparte bancaria.                 │
│                                                     │
│  [✓ Modulo presente e completo – Procedi]          │
│  [✗ Modulo assente o incompleto – Blocca]          │
│  [✕ Chiudi senza modifiche]                        │
└─────────────────────────────────────────────────────┘
```

Al click `[✓ Procedi]`: cambia `data-stato` della riga in `inserimento-aea`, aggiorna il badge, chiudi il dialog.
Al click `[✗ Blocca]`: cambia `data-stato` in `business-error`, aggiorna badge.

### Dati di esempio (8 righe) [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/9e443b53-65e0-42b0-9566-7f0af2fcaea0/Analisi-funzionale-Traslochi-IN_-follow-up-3.docx)

Coprire almeno una riga per ogni scenario operativo:
1. `verifica-modulo` — Banca Sella, cliente Mario Bianchi
2. `inserimento-aea` — Banca Intesa, causale 90111
3. `verifica-trasf` — BNP Paribas, causale 90142, 5 ISIN
4. `da-verificare` — Banca Unicredit, causale 90142, 2 ISIN in attesa Supporto
5. `extra-tdt` — causale 90618, mail controparte già inviata
6. `ko-96114` — con flag reinserita: Sì, link pratica originale
7. `business-error` — NDG non coerente, bottone Modifica NDG visibile
8. `completata` (archiviata, nascosta di default) — causale 90143

***

## FILE 2 — `tdtin-isin.html` (nuovo)

Questa pagina mostra tutti gli **ISIN di una singola pratica** TDT IN. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/10455450-eb51-47d9-b722-be9cea8f58b1/PDD_MedioBanca_Traslochi-IN_v2.0.docx-9.pdf)

Nella barra in cima aggiungere un breadcrumb: `← Lista Pratiche / Pratica SF-20240312-001 / ISIN`

### Intestazione pratica (non tabella — card)

```
┌────────────────────────────────────────────────────────┐
│ Pratica:  SF-20240312-001     Causale AEA: 90142       │
│ Cliente:  Mario Bianchi       NDG: 45678901            │
│ Banca:    Banca Sella (ABI 03268)                      │
│ Scadenza: 02/04/2026  ← rosso se ≤ oggi               │
│ Stato pratica: [badge Verifica Trasferibilità]         │
└────────────────────────────────────────────────────────┘
```

### Tabella ISIN [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/10455450-eb51-47d9-b722-be9cea8f58b1/PDD_MedioBanca_Traslochi-IN_v2.0.docx-9.pdf)

Colonne:

1. **ISIN** — codice testo
2. **Denominazione** — nome strumento
3. **Tipologia** — `Amm. (90142)` / `Gest. (90143)`
4. **Divisa** — EUR / USD / GBP etc.
5. **Quote/Quantità**
6. **Depositaria** — `AllFunds Host` / `AllFunds Flash` / `State Street` / `Diretta` / `-`
7. **Flag Estero** — Sì / No
8. **Esito Trasferibilità** — badge: `Trasferibile` / `Non Trasferibile` / `Da Verificare` / `Contattare Advisory` / `Solo PG` / `In attesa` / `-`
9. **Nr. Operazione 3270** — numero se presente, `-` altrimenti
10. **Azioni ISIN** — solo se `Da Verificare`: `[✓ Trasfér.]` + `[✗ Non Trasfér.]`

### Stati badge ISIN

| Label | Colore |
|---|---|
| Trasferibile | `--badge-ok` |
| Non Trasferibile | `--badge-ko` |
| Da Verificare | `--badge-attesa` |
| Contattare Advisory | `--badge-extra` |
| Solo PG (nota) | `--badge-warn` |
| In attesa | `--badge-muted` |
| Elaborato | grigio chiaro, testo barrato |

### Dati esempio (8 ISIN per la pratica fittizia)

- 2 ISIN `Trasferibile` — depositaria AllFunds Host, nr. operazione presente
- 2 ISIN `Non Trasferibile` — piazza non servita
- 1 ISIN `Da Verificare` — con bottoni azione visibili
- 1 ISIN `Contattare Advisory` — ELTIF
- 1 ISIN `Esteri da Gestire` — flag Estero = Sì
- 1 ISIN `Elaborato` — riga grigio barrato

***

## FILE 3 — `tdtout-pratiche.html` (espandere da `tdtout-12.html`)

### Rimozioni obbligatorie [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/6d0b1a5a-724b-435b-acfd-c711cf3147f7/TDT-Incontro-5-Documenti-di-analisi-4.docx)

- Qualsiasi riga/label con testo `"Verifica Antiriciclaggio"` o `"AML"`
- Il label `"Lancia Step Due"` → rinominare in `"Avvia Scarico Titoli"` (Anna ha esplicitamente richiesto etichette parlanti) [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/3adf8a00-08e3-4298-99aa-c3032286d831/TDT-Incontro-4-Documenti-di-analisi-5.docx)

### Struttura filtri

```
[Stato ▾]  [Cliente/NDG ____]  [Modulo ▾]  [Firma ▾]  [Scad. da __][a __]  [☐ Mostra archiviate]  [Reset]
```

### Colonne tabella [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/6d0b1a5a-724b-435b-acfd-c711cf3147f7/TDT-Incontro-5-Documenti-di-analisi-4.docx)

1. **Priorità** — 🔴 se scadenza = oggi o passata / 🟡 ≤ 3gg / ◯ altro
2. **Pratica SF** — link testo
3. **NDG / Cliente**
4. **Banca Controparte** — nome (ABI)
5. **Scadenza** — data + countdown `"tra N gg"` in piccolo sotto (solo se ≤ 5 gg)
6. **Fase corrente** — testo parlante (es: `"Richiesta Modulo"`, `"Attesa Modulo Firmato"`, `"Verifica Firma"`, `"Verifica Trasferibilità"`, `"Scarico Titoli"`)
7. **Stato** — badge (§stati OUT)
8. **Modulo** — `📄 Ricevuto` / `⏳ In attesa` / `✗ KO`
9. **Firma** — `✅ Verificata` / `⏳ Da verificare` / `✗ Non conforme` / `-`
10. **Nr. ISIN** — contatore (es: `"5 ISIN"`)
11. **Azioni** — bottoni contestuali

### Tabella stati — badge [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/6d0b1a5a-724b-435b-acfd-c711cf3147f7/TDT-Incontro-5-Documenti-di-analisi-4.docx)

| Label visibile | data-stato | Colore |
|---|---|---|
| Richiesta Modulo a Controparte | `richiesta-modulo` | `--badge-lavoraz` |
| Attesa Modulo Firmato | `attesa-modulo` | `--badge-attesa` |
| Verifica Firma | `verifica-firma` | `--badge-extra` |
| Firma Non Conforme | `ko-firma` | `--badge-ko` |
| Verifica Trasferibilità | `verifica-trasf` | `--badge-attesa` |
| Trasferibile | `trasferibile` | `--badge-ok` |
| Non Trasferibile | `non-trasferibile` | `--badge-ko` |
| PAC Attivo – Estinzione | `pac-estinzione` | `--badge-warn` |
| Mancanza Provvista Imposta | `mancanza-imposta` | `--badge-warn` |
| Scarico Prenotato | `scarico-prenotato` | `--badge-ok` (opacity 0.7) |
| Scarico Titoli in Corso | `scarico-corso` | `--badge-ok` |
| KO – Retention | `ko-retention` | `--badge-extra` |
| KO – Penale a Debito | `ko-96115` | `--badge-ko` |
| ⚠ Business Error | `business-error` | `--badge-ko` + ⚠ |
| 🔴 System Exception | `system-exception` | bordeaux + 🔴 |
| ✅ Completata | `completata` | `--badge-muted` + archiviata |

### Azioni per stato [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/6d0b1a5a-724b-435b-acfd-c711cf3147f7/TDT-Incontro-5-Documenti-di-analisi-4.docx)

| Stato | Bottoni |
|---|---|
| `verifica-firma` | `[🔍 Verifica Firma]` → apre modal §firma-OUT |
| `ko-firma` | `[✗ Nega Pratica]` |
| `da-verificare` (ISIN) | `[✓ Trasferibile]` + `[✗ Non Trasferibile]` |
| `pac-estinzione` | `[✓ PAC Estinto – Procedi]` |
| `mancanza-imposta` | `[📋 Dettaglio Imposta]` → apre modal §imposta |
| `scarico-prenotato` | `[▶ Avvia Scarico Titoli]` (trigger manuale, con confirm) |
| `business-error` / `system-exception` | `[↺ Risubmit]` |
| tutti gli stati attivi | `[→ Dettaglio ISIN]` (link a `tdtout-isin.html`) |
| stati archiviati | `[👁 Dettaglio ISIN]` solo |

### Modal "Verifica Firma" — TDT OUT [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/6d0b1a5a-724b-435b-acfd-c711cf3147f7/TDT-Incontro-5-Documenti-di-analisi-4.docx)

> **Logica:** Il bot ha già salvato il modulo TDT dalla cartella di rete e ha estratto la firma da DocBank. L'operatore vede entrambi e decide. Non c'è confronto automatico AI — è sempre una decisione umana. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/6d0b1a5a-724b-435b-acfd-c711cf3147f7/TDT-Incontro-5-Documenti-di-analisi-4.docx)

```
<dialog id="modal-verifica-firma">

┌─────────────────────────────────────────────────────────────────┐
│  Verifica Firma — [Cliente] / Pratica [ID]                      │
│  ──────────────────────────────────────────────────────────────  │
│                                                                  │
│  ┌────────────────────────────┐  ┌─────────────────────────┐   │
│  │  📄 Modulo TDT ricevuto   │  │  ✍ Firma da DocBank     │   │
│  │  (dalla controparte)      │  │  (specimen depositato)  │   │
│  │                           │  │                         │   │
│  │  [placeholder rettangolo  │  │  [placeholder rettangolo│   │
│  │   bianco 400×500px        │  │   bianco 200×100px      │   │
│  │   bordo grigio            │  │   bordo grigio          │   │
│  │   testo centrato:         │  │   testo centrato:       │   │
│  │   "Modulo TDT             │  │   "Firma cliente        │   │
│  │    Controparte Banca X    │  │    da DocBank"]         │   │
│  │    [Data]"]               │  │                         │   │
│  │                           │  │  ──────────────────     │   │
│  │                           │  │  Firma presente         │   │
│  │                           │  │  nel modulo ricevuto:   │   │
│  │                           │  │  [placeholder 200×80px] │   │
│  └────────────────────────────┘  └─────────────────────────┘   │
│                                                                  │
│  ⚠ La verifica di conformità della firma è responsabilità      │
│  dell'operatore. Procedere solo se le firme sono congruenti.    │
│                                                                  │
│  [✅ Firma Conforme – Procedi alla Trasferibilità]              │
│  [✗ Firma Non Conforme – Nega Pratica]                         │
│  [✕ Chiudi]                                                     │
└─────────────────────────────────────────────────────────────────┘
```

Layout: due colonne CSS (`display:grid; grid-template-columns: 2fr 1fr`). Altezza fissa `500px` per la colonna sinistra con `overflow:auto`.

### Modal "Mancanza Provvista Imposta" [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/6d0b1a5a-724b-435b-acfd-c711cf3147f7/TDT-Incontro-5-Documenti-di-analisi-4.docx)

```
<dialog id="modal-imposta">

┌──────────────────────────────────────────────────┐
│  Verifica Capienza – Imposta Sostitutiva         │
│  ────────────────────────────────────────────   │
│  Pratica: SF-20240315-002  |  ISIN: IT0000001   │
│  Tipologia: Obbligazione (BTP)                  │
│  ────────────────────────────────────────────   │
│  Quantità titoli:       €  100.000,00           │
│  Aliquota (26%):        €   26.000,00           │
│  ────────────────────────────────────────────   │
│  Saldo c/c disponibile: €   12.450,00  ← ROSSO │
│  ────────────────────────────────────────────   │
│  ⛔ SALDO INSUFFICIENTE                         │
│  Causale: Mancanza Provvista Imposta            │
│  ────────────────────────────────────────────   │
│  [✓ Confermo – Segnala al gestore]             │
│  [✕ Chiudi]                                     │
└──────────────────────────────────────────────────┘
```

I valori sono statici nell'esempio HTML. Il saldo è colorato in rosso quando insufficiente (classe CSS `text-danger`).

### Dati di esempio (10 righe) [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/6d0b1a5a-724b-435b-acfd-c711cf3147f7/TDT-Incontro-5-Documenti-di-analisi-4.docx)

1. `attesa-modulo` — Banca Widiba, scadenza tra 5 gg
2. `verifica-firma` — Fineco Bank, scadenza oggi 🔴
3. `verifica-trasf` — ING Direct, 4 ISIN, trasferibilità in corso
4. `mancanza-imposta` — BNL, BTP obbligazione
5. `pac-estinzione` — Banca Generali, fondo con PAC attivo
6. `scarico-prenotato` — scadenza domani, bottone "Avvia Scarico Titoli"
7. `ko-firma` — firma non conforme, pratica bloccata
8. `ko-96115` — KO Penale a Debito, archiviata
9. `ko-retention` — cliente ha bloccato il trasferimento (90120)
10. `completata` — archiviata, nascosta di default

***

## FILE 4 — `tdtout-isin.html` (nuovo)

Stessa struttura di `tdtin-isin.html`, adattata al processo OUT.

### Intestazione pratica (card)

```
┌──────────────────────────────────────────────────────────┐
│ Pratica:  SF-20240315-002     Scadenza: 28/03/2026 🔴    │
│ Cliente:  Laura Ferrari       NDG: 78901234              │
│ Banca:    Fineco Bank (ABI 03015)                        │
│ Modulo:   📄 Ricevuto    Firma: ✅ Verificata            │
│ Stato pratica: [badge Scarico Prenotato]                 │
└──────────────────────────────────────────────────────────┘
```

### Tabella ISIN [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/42132473/6d0b1a5a-724b-435b-acfd-c711cf3147f7/TDT-Incontro-5-Documenti-di-analisi-4.docx)

Colonne adattate per OUT:

1. **ISIN** — codice
2. **Denominazione**
3. **Tipologia** — `Azione` / `Obbligazione` / `Fondo` / `ETF`
4. **Divisa**
5. **Quantità**
6. **Stato Trasferibilità** — badge (stessi colori di IN)
7. **Imposta Sostitutiva** — importo se obbligazione, `-` altrimenti
8. **Saldo Capiente** — `✅ Sì` / `⛔ No` / `-` (solo per obbligazioni)
9. **PAC Attivo** — `Sì` / `No`
10. **Nr. Operazione GNCS** — numero se scarico eseguito, `-` altrimenti
11. **Azioni ISIN** — contestuali

### Azioni ISIN in OUT

| Condizione | Bottoni |
|---|---|
| Stato = `Da Verificare` | `[✓ Trasferibile]` + `[✗ Non Trasferibile]` |
| PAC = `Sì` | `[✓ PAC Estinto]` |
| Saldo = `⛔ No` | `[📋 Dettaglio Imposta]` |
| ISIN completato | nessun bottone |

***

## COMPORTAMENTI JS COMUNI (tutti i file)

### Filtro archiviate
```javascript
document.getElementById('filtro-archiviate').addEventListener('change', function() {
  document.querySelectorAll('tr[data-archiviata="si"]').forEach(row => {
    row.style.display = this.checked ? 'table-row' : 'none';
  });
});
```

### Filtro stato
```javascript
document.getElementById('filtro-stato').addEventListener('change', function() {
  const val = this.value;
  document.querySelectorAll('tr[data-stato]').forEach(row => {
    const archiviata = row.dataset.archiviata === 'si';
    const matchStato = !val || row.dataset.stato === val;
    const archivioAttivo = document.getElementById('filtro-archiviate').checked;
    row.style.display = (matchStato && (!archiviata || archivioAttivo)) ? 'table-row' : 'none';
  });
});
```

### Ricerca libera
```javascript
document.getElementById('cerca').addEventListener('input', function() {
  const q = this.value.toLowerCase();
  document.querySelectorAll('tbody tr').forEach(row => {
    row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
  });
});
```

### Ordinamento colonne
Aggiungere `data-sort="text|date|priority"` sulle `<th>`. Al click, toggle `▲/▼` e riordinare `<tbody>` con JS. Nessuna libreria esterna.

### Dialog/Modal
Usare l'elemento nativo `<dialog>`. Aprire con `.showModal()`, chiudere con `.close()`. Aggiungere `backdrop { background: rgba(0,0,0,0.4) }` nel CSS.

***

## CHECKLIST FINALE PER IL LLM

Prima di consegnare ogni file, verificare punto per punto:

- [ ] Zero occorrenze di "AML", "Antiriciclaggio", "Step 1/2/3/4" come label visibili
- [ ] Zero bottoni "Export Excel" o "Scarica Report"
- [ ] Footer con link `[📊 Apri SAS Reports]` (link `href="#"`) presente
- [ ] Modal Verifica Modulo (IN) con layout a colonna singola + due bottoni OK/KO
- [ ] Modal Verifica Firma (OUT) con layout a **due colonne** — PDF a sinistra, firma a destra
- [ ] Modal Imposta con saldo colorato in rosso
- [ ] Filtro archiviate: default OFF, pratiche completate/KO nascoste
- [ ] Righe archiviate con sfondo `#f8fafc` quando visibili
- [ ] Bottone "Avvia Scarico Titoli" (non "Lancia Step Due") in OUT
- [ ] Breadcrumb nei file ISIN che torna alla lista pratiche
- [ ] Ordinamento colonne ▲/▼ funzionante
- [ ] Ricerca libera funzionante
- [ ] Dialog nativi `<dialog>` con `showModal()`/`close()`
- [ ] Nessun `import`, `require`, CDN esterno
- [ ] Tutti i 4 file collegati nella nav dropdown

***

## ORDINE DI ESECUZIONE SUGGERITO

Per un LLM con finestra di contesto limitata, processare nell'ordine:

1. Crea il CSS/design system comune (blocco `<style>`) — salvalo come snippet riutilizzabile
2. Modifica `tdtin-pratiche.html` → applica rimozioni → aggiungi filtri → aggiorna colonne → aggiorna stati → aggiungi modal verifica modulo → aggiorna dati esempio
3. Crea `tdtout-pratiche.html` da `tdtout-12.html` → stessa sequenza → aggiungi modal firma e imposta
4. Crea `tdtin-isin.html` da zero → applica design system → costruisci card intestazione + tabella ISIN
5. Crea `tdtout-isin.html` da zero → stessa struttura → adatta colonne per OUT
6. Aggiorna la nav in tutti e 4 i file con i link corretti tra loro