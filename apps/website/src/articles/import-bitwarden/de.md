---
description: Übertrage deine Passwörter in wenigen Minuten von Bitwarden zu Submarine, mit benutzerdefinierten Feldern und Zwei-Faktor-Codes, und nimm sie jederzeit wieder mit.
---

# Passwörter aus Bitwarden importieren

Submarine liest die Exportdatei von Bitwarden, der Umzug deiner Passwörter dauert also nur wenige Minuten. In deinem Bitwarden-Konto ändert sich nichts: Der Import kopiert lediglich deine Einträge.

## 1. Exportiere deinen Tresor aus Bitwarden

1. Öffne im Web-Tresor von Bitwarden Werkzeuge und dann Tresor exportieren. Die Bitwarden-Apps haben denselben Befehl in ihren Einstellungen oder Menüs.
2. Wähle das Format .json. Du kannst auch das verschlüsselte Format .json wählen, geschützt durch ein Passwort deiner Wahl: Auch das öffnet Submarine.
3. Bestätige mit deinem Bitwarden-Master-Passwort und speichere die Datei.

Ein verschlüsselter Export, der auf dein Bitwarden-Konto beschränkt ist, funktioniert nicht: Nur Bitwarden kann ihn öffnen. Wähle stattdessen den passwortgeschützten Typ.

## 2. Importiere die Datei in Submarine

1. Öffne Submarine und erstelle oder öffne den Tresor, in den deine Passwörter kommen sollen.
2. Geh zu **Einstellungen**, dann **Import und Export**, und drücke neben **Aus Bitwarden importieren** auf **Importieren**.
3. Wähle die Datei aus. Ist sie durch ein Passwort geschützt, gib dieses Passwort ein.
4. Prüfe, wie viele Einträge gefunden wurden, wähle den Tresor, falls du mehrere hast, und drücke auf **Importieren**.

Deine Einträge werden auf deinem Gerät verschlüsselt und dann wie jede andere Änderung mit deinen anderen Geräten synchronisiert.

## 3. Lösche die Exportdatei

Ein .json-Export ohne Passwort ist nicht verschlüsselt: Wer ihn in die Hände bekommt, kann alle deine Passwörter lesen. Lösche ihn, sobald der Import abgeschlossen ist, und leere den Papierkorb deines Computers. Verschicke ihn nicht per E-Mail.

## Was importiert wird

- Zugangsdaten, Karten, sichere Notizen, Identitäten, SSH-Schlüssel und die anderen Eintragstypen von Bitwarden, mit ihren benutzerdefinierten Feldern und ihren Codes für die Zwei-Faktor-Authentifizierung.
- Zugangsdaten, Karten und sichere Notizen lassen sich in Submarine bearbeiten. Die anderen Typen bleiben erhalten und werden angezeigt, lassen sich aber noch nicht bearbeiten.
- Passkeys bleiben erhalten und werden angezeigt, aber Submarine kann sich noch nicht mit ihnen anmelden.
- Ordner werden nicht importiert: Submarine trennt Einträge stattdessen nach Tresoren.
- Angehängte Dateien sind nicht Teil des Bitwarden-Exports und bleiben deshalb in Bitwarden.

## Von einem anderen Passwortmanager

Submarine liest nur das Format von Bitwarden. Bitwarden selbst importiert aus den meisten Passwortmanagern, etwa aus 1Password, LastPass, KeePass oder deinem Browser. Importiere deine Passwörter mit einem kostenlosen Bitwarden-Konto zuerst dort und folge dann den Schritten oben.

## Submarine verlassen

Submarine exportiert im selben Format. Unter **Einstellungen**, dann **Import und Export**, speichert **Tresor exportieren** eine Bitwarden-Datei, passwortgeschützt oder unverschlüsselt, die Bitwarden und andere Passwortmanager importieren können. Der Papierkorb wird nicht mit exportiert.

Neu bei Submarine? [Lade es herunter](/de/download) oder lies, [wie es deine Passwörter schützt](/de/security).
