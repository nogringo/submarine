# Datenschutzerklärung der Browser-Erweiterung von Submarine

Zuletzt aktualisiert: 18. Oktober 2026.

Submarine ist ein Passwortmanager. Seine Browser-Erweiterung zeigt die Passwörter, Karten und Notizen deiner Tresore, lässt dich sie erstellen und bearbeiten, kopiert sie für dich, füllt deine Zugangsdaten auf Websites aus und zeigt die E-Mails, die an die E-Mail-Adressen gesendet werden, die du deinen Zugangsdaten gibst. Diese Erklärung beschreibt, was die Erweiterung mit deinen Daten macht. Kurz gesagt: Es gibt keinen Submarine-Server, und die Erweiterung sendet nichts an ihre Entwickler.

## Was in deinem Browser bleibt

- Der Schlüssel jedes Tresors, den du erstellst oder öffnest, mit dem Namen und der Farbe, die du ihm gibst. Diese Angaben werden mit einem Schlüssel dieses Browsers verschlüsselt, der wiederum durch dein Sperrpasswort geschützt ist, sobald du eines festlegst.
- Eine Kopie des Inhalts deiner Tresore, damit sie sich öffnen, ohne auf das Netzwerk zu warten. Auch sie ist verschlüsselt.
- Die Nachrichten einer E-Mail-Adresse, so wie sie angekommen sind: verschlüsselt für den Schlüssel dieser Adresse. Die Erweiterung entschlüsselt sie jedes Mal, wenn sie sie anzeigt, und speichert sie nie entschlüsselt.
- Deine Einstellungen: die Zeit bis zum Sperren, die Zeit bis zum Leeren der Zwischenablage, die Optionen des Passwortgenerators sowie die E-Mail-Bridge, die Relays und die Server, die neue E-Mail-Adressen erhalten.
- Ein Formular, das du ungespeichert verlässt, damit es wieder erscheint, wenn du die Erweiterung erneut öffnest. Es bleibt im Arbeitsspeicher des Browsers, nie auf der Festplatte, und verschwindet, sobald du es speicherst, verwirfst, die Erweiterung sperrst oder den Browser schließt.

Wenn du einen Tresor aus der Erweiterung entfernst, werden sein Schlüssel und seine Kopie aus deinem Browser gelöscht. Wenn du die Erweiterung deinstallierst, wird alles gelöscht, was sie gespeichert hat.

## Was deinen Browser verlässt

Deine Tresore liegen auf Nostr-Relays: Servern unabhängiger Betreiber, die Daten für alle speichern. Deine Einträge werden auf deinen Geräten verschlüsselt, bevor sie ein Relay erreichen. Relays haben also nur Daten, die sie nicht lesen können.

Um deine Tresore herunterzuladen, verbindet sich die Erweiterung mit ihren Relays: mit den Relays, die jeder Tresor auflistet, sonst mit den [Standard-Relays](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) von Submarine, und mit drei Verzeichnis-Relays, auf denen die Relay-Liste eines Tresors veröffentlicht wird. Jedes Relay sieht deine IP-Adresse, wie jede Website, die du besuchst, und den öffentlichen Schlüssel jedes Tresors, den du öffnest. Mit diesem Schlüssel meldet sich die Erweiterung an und fragt die Daten des Tresors ab.

Wenn du einen Eintrag erstellst, bearbeitest, zu den Favoriten hinzufügst, in den Papierkorb verschiebst oder wiederherstellst, verschlüsselt die Erweiterung seine neue Version auf deinem Gerät und sendet sie an die Relays seines Tresors. Wenn du einen Eintrag dauerhaft löschst, bittet sie diese Relays, jede seiner Versionen zu löschen. Eine Änderung, die noch kein Relay angenommen hat, wartet in der verschlüsselten Kopie in deinem Browser und wird erneut gesendet, wenn du die Erweiterung das nächste Mal öffnest oder auf ihre Schaltfläche zum Synchronisieren klickst.

Der Passwortgenerator arbeitet in deinem Browser: Was er erzeugt, verlässt ihn nur in einem Eintrag, den du speicherst.

Wenn du einen Bitwarden-Export importierst, liest die Erweiterung die Datei, die du auswählst, in deinem Browser und speichert ihre Einträge dann in dem Tresor, den du wählst, wie Einträge, die du selbst erstellst. Wenn du einen Tresor exportierst, speichert sie die Datei auf deinem Computer, verschlüsselt mit dem Passwort, das du wählst, oder unverschlüsselt, wenn du diesen Schutz ausschaltest. Die Datei gelangt nirgendwo anders hin.

Wenn du sie bittest, Zugangsdaten auszufüllen, über ihr Fenster oder mit ihrem Tastenkürzel, schreibt die Erweiterung Benutzername und Passwort in das Anmeldeformular der aktuellen Seite, und zwar nur, wenn die Adresse der Seite zu den Zugangsdaten passt. Die Website erhält sie, sobald du dich anmeldest, genau wie beim Eintippen.

## E-Mail-Adressen

Zugangsdaten können über das Menü zum Hinzufügen eines Felds eine eigene E-Mail-Adresse bekommen, etwa `npub1...@uid.ovh`. Die Erweiterung erstellt für jede Adresse einen neuen Schlüssel, der nichts mit deinen Tresoren zu tun hat, und bewahrt ihn in einem versteckten Feld der Zugangsdaten auf, zusammen mit dem Rest des Eintrags verschlüsselt. Die Domain ist die einer E-Mail-Bridge, `uid.ovh`, sofern du in den Einstellungen keine andere wählst: ein Server eines unabhängigen Betreibers, der die an die Adresse gesendeten E-Mails empfängt, wie jeder E-Mail-Server, sie für den Schlüssel der Adresse verschlüsselt und an die Relays der Adresse weitergibt. Die Erweiterung sendet nie eine E-Mail und verbindet sich nie mit der Bridge.

Wenn du Zugangsdaten mit einer neuen E-Mail-Adresse speicherst, veröffentlicht die Erweiterung drei öffentliche Listen, signiert mit dem Schlüssel der Adresse, damit die Bridge weiß, wohin sie zustellen soll: die Relays der Adresse, gesendet an diese Relays und an die drei Verzeichnis-Relays; die Relays, auf denen ihre E-Mails ankommen; und die Server, die E-Mails empfangen, die für ein Relay zu groß sind. Diese Listen nennen den Schlüssel der Adresse und ihre Relays und Server, nie deine Tresore. Sofern du nichts änderst, sind das die [Standard-Relays und -Server für E-Mails](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) von Submarine. In den Einstellungen kannst du ändern, welche neue Adressen erhalten.

Solange Zugangsdaten mit einer E-Mail-Adresse angezeigt werden, verbindet sich die Erweiterung mit den Relays dieser Adresse, die sie auf den Verzeichnis-Relays findet, meldet sich dort mit dem Schlüssel der Adresse an, lädt ihre neuesten Nachrichten herunter und empfängt neu eintreffende, bis du die Zugangsdaten schließt. Jedes Relay sieht deine IP-Adresse und den öffentlichen Schlüssel der Adresse. Die Erweiterung empfängt auch die privaten Nachrichten (NIP-17), die an diesen Schlüssel gesendet werden. Eine E-Mail, die für ein Relay zu groß ist, wird verschlüsselt heruntergeladen, wenn du sie öffnest, und zwar von einem der Server der Adresse oder der Bridge, sonst von den Standard-Servern von Submarine. Dieser Server sieht deine IP-Adresse.

Wenn du eine E-Mail speicherst, schreibt die Erweiterung die ganze Nachricht samt Anhängen in eine Datei auf deinem Computer. Wenn du eine Nachricht löschst, bittet sie die Relays der Adresse, sie zu löschen. Wenn du Zugangsdaten dauerhaft löschst, werden ihre Nachrichten nicht von den Relays gelöscht. Ein Link in einer Nachricht öffnet sich erst in einem neuen Tab, wenn du ihn bestätigt hast, nachdem die Erweiterung gezeigt hat, wohin er führt.

## Was die Erweiterung nicht tut

- Sie hat kein Konto und keinen eigenen Server: Ihre Entwickler erhalten keine Daten von ihr.
- Sie sendet nie eine E-Mail und zeigt nie die Bilder oder anderen Inhalte an, die eine E-Mail aus dem Web laden würde: Sie zeigt E-Mails als reinen Text an.
- Sie hat keine Analyse, kein Tracking und keine Werbung.
- Sie liest nichts von den Seiten, die du besuchst, außer den Feldern der aktuellen Seite, wenn du sie bittest, Zugangsdaten auszufüllen, um herauszufinden, wohin Benutzername und Passwort gehören. Beim Öffnen liest sie die Adresse des aktuellen Tabs, um die Zugangsdaten für diese Website zuerst anzuzeigen. Beides verlässt deinen Browser nicht.
- Sie schreibt nur das in die Zwischenablage, was du kopierst, und den Verifizierungscode der Zugangsdaten, die sie ausfüllt. Danach leert sie die Zwischenablage nach der in den Einstellungen gewählten Zeit. Sie liest die Zwischenablage nie.

## Berechtigungen

- Speicher: bewahrt deine Tresore und Einstellungen in deinem Browser auf, wie oben beschrieben.
- In die Zwischenablage schreiben: kopiert ein Passwort, einen Code oder ein anderes Feld, wenn du darum bittest.
- Alarme: sperrt die Tresore, sobald die Zeit bis zum Sperren abgelaufen ist.
- Aktiver Tab: gibt der Erweiterung den Tab, über dem du sie öffnest oder in dem du ihr Tastenkürzel nutzt, und nur diesen: seine Adresse, um die Zugangsdaten für diese Website zuerst anzuzeigen, und seine Seite, um Zugangsdaten auszufüllen, wenn du darum bittest.
- Skripte: füllt Zugangsdaten in die Seite dieses Tabs ein, wenn du darum bittest.
- Offscreen-Dokumente, nur in Chrome: kopiert den Verifizierungscode ausgefüllter Zugangsdaten und leert die Zwischenablage nach der eingestellten Zeit, auch wenn das Fenster der Erweiterung geschlossen ist.

## Änderungen und Kontakt

Diese Erklärung ändert sich mit der Erweiterung. Ihr Verlauf ist der Verlauf dieser Datei im [Submarine-Repository](https://github.com/nogringo/submarine). Bei Fragen eröffne ein [Issue](https://github.com/nogringo/submarine/issues).
