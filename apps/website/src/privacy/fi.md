# Submarinen selainlaajennuksen tietosuojakäytäntö

Päivitetty viimeksi 18. lokakuuta 2026.

Submarine on salasanojen hallintaohjelma. Sen selainlaajennus näyttää holviesi salasanat, kortit ja muistiinpanot, antaa sinun luoda ja muokata niitä, kopioi ne puolestasi, täyttää kirjautumistietosi verkkosivustoille ja näyttää sähköpostit, jotka on lähetetty kirjautumistiedoillesi antamiisi sähköpostiosoitteisiin. Tämä käytäntö kertoo, mitä laajennus tekee tiedoillasi. Lyhyesti: Submarinella ei ole palvelinta, eikä laajennus lähetä mitään sen kehittäjille.

## Mitä selaimeesi jää

- Jokaisen luomasi tai avaamasi holvin avain sekä nimi ja väri, jotka annat sille. Ne on salattu tämän selaimen avaimella, jota suojaa lukitussalasanasi, kun olet asettanut sellaisen.
- Kopio holviesi sisällöstä, jotta ne aukeavat odottamatta verkkoa. Sekin on salattu.
- Sähköpostiosoitteen viestit sellaisina kuin ne saapuivat: salattuina kyseisen osoitteen avaimelle. Laajennus purkaa niiden salauksen aina, kun se näyttää ne, eikä koskaan tallenna niitä salaamattomina.
- Asetuksesi: lukitusviive, leikepöydän tyhjennysviive, salasanageneraattorin valinnat sekä sähköpostisilta, releet ja palvelimet, jotka uudet sähköpostiosoitteet saavat.
- Lomake, jonka jätät tallentamatta, jotta se näkyy taas, kun avaat laajennuksen uudelleen. Se pysyy selaimen muistissa eikä koskaan levyllä, ja se katoaa, kun tallennat tai hylkäät sen, lukitset laajennuksen tai suljet selaimen.

Kun poistat holvin laajennuksesta, sen avain ja kopio poistetaan selaimestasi. Kun poistat laajennuksen, kaikki sen tallentama poistetaan.

## Mitä selaimestasi lähtee

Holvisi sijaitsevat Nostr-releillä eli palvelimilla, joita ylläpitävät riippumattomat tahot ja jotka tallentavat tietoa kenelle tahansa. Kohteesi salataan laitteillasi ennen kuin ne päätyvät releelle, joten releillä on vain tietoa, jota ne eivät voi lukea.

Ladatakseen holvisi laajennus muodostaa yhteyden niiden releisiin: kunkin holvin luettelemiin releisiin tai muuten Submarinen [oletusreleisiin](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) sekä kolmeen hakemistoreleeseen, joille holvin releluettelo julkaistaan. Jokainen rele näkee IP-osoitteesi, kuten mikä tahansa vierailemasi verkkosivusto, sekä jokaisen avaamasi holvin julkisen avaimen, jolla laajennus kirjautuu sisään ja pyytää kyseisen holvin tietoja.

Kun luot, muokkaat, lisäät suosikkeihin, siirrät roskakoriin tai palautat kohteen, laajennus salaa sen uuden version laitteellasi ja lähettää sen holvin releille. Kun poistat kohteen pysyvästi, laajennus pyytää näitä releitä poistamaan sen jokaisen version. Muutos, jota mikään rele ei ole vielä hyväksynyt, odottaa selaimesi salatussa kopiossa ja lähetetään uudelleen, kun seuraavan kerran avaat laajennuksen tai painat sen synkronointipainiketta.

Salasanageneraattori toimii selaimessasi: sen luoma tieto lähtee selaimesta vain tallentamasi kohteen sisällä.

Kun tuot Bitwardenin vientitiedoston, laajennus lukee valitsemasi tiedoston selaimessasi ja tallentaa sen kohteet haluamaasi holviin samalla tavalla kuin itse luomasi kohteet. Kun viet holvin, laajennus tallentaa tiedoston tietokoneellesi salattuna valitsemallasi salasanalla, tai salaamattomana, jos kytket salauksen pois päältä. Tiedosto ei mene minnekään muualle.

Kun pyydät laajennusta täyttämään kirjautumistiedon sen ikkunasta tai pikanäppäimellä, laajennus kirjoittaa käyttäjätunnuksen ja salasanan nykyisen sivun kirjautumislomakkeeseen, mutta vain jos sivun osoite vastaa kirjautumistietoa. Verkkosivusto saa ne, kun kirjaudut sisään, aivan kuin kirjoittaisit ne itse.

## Sähköpostiosoitteet

Kirjautumistiedolle voi antaa oman sähköpostiosoitteen, kuten `npub1...@uid.ovh`, Lisää kenttä -valikosta. Laajennus luo jokaiselle osoitteelle uuden avaimen, jolla ei ole yhteyttä holveihisi, ja säilyttää sen kirjautumistiedon piilotetussa kentässä salattuna kohteen muiden tietojen kanssa. Osoitteen verkkotunnus on sähköpostisillan verkkotunnus, `uid.ovh`, ellet valitse asetuksista toista siltaa. Silta on riippumattoman tahon ylläpitämä palvelin, joka vastaanottaa osoitteeseen lähetetyt sähköpostit kuten mikä tahansa sähköpostipalvelin, salaa ne osoitteen avaimelle ja välittää ne osoitteen releille. Laajennus ei koskaan lähetä sähköpostia eikä koskaan muodosta yhteyttä siltaan.

Kun tallennat kirjautumistiedon, jolla on uusi sähköpostiosoite, laajennus julkaisee kolme osoitteen avaimella allekirjoitettua julkista luetteloa, jotta silta tietää, minne sähköpostit toimitetaan: osoitteen releluettelon, joka lähetetään kyseisille releille ja kolmelle hakemistoreleelle; luettelon releistä, joille osoitteen sähköpostit saapuvat; sekä luettelon palvelimista, jotka vastaanottavat releelle liian suuret sähköpostit. Luetteloissa mainitaan osoitteen avain sekä sen releet ja palvelimet, ei koskaan holvejasi. Oletuksena ne ovat Submarinen [sähköpostin oletusreleet ja -palvelimet](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart); voit muuttaa asetuksissa niitä, jotka uudet osoitteet saavat.

Kun kirjautumistieto, jolla on sähköpostiosoite, on näkyvissä, laajennus muodostaa yhteyden osoitteen releisiin, jotka se löytää hakemistoreleiltä, kirjautuu niihin sisään osoitteen avaimella, lataa osoitteen viimeisimmät viestit ja vastaanottaa uudet, kunnes suljet kirjautumistiedon. Jokainen rele näkee IP-osoitteesi ja osoitteen julkisen avaimen. Laajennus vastaanottaa myös kyseiselle avaimelle lähetetyt yksityisviestit (NIP-17). Kun avaat sähköpostin, joka on liian suuri releelle, se ladataan salattuna jostakin osoitteen tai sillan palvelimelta tai muuten Submarinen oletuspalvelimilta; kyseinen palvelin näkee IP-osoitteesi.

Kun tallennat sähköpostin, laajennus kirjoittaa koko viestin liitteineen tiedostoon tietokoneellesi. Kun poistat viestin, laajennus pyytää osoitteen releitä poistamaan sen. Kirjautumistiedon poistaminen pysyvästi ei poista sen viestejä releiltä. Viestissä oleva linkki avautuu uuteen välilehteen vasta, kun laajennus on näyttänyt, minne se vie, ja olet vahvistanut sen.

## Mitä laajennus ei tee

- Sillä ei ole tiliä eikä omaa palvelinta: sen kehittäjät eivät saa siltä mitään tietoja.
- Se ei koskaan lähetä sähköpostia eikä koskaan näytä kuvia tai muuta sisältöä, jonka sähköposti lataisi verkosta: se näyttää sähköpostit pelkkänä tekstinä.
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
