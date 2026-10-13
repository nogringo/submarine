---
description: Siirrä salasanasi Bitwardenista Submarineen muutamassa minuutissa lisäkenttineen ja kaksivaiheisen tunnistautumisen koodeineen, ja vie ne pois milloin haluat.
---

# Tuo salasanasi Bitwardenista

Submarine lukee Bitwardenin vientitiedoston, joten salasanojen siirtäminen vie vain muutaman minuutin. Bitwarden-tilisi ei muutu mitenkään: tuonti vain kopioi kohteesi.

## 1. Vie holvisi Bitwardenista

1. Avaa Bitwardenin verkkoholvissa Työkalut ja sitten Vie holvi. Bitwardenin sovelluksissa sama toiminto löytyy asetuksista tai valikoista.
2. Valitse .json-muoto. Voit myös valita salatun .json-muodon, jota suojaa valitsemasi salasana: Submarine avaa senkin.
3. Vahvista Bitwardenin pääsalasanallasi ja tallenna tiedosto.

Bitwarden-tiliisi rajattu salattu vientitiedosto ei toimi: vain Bitwarden voi avata sen. Valitse sen sijaan salasanasuojattu vienti.

## 2. Tuo tiedosto Submarineen

1. Avaa Submarine ja luo tai avaa holvi, johon salasanasi tuodaan.
2. Siirry kohtaan **Asetukset** ja sitten **Tuonti ja vienti**, ja paina kohdan **Tuo Bitwardenista** vieressä olevaa painiketta **Tuo**.
3. Valitse tiedosto. Jos se on salasanasuojattu, syötä sen salasana.
4. Tarkista, montako kohdetta löytyi, valitse holvi, jos sinulla on useita, ja paina **Tuo**.

Kohteesi salataan laitteellasi ja synkronoidaan sitten muille laitteillesi kuten mikä tahansa muu muutos.

## 3. Poista vientitiedosto

Ilman salasanaa tehty .json-vientitiedosto ei ole salattu: kuka tahansa, joka saa sen käsiinsä, voi lukea kaikki salasanasi. Poista se heti, kun tuonti on valmis, ja tyhjennä tietokoneesi roskakori. Älä lähetä sitä sähköpostitse.

## Mitä tuodaan

- Kirjautumistiedot, kortit, salatut muistiot, henkilöllisyydet, SSH-avaimet ja Bitwardenin muut kohdetyypit lisäkenttineen ja kaksivaiheisen tunnistautumisen koodeineen.
- Kirjautumistietoja, kortteja ja salattuja muistioita voi muokata Submarinessa. Muut tyypit säilytetään ja näytetään, mutta niitä ei voi vielä muokata.
- Pääsyavaimet säilytetään ja näytetään, mutta Submarine ei vielä osaa kirjautua niillä.
- Kansioita ei tuoda: Submarine pitää kohteet erillään holveittain.
- Liitetiedostot eivät sisälly Bitwardenin vientiin, joten ne jäävät Bitwardeniin.

## Toisesta salasanojen hallintaohjelmasta

Submarine lukee vain Bitwardenin muotoa. Bitwarden itse osaa tuoda tiedot useimmista salasanojen hallintaohjelmista, kuten 1Passwordista, LastPassista, KeePassista tai selaimestasi. Tuo salasanasi ensin ilmaiselle Bitwarden-tilille ja seuraa sitten yllä olevia ohjeita.

## Submarinesta lähteminen

Submarine vie tiedot samassa muodossa. Kohdassa **Asetukset** ja sitten **Tuonti ja vienti** toiminto **Vie holvi** tallentaa Bitwarden-tiedoston, salasanasuojattuna tai salaamattomana, jonka Bitwarden ja muut salasanojen hallintaohjelmat osaavat tuoda. Roskakoria ei viedä.

Etkö vielä käytä Submarinea? [Lataa se](/fi/download) tai lue, [miten se suojaa salasanasi](/fi/security).
