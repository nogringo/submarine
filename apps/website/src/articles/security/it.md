---
description: "Come Submarine protegge le tue password: cifrate sui tuoi dispositivi, conservate su server aperti che vedono solo dati cifrati, aperte da una chiave che hai solo tu."
---

# Come Submarine protegge le tue password

Submarine cifra la tua cassaforte sui tuoi dispositivi, prima che qualsiasi dato ne esca. I server che la conservano vedono sempre e solo dati cifrati, e non c'è nessun account Submarine né alcun server di Submarine di mezzo. Questa pagina spiega cosa è protetto, come, e cosa manca ancora.

## La chiave della cassaforte

Ogni cassaforte ha la propria chiave, creata sul tuo dispositivo quando crei la cassaforte. Chi ha questa chiave può aprire la cassaforte, e nessun altro può farlo: né i server, né noi.

- Submarine ti mostra la chiave quando crei la cassaforte. Conservala in un posto sicuro, per esempio su carta o in un gestore di password che usi già.
- Puoi anche conservarla cifrata con una password a tua scelta. Per aprire la cassaforte ti servono allora sia la chiave cifrata sia la sua password.
- Nessuno può recuperare una chiave persa. Non c'è un account né un link di reimpostazione, quindi conserva una copia della chiave, oppure della chiave cifrata e della sua password.

## Sui tuoi dispositivi

- Le tue casseforti sono cifrate su ogni dispositivo, con una chiave di quel dispositivo.
- La tua password di sblocco protegge quella chiave. Submarine la trasforma in una chiave con Argon2id, un metodo pensato per rendere lento e costoso indovinare le password. Anche una password di sblocco dimenticata non può essere recuperata: in quel caso riapri le tue casseforti con le loro chiavi.
- L'impronta, il volto o il blocco schermo possono sbloccare Submarine al posto della password di sblocco.
- Submarine si blocca da solo dopo un tempo che scegli tu, da subito a qualche ora, e quando si blocca cancella le tue casseforti dalla memoria.
- Le password copiate vengono cancellate dagli appunti dopo un tempo che scegli tu.
- Su Android, screenshot e registrazioni dello schermo di Submarine sono bloccati, a meno che tu non li consenta.

## Sui server

Le tue casseforti si trovano sui relay Nostr: server aperti gestiti da operatori indipendenti, che chiunque può usare o gestire. Ogni cassaforte è copiata su più relay, così sopravvive se uno di essi si ferma, e sei tu a scegliere quali relay la conservano, compresi i tuoi.

Ogni modifica che fai viene cifrata sul tuo dispositivo e inviata ai relay in una busta sigillata. Un relay vede:

- dati cifrati che non può leggere,
- la chiave pubblica della cassaforte, che gli dice quali buste vanno insieme, ma non cosa contengono,
- una data scelta a caso nei due giorni precedenti la modifica, invece dell'ora della modifica,
- il tuo indirizzo IP, come qualsiasi sito web che visiti.

Un relay non può nemmeno modificare le tue password. Ogni modifica è firmata con la chiave della cassaforte, e Submarine ignora tutto ciò che la cassaforte non ha firmato.

## Nessun account, nessun tracciamento

- Non esiste un account Submarine, e nessun server di Submarine conserva i tuoi dati.
- Submarine non ha statistiche di utilizzo, né segnalazioni di arresti anomali, né pubblicità.
- Il codice è open source con licenza MIT, quindi chiunque può verificare cosa fa Submarine. [Vedi il codice sorgente](https://github.com/nogringo/submarine).

## Cosa manca ancora

Nessuna società indipendente ha ancora verificato la sicurezza di Submarine. Fino ad allora, tieni le tue password più importanti, come quelle dell'email e della banca, in un gestore di password con più anni di esperienza alle spalle, e inizia con le altre.

Se trovi un problema di sicurezza, [segnalalo](https://github.com/nogringo/submarine/issues) o [contattaci su Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).

## Dettagli tecnici

Il formato completo è descritto nel [protocollo Nostr Passwords](https://openspecs.uid.ovh/spec/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te/nostr-passwords).

- Una cassaforte è una coppia di chiavi Nostr. La sua chiave è mostrata come `nsec`, e la sua forma cifrata è un `ncryptsec` NIP-49 (scrypt, poi XChaCha20-Poly1305).
- Ogni modifica è una nuova versione dell'elemento: un evento firmato dalla cassaforte, cifrato per la cassaforte con NIP-44 (ChaCha20 e HMAC-SHA256, con un riempimento che nasconde la lunghezza esatta) e chiuso in un gift wrap NIP-59, firmato da una chiave usa e getta e datato a caso nei due giorni precedenti.
- Gli elementi sono elementi di Bitwarden, ed è per questo che Submarine importa ed esporta il formato di Bitwarden.
- Su un dispositivo, le chiavi delle casseforti sono cifrate con AES-256-CBC e HMAC-SHA256 tramite una chiave del dispositivo. Questa chiave è protetta dalla password di sblocco tramite Argon2id, oppure conservata nell'archivio sicuro del sistema. La copia locale delle casseforti è cifrata con AES-256-GCM.
- Se usi Nostr, un firmatario può custodire la chiave della cassaforte, così che non entri mai in Submarine: un firmatario remoto o bunker (NIP-46), un'app di firma come Amber (NIP-55) o un'estensione del browser (NIP-07).
