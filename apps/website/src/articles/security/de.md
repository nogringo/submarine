---
description: "So schützt Submarine deine Passwörter: verschlüsselt auf deinen Geräten, auf offenen Servern, die nur verschlüsselte Daten sehen, mit einem Schlüssel nur für dich."
---

# So schützt Submarine deine Passwörter

Submarine verschlüsselt deinen Tresor auf deinen Geräten, bevor irgendetwas sie verlässt. Die Server, die ihn aufbewahren, sehen immer nur verschlüsselte Daten, und dazwischen gibt es weder ein Submarine-Konto noch einen Submarine-Server. Diese Seite erklärt, was geschützt ist, wie, und was noch fehlt.

## Dein Tresorschlüssel

Jeder Tresor hat seinen eigenen Schlüssel, der auf deinem Gerät entsteht, wenn du den Tresor erstellst. Wer diesen Schlüssel hat, kann den Tresor öffnen, und sonst niemand: weder die Server noch wir.

- Submarine zeigt dir den Schlüssel, wenn du den Tresor erstellst. Bewahre ihn sicher auf, etwa auf Papier oder in einem Passwortmanager, den du schon nutzt.
- Du kannst ihn auch mit einem Passwort deiner Wahl verschlüsselt aufbewahren. Um den Tresor zu öffnen, brauchst du dann beides: den verschlüsselten Schlüssel und sein Passwort.
- Einen verlorenen Schlüssel kann niemand wiederherstellen. Es gibt kein Konto und keinen Link zum Zurücksetzen, also bewahre eine Kopie des Schlüssels auf, oder des verschlüsselten Schlüssels und seines Passworts.

## Auf deinen Geräten

- Deine Tresore werden auf jedem Gerät verschlüsselt, mit einem Schlüssel dieses Geräts.
- Dein Sperrpasswort schützt diesen Schlüssel. Submarine leitet daraus mit Argon2id einen Schlüssel ab, einem Verfahren, das das Erraten von Passwörtern langsam und teuer machen soll. Auch ein vergessenes Sperrpasswort lässt sich nicht wiederherstellen: Du öffnest deine Tresore dann erneut mit ihren Schlüsseln.
- Dein Fingerabdruck, dein Gesicht oder deine Bildschirmsperre können Submarine statt des Sperrpassworts entsperren.
- Submarine sperrt sich nach einer Zeit, die du wählst, von sofort bis zu einigen Stunden, und löscht deine Tresore beim Sperren aus dem Arbeitsspeicher.
- Kopierte Passwörter werden nach einer Zeit, die du wählst, aus der Zwischenablage gelöscht.
- Unter Android sind Screenshots und Bildschirmaufnahmen von Submarine blockiert, außer du erlaubst sie.

## Auf den Servern

Deine Tresore liegen auf Nostr-Relays: offenen Servern unabhängiger Betreiber, die jeder nutzen oder selbst betreiben kann. Jeder Tresor wird auf mehrere Relays kopiert, damit er erhalten bleibt, wenn eines davon ausfällt, und du wählst, welche Relays ihn aufbewahren, auch deine eigenen.

Jede Änderung, die du machst, wird auf deinem Gerät verschlüsselt und in einem versiegelten Umschlag an die Relays gesendet. Ein Relay sieht:

- verschlüsselte Daten, die es nicht lesen kann,
- den öffentlichen Schlüssel des Tresors, an dem es erkennt, welche Umschläge zusammengehören, aber nicht, was sie enthalten,
- ein zufällig gewähltes Datum in den zwei Tagen vor der Änderung, statt des Zeitpunkts der Änderung,
- deine IP-Adresse, wie jede Website, die du besuchst.

Ein Relay kann deine Passwörter auch nicht verändern. Jede Änderung ist mit dem Tresorschlüssel signiert, und Submarine ignoriert alles, was der Tresor nicht signiert hat.

## Kein Konto, kein Tracking

- Es gibt kein Submarine-Konto, und kein Submarine-Server speichert deine Daten.
- Submarine hat keine Analyse, keine Absturzberichte und keine Werbung.
- Der Code ist Open Source unter der MIT-Lizenz, also kann jeder prüfen, was Submarine tut. [Quellcode ansehen](https://github.com/nogringo/submarine).

## Was noch fehlt

Noch hat kein unabhängiges Unternehmen die Sicherheit von Submarine überprüft. Bis dahin bewahre deine wichtigsten Passwörter, etwa für E-Mail und Bank, in einem Passwortmanager auf, der sich schon länger bewährt hat, und fang mit den übrigen an.

Wenn du ein Sicherheitsproblem findest, [melde es bitte](https://github.com/nogringo/submarine/issues) oder [kontaktiere uns über Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).

## Technische Details

Das vollständige Format ist im [Protokoll Nostr Passwords](https://openspecs.uid.ovh/spec/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te/nostr-passwords) beschrieben.

- Ein Tresor ist ein Nostr-Schlüsselpaar. Sein Schlüssel wird als `nsec` angezeigt, seine verschlüsselte Form ist ein `ncryptsec` nach NIP-49 (scrypt, dann XChaCha20-Poly1305).
- Jede Änderung ist eine neue Version des Eintrags: ein vom Tresor signiertes Event, mit NIP-44 für den Tresor verschlüsselt (ChaCha20 und HMAC-SHA256, aufgefüllt, um die genaue Länge zu verbergen) und in einen Gift Wrap nach NIP-59 verpackt, der mit einem Einmalschlüssel signiert und zufällig auf einen Zeitpunkt in den zwei vorangegangenen Tagen datiert ist.
- Einträge sind Bitwarden-Einträge, deshalb importiert und exportiert Submarine das Format von Bitwarden.
- Auf einem Gerät sind die Tresorschlüssel mit AES-256-CBC und HMAC-SHA256 unter einem Geräteschlüssel verschlüsselt. Dieser Schlüssel wird über Argon2id durch das Sperrpasswort geschützt oder im sicheren Speicher des Systems aufbewahrt. Die lokale Kopie der Tresore ist mit AES-256-GCM verschlüsselt.
- Wenn du Nostr nutzt, kann ein Signierer den Tresorschlüssel verwahren, sodass er nie an Submarine übergeben wird: ein Bunker (NIP-46), eine Signier-App wie Amber (NIP-55) oder eine Browser-Erweiterung (NIP-07).
