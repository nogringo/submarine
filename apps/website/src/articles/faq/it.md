---
description: Risposte alle domande frequenti su Submarine, il gestore di password senza account. Chiave persa, server fuori uso, uso offline, cassaforte condivisa e costi.
---

# Domande e risposte

## E se perdo la chiave della mia cassaforte?

Nessuno può recuperarla, nemmeno noi: non c'è un account né un link di reimpostazione. Se Submarine è ancora aperto su uno dei tuoi dispositivi, copia la chiave dalle impostazioni della cassaforte e conservala in un posto sicuro. Altrimenti, la cassaforte non potrà più essere aperta.

## E se un server chiude?

Ogni cassaforte è copiata su più relay, e ciascuno dei tuoi dispositivi ne conserva una copia. Se un relay si ferma, gli altri hanno ancora la tua cassaforte. Puoi aggiungere o rimuovere relay nelle impostazioni della cassaforte, alla voce Sincronizzazione.

## Chi gestisce i server?

I relay Nostr sono gestiti da operatori indipendenti, per tutte le app che usano Nostr, non solo per Submarine. Vedono solo dati cifrati. Puoi anche gestire un tuo relay e aggiungerlo alla tua cassaforte.

## Submarine funziona offline?

Sì. Ogni modifica viene salvata prima sul tuo dispositivo e sincronizzata appena torni online. Submarine mostra quante modifiche sono ancora in attesa di essere inviate.

## Posso usarlo su più dispositivi?

Sì: su Android, Windows, macOS e Linux, e sul web per ogni altro dispositivo. Apri la tua cassaforte su ciascuno di essi con la stessa chiave. [Scarica Submarine](/it/download).

## Posso condividere una cassaforte?

Sì. Dai la chiave della cassaforte alla persona con cui la condividi: chi ce l'ha può aprire e modificare la cassaforte. Una chiave data non si può riprendere, quindi tieni le password condivise in una cassaforte tutta loro, separata da quelle personali.

## E se modifico lo stesso elemento su due dispositivi contemporaneamente?

Entrambe le modifiche vengono conservate. Submarine non sovrascrive mai in silenzio l'una con l'altra.

## Submarine è gratuito?

Sì. Non c'è niente da pagare, nessuna versione premium e nessuna pubblicità. Submarine è open source, con licenza MIT.

## In cosa è diverso dagli altri gestori di password?

Con la maggior parte dei gestori di password, la tua cassaforte si trova sui server dell'azienda che li produce, dietro un account. Submarine non ha un account né un server proprio: la tua cassaforte è copiata su server aperti che scegli tu, e solo la tua chiave la apre. Il rovescio della medaglia è che nessuno può recuperare una chiave persa. Submarine è anche più giovane, e non è ancora stato sottoposto ad audit.

## Posso importare le mie password?

Sì, da Bitwarden, e dalla maggior parte degli altri gestori di password passando da Bitwarden. [Importa da Bitwarden](/it/import-bitwarden). Puoi esportare le tue casseforti in qualsiasi momento, in un formato che altri gestori di password possono importare.

## Submarine è sicuro?

La tua cassaforte è cifrata sui tuoi dispositivi, e i server vedono solo dati cifrati. Tuttavia, nessuna società indipendente ha ancora verificato Submarine. [Come Submarine protegge le tue password](/it/security).

## Cos'è Nostr?

Un protocollo aperto per scambiare dati tramite relay: server che chiunque può gestire. Submarine lo usa per sincronizzare la tua cassaforte senza un'azienda di mezzo. Per usare Submarine non devi conoscere Nostr né avere un account Nostr.

## Come segnalo un problema?

[Segnalalo su GitHub](https://github.com/nogringo/submarine/issues), o [contattaci su Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).
