---
description: "Tieni una copia delle tue casseforti, e di quelle dei tuoi cari, su server che gestisci tu: un relay Nostr per le casseforti e un server di file per i loro allegati."
---

# Gestisci server per te e per i tuoi cari

Submarine non ha un server suo: per impostazione predefinita, le tue casseforti sono copiate su relay Nostr pubblici gestiti da operatori indipendenti. Puoi aggiungere server gestiti da te, o da qualcuno di cui ti fidi: una copia della tua cassaforte resta così presso persone che conosci.

## Per te e per i tuoi cari

Un solo server può conservare le casseforti di tutte le persone intorno a te: dai loro il suo indirizzo, e lo aggiungono alle loro casseforti come al passaggio 3.

- Se spegni il tuo server, non perdono nulla: le loro casseforti sono ancora sui loro altri relay e su ciascuno dei loro dispositivi.
- Il tuo server vede solo dati cifrati: non può né leggere le loro password né modificarle. Come qualsiasi relay, vede il loro indirizzo IP.
- Se anche un amico gestisce un server, aggiungete ciascuno quello dell'altro: così ognuno conserva una copia per l'altro.

## Cosa ti serve

- Una macchina raggiungibile da internet, come un server a noleggio o un computer a casa tua.
- Un nome di dominio che punti a essa, con HTTPS.
- Docker, per installare i due server qui sotto.

## 1. Installa un relay

Installa [nostr-relay](https://github.com/nogringo/nostr-relay) seguendo le sue istruzioni. A differenza della maggior parte dei relay, consegna i dati di una cassaforte solo a chi ne ha la chiave, e ti permette di eliminarli.

Mettigli davanti un proxy HTTPS che inoltri l'intestazione Host originale: al relay serve per verificare che Submarine abbia la chiave della cassaforte.

Il suo indirizzo inizia con `wss://`, per esempio `wss://relay.example.com`.

## 2. Installa un server di file

I file allegati ai tuoi elementi sono conservati su server di file, non sui relay. Per averne anche una copia, installa [blossom-server](https://github.com/hzrd149/blossom-server) seguendo le sue istruzioni.

Nel suo file di configurazione, aggiungi questa regola in cima alle regole sotto `storage`:

```yaml
- type: application/octet-stream
  expiration: 100 years
```

I file cifrati di Submarine vengono così conservati. Senza questa regola, la configurazione di esempio elimina ogni file che nessuno ha aperto da una settimana.

Il suo indirizzo inizia con `https://`, per esempio `https://blossom.example.com`.

## 3. Aggiungili alla tua cassaforte

1. Apri le impostazioni della cassaforte e, alla voce **Sincronizzazione**, apri **Relay**.
2. Premi **Aggiungi un relay**, inserisci l'indirizzo del tuo relay, attiva **Mantieni privato** e premi **Aggiungi**.
3. Premi **Salva**.
4. Di nuovo nelle impostazioni della cassaforte, apri **Server di file** e aggiungi il tuo server di file allo stesso modo con **Aggiungi un server**.

Ripeti per ciascuna delle tue casseforti. **Mantieni privato** cifra l'indirizzo nella cassaforte: altrimenti chiunque potrebbe vedere che questa cassaforte è conservata sul tuo server, e indovinare di chi è.

## Tieni qualche relay pubblico

Tieni qualche relay pubblico accanto al tuo: se il tuo server si ferma o perde i suoi dati, la tua cassaforte è ancora su di loro. Inoltre ciascuno dei tuoi dispositivi ne conserva una copia.
