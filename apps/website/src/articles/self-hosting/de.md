---
description: "Bewahre eine Kopie deiner Tresore und der Tresore deines Umfelds auf Servern auf, die du betreibst: ein Nostr-Relay für die Tresore und einen Dateiserver für ihre Anhänge."
---

# Server für dich und dein Umfeld betreiben

Submarine hat keinen eigenen Server: Standardmäßig werden deine Tresore auf öffentliche Nostr-Relays unabhängiger Betreiber kopiert. Du kannst Server hinzufügen, die du selbst oder jemand betreibt, dem du vertraust: Dann bleibt eine Kopie deines Tresors bei Menschen, die du kennst.

## Für dich und dein Umfeld

Ein einziger Server kann die Tresore deines ganzen Umfelds aufbewahren: Gib ihnen seine Adresse, und sie fügen ihn wie in Schritt 3 ihren Tresoren hinzu.

- Schaltest du deinen Server ab, verlieren sie nichts: Ihre Tresore liegen weiter auf ihren anderen Relays und auf jedem ihrer Geräte.
- Dein Server sieht nur verschlüsselte Daten: Er kann ihre Passwörter weder lesen noch ändern. Wie jedes Relay sieht er ihre IP-Adresse.
- Betreibt ein Freund auch einen Server, fügt jeder den Server des anderen hinzu: So bewahrt ihr gegenseitig eine Kopie füreinander auf.

## Was du brauchst

- Einen Rechner, der aus dem Internet erreichbar ist, etwa einen gemieteten Server oder einen Computer bei dir zu Hause.
- Einen Domainnamen, der auf ihn zeigt, mit HTTPS.
- Docker, um die beiden Server unten zu installieren.

## 1. Installiere ein Relay

Installiere [nostr-relay](https://github.com/nogringo/nostr-relay) nach seiner Anleitung. Anders als die meisten Relays gibt es die Daten eines Tresors nur an den heraus, der den Tresorschlüssel hat, und lässt dich sie löschen.

Setze einen HTTPS-Proxy davor, der den ursprünglichen Host-Header weitergibt: Das Relay braucht ihn, um zu prüfen, dass Submarine den Tresorschlüssel hat.

Seine Adresse beginnt mit `wss://`, zum Beispiel `wss://relay.example.com`.

## 2. Installiere einen Dateiserver

Die an deine Einträge angehängten Dateien liegen auf Dateiservern, nicht auf Relays. Um auch von ihnen eine Kopie zu behalten, installiere [blossom-server](https://github.com/hzrd149/blossom-server) nach seiner Anleitung.

Füge in seiner Konfigurationsdatei diese Regel ganz oben bei den Regeln unter `storage` ein:

```yaml
- type: application/octet-stream
  expiration: 100 years
```

Die verschlüsselten Dateien von Submarine bleiben dann erhalten. Ohne diese Regel löscht die Beispielkonfiguration jede Datei, die eine Woche lang niemand geöffnet hat.

Seine Adresse beginnt mit `https://`, zum Beispiel `https://blossom.example.com`.

## 3. Füge sie deinem Tresor hinzu

1. Öffne die Tresoreinstellungen und unter **Synchronisierung** den Punkt **Relays**.
2. Drücke auf **Relay hinzufügen**, gib die Adresse deines Relays ein, schalte **Privat halten** ein und drücke auf **Hinzufügen**.
3. Drücke auf **Speichern**.
4. Öffne wieder in den Tresoreinstellungen **Dateiserver** und füge deinen Dateiserver genauso mit **Server hinzufügen** hinzu.

Wiederhole das für jeden deiner Tresore. **Privat halten** verschlüsselt die Adresse im Tresor: Sonst könnte jeder sehen, dass dieser Tresor auf deinem Server liegt, und erraten, wem er gehört.

## Behalte ein paar öffentliche Relays

Behalte neben deinem eigenen ein paar öffentliche Relays: Fällt dein Server aus oder verliert er seine Daten, liegt dein Tresor noch dort. Außerdem hat jedes deiner Geräte seine eigene Kopie.
