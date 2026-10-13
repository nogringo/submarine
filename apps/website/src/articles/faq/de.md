---
description: "Antworten auf häufige Fragen zu Submarine, dem Passwortmanager ohne Konto: verlorener Schlüssel, ausgefallener Server, offline nutzen, Tresor teilen und Kosten."
---

# Fragen und Antworten

## Was, wenn ich meinen Tresorschlüssel verliere?

Niemand kann ihn wiederherstellen, nicht einmal wir: Es gibt kein Konto und keinen Link zum Zurücksetzen. Ist Submarine auf einem deiner Geräte noch geöffnet, kopiere den Schlüssel aus den Tresoreinstellungen und bewahre ihn sicher auf. Andernfalls lässt sich der Tresor nicht mehr öffnen.

## Was, wenn ein Server abgeschaltet wird?

Jeder Tresor wird auf mehrere Relays kopiert, und jedes deiner Geräte hat seine eigene Kopie. Fällt ein Relay aus, haben die anderen deinen Tresor noch. In den Tresoreinstellungen kannst du unter Synchronisierung Relays hinzufügen oder entfernen.

## Wer betreibt die Server?

Nostr-Relays werden von unabhängigen Betreibern betrieben, für alle Apps, die Nostr nutzen, nicht nur für Submarine. Sie sehen nur verschlüsselte Daten. Du kannst auch dein eigenes Relay betreiben und es deinem Tresor hinzufügen.

## Funktioniert Submarine offline?

Ja. Jede Änderung wird zuerst auf deinem Gerät gespeichert und synchronisiert, sobald du wieder online bist. Submarine zeigt an, wie viele Änderungen noch darauf warten, gesendet zu werden.

## Kann ich es auf mehreren Geräten nutzen?

Ja: unter Android, Windows, macOS und Linux, und im Web für alle anderen Geräte. Öffne deinen Tresor auf jedem davon mit demselben Schlüssel. [Submarine herunterladen](/de/download).

## Kann ich einen Tresor teilen?

Ja. Gib den Tresorschlüssel der Person, mit der du ihn teilst: Wer ihn hat, kann den Tresor öffnen und ändern. Ein weitergegebener Schlüssel lässt sich nicht zurücknehmen, also bewahre geteilte Passwörter in einem eigenen Tresor auf, getrennt von deinen persönlichen.

## Was, wenn ich denselben Eintrag gleichzeitig auf zwei Geräten bearbeite?

Beide Änderungen bleiben erhalten. Submarine überschreibt nie stillschweigend die eine mit der anderen.

## Ist Submarine kostenlos?

Ja. Es gibt nichts zu bezahlen, keine Premium-Version und keine Werbung. Submarine ist Open Source, unter der MIT-Lizenz.

## Was unterscheidet es von anderen Passwortmanagern?

Bei den meisten Passwortmanagern liegt dein Tresor hinter einem Konto auf den Servern des Unternehmens, das sie entwickelt. Submarine hat kein Konto und keinen eigenen Server: Dein Tresor wird auf offene Server kopiert, die du wählst, und nur dein Schlüssel öffnet ihn. Die Kehrseite: Einen verlorenen Schlüssel kann niemand wiederherstellen. Submarine ist außerdem jünger und hatte noch kein Audit.

## Kann ich meine Passwörter importieren?

Ja, aus Bitwarden, und über Bitwarden aus den meisten anderen Passwortmanagern. [Aus Bitwarden importieren](/de/import-bitwarden). Du kannst deine Tresore jederzeit exportieren, in einem Format, das andere Passwortmanager importieren können.

## Ist Submarine sicher?

Dein Tresor wird auf deinen Geräten verschlüsselt, und die Server sehen nur verschlüsselte Daten. Allerdings hat noch kein unabhängiges Unternehmen Submarine überprüft. [So schützt Submarine deine Passwörter](/de/security).

## Was ist Nostr?

Ein offenes Protokoll, um Daten über Relays auszutauschen: Server, die jeder betreiben kann. Submarine nutzt es, um deinen Tresor ohne ein Unternehmen dazwischen zu synchronisieren. Um Submarine zu nutzen, musst du Nostr weder kennen noch ein Nostr-Konto haben.

## Wie melde ich ein Problem?

[Melde es auf GitHub](https://github.com/nogringo/submarine/issues) oder [kontaktiere uns über Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).
