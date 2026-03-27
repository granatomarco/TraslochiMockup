# Memoria Implementazione TDT IN & OUT v2

## Ultimo aggiornamento: 2026-03-26 - CORREZIONI UX: DATE DINAMICHE, AZIONI COME TRASLOCHI IN

---

## OBIETTIVO
Creare 4 file HTML partendo dal layout esistente di tdtin.html e tdtout.html, aggiungendo le feature richieste.

## REGRE FONDAMENTALI
- MANTENERE il layout grafico esistente (navbar, stili, colori, struttura)
- NON creare layout da zero
- Usare SOLO Material Icons da Google Fonts (NO unicode/emoji)
- 4 link in navbar: TDT IN | TDT OUT | Traslochi IN | Traslochi OUT
- Rimuovere: AML, Antiriciclaggio, Export Excel, report mensile
- Footer con link [Apri SAS Reports] usando Material Icons
- Tutte le pagine devono avere il pulsante "Elenco Feature"
- Azioni in tabella: sempre eye icon button PRIMA + un'azione rapida
- Modal dettaglio con storico eventi (business-history)
- Tutte le azioni devono essere funzionali con conferma modale
- ISIN details nel modal dettaglio (NON pagine separate con bottone ISIN)
- Azioni con dropdown priorità per invio in coda

---

## FILE DA CREARE

| # | File (nuovo nome) | Vecchio nome | Basato su | Stato |
|---|------|-----------|-------|
| 1 | pratiche-in.html | tdtin-pratiche.html | tdtin.html | ✅ COMPLETATO |
| 2 | dettaglio-in.html | tdtin-isin.html | Nuovo | ✅ COMPLETATO |
| 3 | pratiche-out.html | tdtout-pratiche.html | tdtout.html | ✅ COMPLETATO |
| 4 | dettaglio-out.html | tdtout-isin.html | Nuovo | ✅ COMPLETATO |

**Nota:** I file originali tdtin.html e tdtout.html ora hanno link a pratiche-in.html e pratiche-out.html nella navbar.

---

## NAVIGAZIONE (stessa in tutti i 4 file)

```html
<div class="nav-menu">
    <span class="nav-link active"><span class="material-icons">login</span> TDT IN</span>
    <span class="nav-link"><span class="material-icons">logout</span> TDT OUT</span>
    <span class="nav-link" onclick="window.location.href='tdtin.html'"><span class="material-icons">login</span> Traslochi IN</span>
    <span class="nav-link" onclick="window.location.href='tdtout.html'"><span class="material-icons">logout</span> Traslochi OUT</span>
</div>
```

---

## STEP 1: tdtin-pratiche.html (basato su tdtin.html)

### Da rimuovere
- Riferimenti a "Verifica Antiriciclaggio", "AML", "Allarme Penale (90617)"
- "Scarto Controparte (90614)" → "KO – Penale a Credito"
- Riferimenti a "report mensile" / "export"

### Struttura filtri (aggiornare select)
- Stato Lavorazione → nuovi stati TDT IN
- Causale AEA ▾
- Controparte
- Data scad. da / a
- ☑ Mostra archiviate

### Colonne tabella (nuovo ordine)
1. Priorità (icona: 🔴 scaduta / 🟡 ≤3gg / ⚪ altro)
2. Pratica SF
3. NDG / Cliente
4. Banca Controparte
5. Causale AEA (badge codice)
6. Fase corrente (senza "Step")
7. Stato lavorazione (badge colorato)
8. Scadenza
9. Reinserita
10. Azioni

### Badge stati TDT IN
| Stato | Badge |
|-------|-------|
| verifica-modulo | giallo |
| inserimento-aea | blu |
| attesa-risposta | blu (opacity) |
| verifica-trasf | giallo |
| trasferibile | verde |
| non-trasferibile | rosso |
| da-verificare | giallo |
| advisory | viola |
| carico-allfunds | verde |
| invio-sip | blu |
| ko-90165 | rosso |
| ko-96114 | rosso |
| ko-96115 | rosso |
| ko-retention | viola |
| extra-tdt | arancio |
| esteri-90168 | arancio |
| business-error | rosso + ⚠ |
| system-exception | bordeaux + 🔴 |
| completata | grigio (archiviata) |

### Azioni per stato
- verifica-modulo: [Visualizza Modulo] [Modulo OK] [KO Modulo]
- business-error/system-exception: [Modifica NDG] [Risubmit]
- da-verificare: [Trasferibile] [Non Trasferibile]
- ko-96114: [Reinserisci]
- tutti stati attivi: [Dettaglio ISIN]
- completata/KO chiusi: solo [Dettaglio ISIN] readonly

### Modal Verifica Modulo (colonna singola)
- Preview PDF
- Nota: verifica modulo a carico controparte
- [✓ Procedi] [✗ Blocca] [Chiudi]

### Dati esempio (8 righe)
1. verifica-modulo — Banca Sella, Mario Bianchi
2. inserimento-aea — Banca Intesa, 90111
3. verifica-trasf — BNP Paribas, 90142
4. da-verificare — Unicredit, 90142
5. extra-tdt — causale 90618
6. ko-96114 — reinserita Sì
7. business-error — con Modifica NDG
8. completata — archiviata

---

## STEP 2: tdtout-pratiche.html (basato su tdtout.html)

### Da rimuovere
- "Verifica Antiriciclaggio", "AML"
- "Lancia Step Due" → "Avvia Scarico Titoli"

### Aggiungere colonna Modulo e Firma
- Modulo: 📄 Ricevuto / ⏳ In attesa / ✗ KO
- Firma: ✅ Verificata / ⏳ Da verificare / ✗ Non conforme

### Badge stati TDT OUT
| Stato | Badge |
|-------|-------|
| richiesta-modulo | blu |
| attesa-modulo | giallo |
| verifica-firma | viola |
| ko-firma | rosso |
| verifica-trasf | giallo |
| trasferibile | verde |
| non-trasferibile | rosso |
| pac-estinzione | arancio |
| mancanza-imposta | arancio |
| scarico-prenotato | verde (opacity) |
| scarico-corso | verde |
| ko-retention | viola |
| ko-96115 | rosso |
| business-error | rosso + ⚠ |
| system-exception | bordeaux + 🔴 |
| completata | grigio (archiviata) |

### Modal Verifica Firma (due colonne)
- Colonna sinistra: PDF modulo (2fr)
- Colonna destra: Firma DocBank (1fr)
- [✓ Conforme] [✗ Non Conforme] [Chiudi]

### Modal Mancanza Imposta
- Grid con importi
- Saldo colorato rosso
- ⛔ SALDO INSUFFICIENTE

### Dati esempio (10 righe)
1. attesa-modulo — Widiba, scad 5gg
2. verifica-firma — Fineco, scad oggi
3. verifica-trasf — ING, 4 ISIN
4. mancanza-imposta — BNL, BTP
5. pac-estinzione — Generali, PAC attivo
6. scarico-prenotato — scad domani, [Avvia Scarico Titoli]
7. ko-firma — non conforme
8. ko-96115 — archiviata
9. ko-retention — bloccato
10. completata — archiviata

---

## STEP 3: tdtin-isin.html (nuovo)

### Struttura
- Breadcrumb: ← Lista Pratiche / Pratica / ISIN
- Card intestazione pratica (6 campi)
- Tabella ISIN (10 colonne)

### Card pratica
```
Pratica: SF-XXX    Causale AEA: 90142
Cliente: Nome      NDG: XXXXX
Banca: Nome       Scadenza: XX/XX/XXXX (rosso se ≤ oggi)
Stato: [badge]
```

### Colonne ISIN TDT IN
1. ISIN
2. Denominazione
3. Tipologia (Amm./Gest.)
4. Divisa
5. Quote/Quantità
6. Depositaria
7. Flag Estero
8. Esito Trasferibilità
9. Nr. Operazione 3270
10. Azioni (solo se Da Verificare)

### Dati esempio (8 ISIN)
- 2 Trasferibile (AllFunds Host)
- 2 Non Trasferibile (piazza non servita)
- 1 Da Verificare (con azioni)
- 1 Contattare Advisory (ELTIF)
- 1 Esteri da Gestire
- 1 Elaborato (barrato)

---

## STEP 4: tdtout-isin.html (nuovo)

### Struttura (stessa di tdtin-isin.html)
- Breadcrumb
- Card intestazione (con Modulo e Firma)
- Tabella ISIN (11 colonne, adattata OUT)

### Card pratica OUT (aggiungere)
```
Modulo: 📄 Ricevuto    Firma: ✅ Verificata
```

### Colonne ISIN TDT OUT
1. ISIN
2. Denominazione
3. Tipologia (Azione/Obbligazione/Fondo/ETF)
4. Divisa
5. Quantità
6. Stato Trasferibilità
7. Imposta Sostitutiva
8. Saldo Capiente (✅/⛔)
9. PAC Attivo
10. Nr. Operazione GNCS
11. Azioni

### Azioni ISIN OUT
- Da Verificare: [Trasferibile] [Non Trasferibile]
- PAC = Sì: [PAC Estinto]
- Saldo = ⛔: [Dettaglio Imposta]
- Completato: -

---

## CHECKLIST FINALE

- [ ] Zero "AML", "Antiriciclaggio", "Step 1/2/3/4"
- [ ] Zero "Export Excel" o "Scarica Report"
- [ ] Footer con [📊 Apri SAS Reports]
- [ ] Modal Verifica Modulo (IN) - colonna singola
- [ ] Modal Verifica Firma (OUT) - due colonne
- [ ] Modal Imposta - saldo rosso
- [ ] Filtro archiviate default OFF
- [ ] "Avvia Scarico Titoli" in OUT
- [ ] Breadcrumb nei file ISIN
- [ ] 4 link nav: TDT IN, TDT OUT, Traslochi IN, Traslochi OUT

---

## NOTES
- Layout preso da tdtin.html e tdtout.html originali
- Mantenere stessi stili CSS
- Material Icons da Google Fonts
- Vanilla JS only (no framework)

---

## CORREZIONI APPORTATE (2026-03-26)

### 1. Icone Priorita
Prima: `&#128308;` (unicode rosso), `&#128大使;` (unicode grigio)
Dopo: `<span class="material-icons prio-icon prio-red">flag</span>`
- 🔴 Red/urgent = `flag`
- 🟡 Yellow/≤3gg = `schedule`
- ⚪ Gray/normal = `radio_button_unchecked`

### 2. Icone di Stato
Prima: `✅`, `⏳`, `✗`, `📄`, `⛔`
Dopo: Material Icons `<span class="material-icons">check_circle</span>`, etc.

### 3. Struttura Azioni
Prima: solo un'azione per riga
Dopo: eye icon `<button class="btn-icon">` PRIMA + azione rapida

### 4. Elenco Feature Button
Aggiunto in tutte le 4 pagine:
```html
<button class="btn btn-primary" onclick="openModal('modal-feature')">
    <span class="material-icons">military_tech</span> Elenco Feature
</button>
```

### 5. Modal Dettaglio con Storico
Aggiunto in tutte le pagine pratiche:
- Dettaglio pratica (4 colonne info)
- Storico Eventi (business-history)
- Area Azioni contestuale

### 6. Footer SAS Reports
Prima: `[📊 Apri SAS Reports]`
Dopo: `<span class="material-icons">bar_chart</span> Apri SAS Reports`

### 7. Azioni Funzionali
Tutte le azioni ora usano `confirm()` per conferma:
```javascript
function azioneRapida(rowId, stato, nuovoStato, msg) {
    if (!confirm(msg)) return;
    // ... logica
}
```

### 8. Colonna "Reinserita" rimossa
Non piu presente in nessuna tabella pratiche.

### 9. Rinomina file (2026-03-26)
- tdtin-pratiche.html → pratiche-in.html
- tdtin-isin.html → dettaglio-in.html
- tdtout-pratiche.html → pratiche-out.html
- tdtout-isin.html → dettaglio-out.html

### 10. Link TDT IN/OUT nella navbar (originali)
- Aggiunti link a pratiche-in.html e pratiche-out.html in tdtin.html e tdtout.html

### 11. ISIN nel modal dettaglio
- I dettagli ISIN sono ora visualizzati direttamente nel modal dettaglio (apriDettaglio)
- Il pulsante "ISIN" nelle righe della tabella e stato rimosso
- Le tabelle pratiche-out.html hanno ISIN table nel modal con dati di esempio

### 12. Ordinamento tabella (2026-03-26 - Sessione 2)
Aggiunto sorting alle tabelle pratiche-in.html e pratiche-out.html:
```css
th { cursor: pointer; user-select: none; }
th .sort-icon { font-size: 16px; opacity: 0.3; margin-left: 4px; }
th.asc .sort-icon { opacity: 1; transform: rotate(180deg); }
th.desc .sort-icon { opacity: 1; transform: rotate(0deg); }
```

```javascript
let sortDir = [true, true, true, true, true, true, true, true];
function sortTable(colIndex, type) {
    // Ordina per colonna con direzione toggle
    // type: 'string' o 'date'
}
```

Headers ora hanno `onclick="sortTable(n, 'string')"` e `class="sortable"`.

### 13. Modal Conferma con Priorita (2026-03-26 - Sessione 2)
Le azioni ora usano un modal personalizzato invece di `confirm()`:
```html
<div id="modal-conferma" class="modal">
    <!-- Icon + Titolo -->
    <!-- Messaggio -->
    <!-- Dropdown Priorita: Alta, Media, Bassa -->
    <!-- Bottoni: Annulla, Conferma -->
</div>
```

Variabili globali per gestire l'azione pendente:
- `pendingAction` / `pendingActionOut`
- `confermaAzione()` / `confermaAzioneOut()`

Funzioni aggiornate:
- `azioneRapida()` - mostra modal invece di confirm()
- `eseguiAzioneDetail()` - mostra modal dopo chiusura dettaglio
- `confermaAzione()` - esegue azione con priorita selezionata
- `aggiornaRiga()` - accetta parametro priority opzionale

### 14. Layout PDF Preview migliorato (2026-03-26 - Sessione 2)
In pratiche-in.html, il modal dettaglio ora mostra:
- Header con titolo + bottoni (Apri PDF, Scarica)
- Area preview con placeholder documentale
- ID documento, formato, numero pagine
- Bottone "Visualizza Documento"
- Iframe nascosto per visualizzazione (future integration)

```javascript
function apriModuloPDF() {
    // Mostra iframe per PDF viewer
    // Integrazione Salesforce futura
}

function scaricaModuloPDF() {
    // Download del documento
}
```

### 15. Badge Priorita nella tabella
Aggiunto supporto per badge priorita visivi:
```css
.prio-badge { padding: 3px 8px; border-radius: 3px; font-size: 11px; font-weight: bold; }
.prio-alta { background: #fdf3f4; color: #dc3545; border-color: #f5c6cb; }
.prio-media { background: #fffdf5; color: #e67e22; border-color: #ffeeba; }
.prio-bassa { background: #f4f9f5; color: #155724; border-color: #c3e6cb; }
```

Quando un'azione viene confermata, la cella priorita viene aggiornata con il badge corrispondente.

### 16. Date dinamiche nella tabella (2026-03-26 - Sessione 3)
Le date di scadenza sono ora calcolate dinamicamente dalla data odierna:
```javascript
function updateScadenze() {
    const scadCells = document.querySelectorAll('[id^="td-scad-"]');
    const scadenze = ['26/03/2026', '02/04/2026', ...];
    scadCells.forEach((cell, i) => {
        if (scadenze[i]) {
            cell.textContent = scadenze[i];
            const d = new Date(scadenze[i].split('/').reverse().join('-'));
            const diff = Math.ceil((d - oggi) / (1000 * 60 * 60 * 24));
            if (diff <= 0) cell.classList.add('date-urgent');
        }
    });
}
```

Le date sono hardcoded nel data ma visualizzate con calcolo dinamico della vicinanza alla scadenza.

### 17. Pattern azioni come tdtin.html (2026-03-26 - Sessione 3)
Le azioni funzionano come in tdtin.html/tdtout.html:
- Ogni riga ha `id="row-X"` per identificazione univoca
- La cella stato ha `id="td-status-X"`
- La cella azioni ha `id="td-actions-X"`
- Il bottone azione rapida chiama `apriDettaglio(rowId, ...)` che apre il modal
- Il modal ha un'area azione con bottone "Conferma" che chiama `setInCoda(rowId, msg)`
- `setInCoda` aggiorna lo stato a "In Coda" e rimuove il bottone azione (resta solo l'occhio)

```javascript
function setInCoda(rowId, customMessage) {
    const tdStatus = document.getElementById('td-status-' + rowId);
    const tdActions = document.getElementById('td-actions-' + rowId);
    
    if(tdStatus) {
        tdStatus.innerHTML = '<span class="status-badge status-in-coda">In Coda</span>';
    }
    
    if(tdActions) {
        tdActions.innerHTML = `
            <div class="action-group">
                <button class="btn-icon" onclick="apriDettaglio('${rowId}', ...)"><span class="material-icons">visibility</span></button>
            </div>
        `;
    }
    
    showToast(customMessage || 'Pratica inviata in coda.', 'check_circle');
}
```

### 18. Icone solo pallini (2026-03-26 - Sessione 3)
Priorita in tutte le tabelle usa solo il pallino (cerchio):
- `<span class="material-icons">circle</span>` con colori `prio-red`, `prio-yellow`, `prio-gray`

### 19. Footer con data dinamica (2026-03-26 - Sessione 3)
```javascript
const oggi = new Date();
document.getElementById('footer-date').textContent = 
    'Ultimo aggiornamento: ' + gg + '/' + mm + '/' + yyyy + ' ore ' + hh + ':' + min;
```
