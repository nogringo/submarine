---
description: "Pidä kopio holveistasi ja läheistesi holveista palvelimilla, joita ylläpidät: Nostr-rele holveille ja tiedostopalvelin niiden liitetiedostoille."
---

# Ylläpidä palvelimia itsellesi ja läheisillesi

Submarinella ei ole omaa palvelinta: oletuksena holvisi kopioidaan julkisille Nostr-releille, joita ylläpitävät riippumattomat tahot. Voit lisätä palvelimia, joita ylläpidät itse tai joita ylläpitää joku, johon luotat: silloin kopio holvistasi on tuttujen ihmisten luona.

## Sinulle ja läheisillesi

Yksi palvelin voi säilyttää koko lähipiirisi holvit: anna heille sen osoite, niin he lisäävät sen holveihinsa kuten vaiheessa 3.

- Jos lopetat palvelimesi, he eivät menetä mitään: heidän holvinsa ovat yhä heidän muilla releillään ja jokaisella heidän laitteellaan.
- Palvelimesi näkee vain salattua tietoa: se ei voi lukea eikä muuttaa heidän salasanojaan. Kuten mikä tahansa rele, se näkee heidän IP-osoitteensa.
- Jos ystävälläsikin on palvelin, lisätkää toistenne palvelimet: kumpikin säilyttää kopion toiselle.

## Mitä tarvitset

- Koneen, johon pääsee internetistä, esimerkiksi vuokratun palvelimen tai tietokoneen kotonasi.
- Verkkotunnuksen, joka osoittaa siihen, ja HTTPS-yhteyden.
- Dockerin, jolla asennat alla olevat kaksi palvelinta.

## 1. Asenna rele

Asenna [nostr-relay](https://github.com/nogringo/nostr-relay) sen ohjeiden mukaan. Toisin kuin useimmat releet, se antaa holvin tiedot vain sille, jolla on holvin avain, ja antaa sinun poistaa ne.

Laita sen eteen HTTPS-välityspalvelin, joka välittää alkuperäisen Host-otsakkeen: rele tarvitsee sitä tarkistaakseen, että Submarinella on holvin avain.

Sen osoite alkaa `wss://`, esimerkiksi `wss://relay.example.com`.

## 2. Asenna tiedostopalvelin

Kohteisiisi liitetyt tiedostot säilytetään tiedostopalvelimilla, ei releillä. Jos haluat niistäkin kopion, asenna [blossom-server](https://github.com/hzrd149/blossom-server) sen ohjeiden mukaan.

Lisää sen asetustiedostossa tämä sääntö `storage`-kohdan sääntöjen alkuun:

```yaml
- type: application/octet-stream
  expiration: 100 years
```

Submarinen salatut tiedostot säilyvät silloin. Ilman tätä sääntöä esimerkkiasetukset poistavat jokaisen tiedoston, jota kukaan ei ole avannut viikkoon.

Sen osoite alkaa `https://`, esimerkiksi `https://blossom.example.com`.

## 3. Lisää ne holviisi

1. Avaa holvin asetukset ja kohdassa **Synkronointi** avaa **Releet**.
2. Paina **Lisää rele**, kirjoita releesi osoite, ota **Pidä yksityisenä** käyttöön ja paina **Lisää**.
3. Paina **Tallenna**.
4. Palaa holvin asetuksiin, avaa **Tiedostopalvelimet** ja lisää tiedostopalvelimesi samalla tavalla painikkeella **Lisää palvelin**.

Tee sama jokaiselle holvillesi. **Pidä yksityisenä** salaa osoitteen holvin sisällä: muuten kuka tahansa näkisi, että tätä holvia säilytetään palvelimellasi, ja voisi arvata, kenen holvi se on.

## Pidä mukana muutama julkinen rele

Pidä oman releesi rinnalla muutama julkinen rele: jos palvelimesi lakkaa toimimasta tai menettää tietonsa, holvisi on yhä niillä. Lisäksi jokaisella laitteellasi on oma kopionsa.
