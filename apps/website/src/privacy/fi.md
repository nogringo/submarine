# Submarinen selainlaajennuksen tietosuojakäytäntö

Päivitetty viimeksi 12. lokakuuta 2026.

Submarine on salasanojen hallintaohjelma. Sen selainlaajennus näyttää holviesi salasanat, kortit ja muistiinpanot, antaa sinun luoda ja muokata niitä, kopioi ne puolestasi ja täyttää kirjautumistietosi verkkosivustoille. Tämä käytäntö kertoo, mitä laajennus tekee tiedoillasi. Lyhyesti: Submarinella ei ole palvelinta, eikä laajennus lähetä mitään sen kehittäjille.

## Mitä selaimeesi jää

- Jokaisen avaamasi holvin avain sekä nimi ja väri, jotka annat sille. Ne on salattu tämän selaimen avaimella, jota suojaa lukitussalasanasi, kun olet asettanut sellaisen.
- Kopio holviesi sisällöstä, jotta ne aukeavat odottamatta verkkoa. Sekin on salattu.
- Asetuksesi: lukitusviive, leikepöydän tyhjennysviive ja salasanageneraattorin valinnat.
- Lomake, jonka jätät tallentamatta, jotta se näkyy taas, kun avaat laajennuksen uudelleen. Se pysyy selaimen muistissa eikä koskaan levyllä, ja se katoaa, kun tallennat tai hylkäät sen, lukitset laajennuksen tai suljet selaimen.

Kun poistat holvin laajennuksesta, sen avain ja kopio poistetaan selaimestasi. Kun poistat laajennuksen, kaikki sen tallentama poistetaan.

## Mitä selaimestasi lähtee

Holvisi sijaitsevat Nostr-releillä eli palvelimilla, joita ylläpitävät riippumattomat tahot ja jotka tallentavat tietoa kenelle tahansa. Kohteesi salataan laitteillasi ennen kuin ne päätyvät releelle, joten releillä on vain tietoa, jota ne eivät voi lukea.

Ladatakseen holvisi laajennus muodostaa yhteyden niiden releisiin: kunkin holvin luettelemiin releisiin tai muuten Submarinen [oletusreleisiin](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) sekä kolmeen hakemistoreleeseen, joille holvin releluettelo julkaistaan. Jokainen rele näkee IP-osoitteesi, kuten mikä tahansa vierailemasi verkkosivusto, sekä jokaisen avaamasi holvin julkisen avaimen, jolla laajennus kirjautuu sisään ja pyytää kyseisen holvin tietoja.

Kun luot, muokkaat, lisäät suosikkeihin, siirrät roskakoriin tai palautat kohteen, laajennus salaa sen uuden version laitteellasi ja lähettää sen holvin releille. Kun poistat kohteen pysyvästi, laajennus pyytää näitä releitä poistamaan sen jokaisen version. Muutos, jota mikään rele ei ole vielä hyväksynyt, odottaa selaimesi salatussa kopiossa ja lähetetään uudelleen, kun seuraavan kerran avaat laajennuksen tai painat sen synkronointipainiketta.

Salasanageneraattori toimii selaimessasi: sen luoma tieto lähtee selaimesta vain tallentamasi kohteen sisällä.

Kun pyydät laajennusta täyttämään kirjautumistiedon sen ikkunasta tai pikanäppäimellä, laajennus kirjoittaa käyttäjätunnuksen ja salasanan nykyisen sivun kirjautumislomakkeeseen, mutta vain jos sivun osoite vastaa kirjautumistietoa. Verkkosivusto saa ne, kun kirjaudut sisään, aivan kuin kirjoittaisit ne itse.

## Mitä laajennus ei tee

- Sillä ei ole tiliä eikä omaa palvelinta: sen kehittäjät eivät saa siltä mitään tietoja.
- Siinä ei ole analytiikkaa, seurantaa eikä mainoksia.
- Se ei lue mitään vierailemiltasi sivuilta, paitsi nykyisen sivun kenttiä, kun pyydät sitä täyttämään kirjautumistiedon, jotta se löytää käyttäjätunnuksen ja salasanan paikat. Kun avaat sen, se lukee nykyisen välilehden osoitteen näyttääkseen ensin kyseisen sivuston kirjautumistiedot. Kumpikaan ei lähde selaimestasi.
- Se kirjoittaa leikepöydälle vain sen, minkä kopioit, sekä täyttämänsä kirjautumistiedon todennuskoodin, ja tyhjentää leikepöydän asetuksissa valitun viiveen jälkeen. Se ei koskaan lue leikepöytää.

## Käyttöoikeudet

- Tallennustila: säilyttää holvisi ja asetuksesi selaimessasi, kuten yllä kuvattiin.
- Leikepöydälle kirjoittaminen: kopioi salasanan, koodin tai minkä tahansa muun kentän, kun pyydät.
- Hälytykset: lukitsee holvit, kun lukitusviive on kulunut.
- Aktiivinen välilehti: antaa laajennukselle pääsyn siihen välilehteen, jonka päällä avaat laajennuksen tai käytät sen pikanäppäintä, ja vain siihen: sen osoitteeseen, jotta kyseisen sivuston kirjautumistiedot näytetään ensin, ja sen sivuun, jotta kirjautumistieto voidaan täyttää, kun pyydät.
- Komentosarjat: täyttää kirjautumistiedon kyseisen välilehden sivulle, kun pyydät.
- Taustadokumentit, vain Chromessa: kopioi täytetyn kirjautumistiedon todennuskoodin ja tyhjentää leikepöydän sen viiveen jälkeen, vaikka laajennuksen ikkuna olisi suljettu.

## Muutokset ja yhteydenotot

Tämä käytäntö muuttuu laajennuksen mukana. Sen historia on tämän tiedoston historia [Submarinen repositoriossa](https://github.com/nogringo/submarine). Jos sinulla on kysyttävää, tee [ilmoitus](https://github.com/nogringo/submarine/issues).
