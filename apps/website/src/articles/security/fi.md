---
description: Näin Submarine suojaa salasanasi. Ne salataan laitteillasi, säilytetään avoimilla palvelimilla, jotka näkevät vain salattua tietoa, ja avataan vain sinun avaimellasi.
---

# Näin Submarine suojaa salasanasi

Submarine salaa holvisi laitteillasi, ennen kuin mitään lähtee niiltä. Holvia säilyttävät palvelimet näkevät aina vain salattua tietoa, eikä välissä ole Submarine-tiliä tai Submarinen palvelinta. Tällä sivulla kerrotaan, mitä suojataan, miten, ja mitä ei ole vielä tehty.

## Holvin avain

Jokaisella holvilla on oma avaimensa, joka luodaan laitteellasi, kun luot holvin. Avaimen haltija voi avata holvin, eikä kukaan muu voi: eivät palvelimet eivätkä me.

- Submarine näyttää avaimen, kun luot holvin. Säilytä se turvallisessa paikassa, esimerkiksi paperilla tai salasanojen hallintaohjelmassa, jota jo käytät.
- Voit myös säilyttää sen salattuna valitsemallasi salasanalla. Silloin tarvitset holvin avaamiseen sekä salatun avaimen että sen salasanan.
- Kukaan ei voi palauttaa kadonnutta avainta. Tiliä tai palautuslinkkiä ei ole, joten pidä tallessa kopio avaimesta tai salatusta avaimesta ja sen salasanasta.

## Laitteillasi

- Holvisi salataan jokaisella laitteella kyseisen laitteen avaimella.
- Lukitussalasanasi suojaa tätä avainta. Submarine muuntaa sen avaimeksi Argon2id:llä, menetelmällä, joka on suunniteltu tekemään salasanojen arvaamisesta hidasta ja kallista. Unohdettua lukitussalasanaakaan ei voi palauttaa: silloin avaat holvisi uudelleen niiden avaimilla.
- Sormenjälki, kasvot tai näytön lukitus voi avata Submarinen lukituksen lukitussalasanan sijaan.
- Submarine lukitsee itsensä valitsemasi viiveen jälkeen, joka voi olla mitä tahansa heti tapahtuvasta muutamaan tuntiin, ja tyhjentää holvisi muistista lukittuessaan.
- Kopioidut salasanat tyhjennetään leikepöydältä valitsemasi viiveen jälkeen.
- Androidilla Submarinesta otetut kuvakaappaukset ja näyttötallenteet on estetty, ellet salli niitä.

## Palvelimilla

Holvisi sijaitsevat Nostr-releillä eli avoimilla palvelimilla, joita ylläpitävät riippumattomat tahot ja joita kuka tahansa voi käyttää tai ylläpitää. Jokainen holvi kopioidaan useille releille, joten se säilyy, vaikka yksi niistä lakkaisi toimimasta, ja sinä valitset, mitkä releet sitä säilyttävät, myös omasi.

Jokainen tekemäsi muutos salataan laitteellasi ja lähetetään releille sinetöidyssä kirjekuoressa. Rele näkee:

- salattua tietoa, jota se ei voi lukea,
- holvin julkisen avaimen, josta se tietää, mitkä kirjekuoret kuuluvat yhteen, mutta ei sitä, mitä ne sisältävät,
- satunnaisen päivämäärän muutosta edeltäneiden kahden päivän ajalta muutoksen todellisen ajankohdan sijaan,
- IP-osoitteesi, kuten mikä tahansa verkkosivusto, jolla vierailet.

Rele ei myöskään voi muuttaa salasanojasi. Jokainen muutos allekirjoitetaan holvin avaimella, ja Submarine ohittaa kaiken, mitä holvi ei ole allekirjoittanut.

## Ei tiliä, ei seurantaa

- Submarine-tiliä ei ole, eikä mikään Submarinen palvelin säilytä tietojasi.
- Submarinessa ei ole analytiikkaa, kaatumisraportointia eikä mainoksia.
- Koodi on avointa lähdekoodia MIT-lisenssillä, joten kuka tahansa voi tarkistaa, mitä Submarine tekee. [Katso lähdekoodi](https://github.com/nogringo/submarine).

## Vielä tekemättä

Mikään riippumaton taho ei ole vielä auditoinut Submarinen tietoturvaa. Siihen asti säilytä tärkeimmät salasanasi, kuten sähköpostisi ja pankkisi, salasanojen hallintaohjelmassa, jolla on pidempi näyttö takanaan, ja aloita muista.

Jos löydät tietoturvaongelman, [ilmoita siitä](https://github.com/nogringo/submarine/issues) tai [ota meihin yhteyttä Nostrissa](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).

## Tekniset tiedot

Koko formaatti on kuvattu [Nostr Passwords -protokollassa](https://openspecs.uid.ovh/spec/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te/nostr-passwords).

- Holvi on Nostr-avainpari. Sen avain esitetään `nsec`-muodossa, ja sen salattu muoto on NIP-49:n mukainen `ncryptsec` (scrypt, sitten XChaCha20-Poly1305).
- Jokainen muutos on kohteen uusi versio: holvin allekirjoittama tapahtuma, joka on salattu holville NIP-44:llä (ChaCha20 ja HMAC-SHA256, täytteellä, joka kätkee tarkan pituuden) ja pakattu NIP-59:n gift wrap -kääreeseen, jonka allekirjoittaa kertakäyttöinen avain ja jonka päiväys on satunnainen kahden edellisen päivän ajalta.
- Kohteet ovat Bitwardenin kohteita, minkä vuoksi Submarine tuo ja vie Bitwardenin muotoa.
- Laitteella holvien avaimet salataan laiteavaimella AES-256-CBC:tä ja HMAC-SHA256:ta käyttäen. Laiteavainta suojaa lukitussalasana Argon2id:n avulla, tai se säilytetään järjestelmän suojatussa tallennustilassa. Holvien paikallinen kopio salataan AES-256-GCM:llä.
- Jos käytät Nostria, allekirjoittaja voi säilyttää holvin avaimen niin, ettei se koskaan päädy Submarineen: etäallekirjoittaja (NIP-46), allekirjoitussovellus, kuten Amber (NIP-55), tai selainlaajennus (NIP-07).
