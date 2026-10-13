---
description: Sposta le tue password da Bitwarden a Submarine in pochi minuti, con i campi personalizzati e i codici a due fattori, e riportale fuori quando vuoi.
---

# Importa le tue password da Bitwarden

Submarine legge il file di esportazione di Bitwarden, quindi spostare le tue password richiede pochi minuti. Nel tuo account Bitwarden non cambia nulla: l'importazione copia soltanto i tuoi elementi.

## 1. Esporta la tua cassaforte da Bitwarden

1. Nella cassaforte web di Bitwarden, apri Strumenti, poi Esporta cassaforte. Le app di Bitwarden hanno lo stesso comando nelle impostazioni o nei menu.
2. Scegli il formato .json. Puoi anche scegliere il formato .json cifrato, protetto da una password a tua scelta: Submarine apre anche quello.
3. Conferma con la tua password principale di Bitwarden e salva il file.

Un'esportazione cifrata limitata al tuo account Bitwarden non funziona: solo Bitwarden può aprirla. Scegli invece il tipo protetto da password.

## 2. Importa il file in Submarine

1. Apri Submarine, e crea o apri la cassaforte in cui devono finire le tue password.
2. Vai in **Impostazioni**, poi **Importa ed esporta**, e premi **Importa** accanto a **Importa da Bitwarden**.
3. Scegli il file. Se è protetto da una password, inserisci quella password.
4. Controlla quanti elementi sono stati trovati, scegli la cassaforte se ne hai più di una, e premi **Importa**.

I tuoi elementi vengono cifrati sul tuo dispositivo, poi sincronizzati con gli altri tuoi dispositivi come qualsiasi altra modifica.

## 3. Elimina il file di esportazione

Un'esportazione .json senza password non è cifrata: chiunque la ottenga può leggere tutte le tue password. Eliminala una volta terminata l'importazione, e svuota il cestino del computer. Non inviarla per email.

## Cosa viene importato

- Login, carte, note sicure, identità, chiavi SSH e gli altri tipi di elemento di Bitwarden, con i loro campi personalizzati e i loro codici di autenticazione a due fattori.
- Login, carte e note sicure si possono modificare in Submarine. Gli altri tipi vengono conservati e mostrati, ma non si possono ancora modificare.
- Le passkey vengono conservate e mostrate, ma Submarine non può ancora usarle per accedere.
- Le cartelle non vengono importate: Submarine separa invece gli elementi per cassaforte.
- I file allegati non fanno parte dell'esportazione di Bitwarden, quindi restano in Bitwarden.

## Se arrivi da un altro gestore di password

Submarine legge solo il formato di Bitwarden. Bitwarden invece importa dalla maggior parte dei gestori di password, come 1Password, LastPass, KeePass o il tuo browser. Con un account Bitwarden gratuito, importa prima lì le tue password, poi segui i passaggi qui sopra.

## Lasciare Submarine

Submarine esporta nello stesso formato. In **Impostazioni**, poi **Importa ed esporta**, **Esporta una cassaforte** salva un file di Bitwarden, protetto da password o non cifrato, che Bitwarden e altri gestori di password possono importare. Il cestino resta escluso.

Nuovo su Submarine? [Scaricalo](/it/download), o leggi [come protegge le tue password](/it/security).
