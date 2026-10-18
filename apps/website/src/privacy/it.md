# Informativa sulla privacy dell'estensione del browser di Submarine

Ultimo aggiornamento: 18 ottobre 2026.

Submarine è un gestore di password. La sua estensione del browser mostra le password, le carte e le note delle tue casseforti, ti permette di crearle e modificarle, le copia per te, compila i tuoi login nei siti web e mostra le email inviate agli indirizzi email che dai ai tuoi login. Questa informativa spiega cosa fa l'estensione con i tuoi dati. In breve: non esiste un server di Submarine, e l'estensione non invia nulla ai suoi sviluppatori.

## Cosa resta nel tuo browser

- La chiave di ogni cassaforte che crei o apri, con il nome e il colore che le dai. Sono cifrati con una chiave di questo browser, a sua volta protetta dalla tua password di sblocco, se ne imposti una.
- Una copia del contenuto delle tue casseforti, così si aprono senza aspettare la rete. Anche questa è cifrata.
- I messaggi di un indirizzo email, così come sono arrivati: cifrati per la chiave di quell'indirizzo. L'estensione li decifra ogni volta che li mostra, e non li conserva mai decifrati.
- Le tue impostazioni: il tempo prima del blocco, il tempo prima di svuotare gli appunti, le opzioni del generatore di password, e il ponte email, i relay e i server assegnati ai nuovi indirizzi email.
- Un modulo che lasci senza salvarlo, così ricompare quando riapri l'estensione. Resta nella memoria del browser, mai sul disco, e sparisce non appena lo salvi, lo scarti, blocchi l'estensione o chiudi il browser.

Rimuovere una cassaforte dall'estensione cancella la sua chiave e la sua copia dal tuo browser. Disinstallare l'estensione cancella tutto ciò che aveva salvato.

## Cosa esce dal tuo browser

Le tue casseforti si trovano sui relay Nostr: server gestiti da operatori indipendenti, che conservano dati per chiunque. I tuoi elementi vengono cifrati sui tuoi dispositivi prima di raggiungere un relay, quindi i relay conservano solo dati che non possono leggere.

Per scaricare le tue casseforti, l'estensione si collega ai loro relay: quelli indicati da ciascuna cassaforte, oppure, in mancanza, i [relay predefiniti](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) di Submarine, più tre relay di directory dove viene pubblicato l'elenco dei relay di ogni cassaforte. Ogni relay vede il tuo indirizzo IP, come qualsiasi sito web che visiti, e la chiave pubblica di ogni cassaforte che apri, con cui l'estensione si identifica e chiede i dati di quella cassaforte.

Quando crei, modifichi, aggiungi ai preferiti, sposti nel cestino o ripristini un elemento, l'estensione cifra la sua nuova versione sul tuo dispositivo e la invia ai relay della sua cassaforte. Quando elimini definitivamente un elemento, chiede a quei relay di eliminare ciascuna delle sue versioni. Una modifica che nessun relay ha ancora accettato resta in attesa nella copia cifrata nel tuo browser, e viene inviata di nuovo la prossima volta che apri l'estensione o premi il suo pulsante di sincronizzazione.

Il generatore di password funziona nel tuo browser: ciò che genera ne esce solo all'interno di un elemento che salvi.

Quando importi un'esportazione di Bitwarden, l'estensione legge nel tuo browser il file che scegli, poi salva i suoi elementi nella cassaforte che indichi, come elementi creati da te. Quando esporti una cassaforte, salva il file sul tuo computer, cifrato con la password che scegli, oppure non cifrato se disattivi questa opzione. Il file non va da nessun'altra parte.

Quando le chiedi di compilare un login, dalla sua finestra o con la sua scorciatoia da tastiera, l'estensione scrive il nome utente e la password nel modulo di accesso della pagina corrente, e solo se l'indirizzo della pagina corrisponde al login. Il sito web li riceve quando accedi, come quando li digiti tu.

## Indirizzi email

Puoi dare a un login un indirizzo email proprio, come `npub1...@uid.ovh`, dal menu che aggiunge un campo. L'estensione crea una nuova chiave per ogni indirizzo, senza legami con le tue casseforti, e la conserva in un campo nascosto del login, cifrata insieme al resto dell'elemento. Il dominio è quello di un ponte email, `uid.ovh` a meno che tu non ne scelga un altro nelle impostazioni: un server gestito da un operatore indipendente, che riceve le email inviate all'indirizzo, come qualsiasi server di posta, le cifra per la chiave dell'indirizzo e le trasmette ai relay dell'indirizzo. L'estensione non invia mai email e non si collega mai al ponte.

Quando salvi un login con un nuovo indirizzo email, l'estensione pubblica tre elenchi pubblici firmati con la chiave dell'indirizzo, così il ponte sa dove consegnare: l'elenco dei relay dell'indirizzo, inviato a quei relay e ai tre relay di directory; quello dei relay su cui arrivano le sue email; e quello dei server che ricevono le email troppo grandi per un relay. Questi elenchi indicano la chiave dell'indirizzo e i suoi relay e server, mai le tue casseforti. Salvo modifiche, sono i [relay e server email predefiniti](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) di Submarine; puoi cambiare nelle impostazioni quelli assegnati ai nuovi indirizzi.

Mentre è visualizzato un login con un indirizzo email, l'estensione si collega ai relay di quell'indirizzo, trovati sui relay di directory, vi si identifica con la chiave dell'indirizzo, scarica i suoi ultimi messaggi e riceve quelli nuovi finché non chiudi il login. Ogni relay vede il tuo indirizzo IP e la chiave pubblica dell'indirizzo. L'estensione riceve anche i messaggi privati (NIP-17) inviati a quella chiave. Un'email troppo grande per un relay viene scaricata, cifrata, quando la apri, da uno dei server dell'indirizzo o del ponte, oppure, in mancanza, dai server predefiniti di Submarine; quel server vede il tuo indirizzo IP.

Quando salvi un'email, l'estensione scrive l'intero messaggio, allegati compresi, in un file sul tuo computer. Quando elimini un messaggio, chiede ai relay dell'indirizzo di eliminarlo. Eliminare definitivamente un login non elimina i suoi messaggi dai relay. Un link in un messaggio si apre in una nuova scheda solo dopo che l'hai confermato, una volta che l'estensione ti ha mostrato dove porta.

## Cosa non fa l'estensione

- Non ha un account né un server proprio: i suoi sviluppatori non ricevono alcun dato da essa.
- Non invia mai email e non mostra mai le immagini né gli altri contenuti che un'email caricherebbe dal web: mostra le email come semplice testo.
- Non ha statistiche di utilizzo, né tracciamento, né pubblicità.
- Non legge nulla delle pagine che visiti, tranne i campi della pagina corrente quando le chiedi di compilare un login, per trovare dove vanno il nome utente e la password. Quando la apri, legge l'indirizzo della scheda corrente per mostrare per primi i login di quel sito. Nessuno dei due esce dal tuo browser.
- Scrive negli appunti solo ciò che copi e il codice di verifica di un login che compila, poi svuota gli appunti dopo il tempo scelto nelle impostazioni. Non legge mai gli appunti.

## Autorizzazioni

- Archiviazione: conserva le tue casseforti e le tue impostazioni nel browser, come descritto sopra.
- Scrittura negli appunti: copia una password, un codice o qualsiasi altro campo quando lo chiedi.
- Allarmi: blocca le casseforti una volta trascorso il tempo prima del blocco.
- Scheda attiva: dà all'estensione la scheda su cui la apri o su cui usi la sua scorciatoia, e solo quella: il suo indirizzo, per mostrare per primi i login di quel sito, e la sua pagina, per compilare un login quando lo chiedi.
- Script: compila un login nella pagina di quella scheda quando lo chiedi.
- Documenti fuori schermo, solo in Chrome: copia il codice di verifica di un login compilato e svuota gli appunti una volta trascorso il tempo previsto, anche con la finestra dell'estensione chiusa.

## Modifiche e contatti

Questa informativa cambia insieme all'estensione. La sua cronologia è quella di questo file nel [repository di Submarine](https://github.com/nogringo/submarine). Per qualsiasi domanda, apri una [segnalazione](https://github.com/nogringo/submarine/issues).
