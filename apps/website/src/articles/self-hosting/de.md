---
description: "Bewahre eine Kopie deiner Tresore auf Servern auf, die du selbst betreibst: ein Nostr-Relay für deine Tresore und einen Dateiserver für ihre Anhänge."
---

# Eigene Server betreiben

Submarine hat keinen eigenen Server: Standardmäßig werden deine Tresore auf öffentliche Nostr-Relays unabhängiger Betreiber kopiert. Füge Server hinzu, die du selbst betreibst, dann bleibt dort eine Kopie deines Tresors, so lange du willst.

## Was du brauchst

- Einen Rechner, der aus dem Internet erreichbar ist, etwa einen gemieteten Server oder einen Computer bei dir zu Hause.
- Einen Domainnamen, der auf ihn zeigt, mit HTTPS.
- Docker, um die beiden Server unten zu installieren.

## 1. Installiere ein Relay

Installiere [nostr-relay](https://github.com/nogringo/nostr-relay) nach seiner Anleitung. Anders als die meisten Relays gibt es die Daten eines Tresors nur an den heraus, der den Tresorschlüssel hat, und lässt dich sie löschen.

Setze einen HTTPS-Proxy davor, der den ursprünglichen Host-Header weitergibt: Das Relay braucht ihn, um zu prüfen, dass Submarine den Tresorschlüssel hat.

Seine Adresse beginnt mit `wss://`, zum Beispiel `wss://relay.example.com`.

## 2. Installiere einen Dateiserver

Die an deine Einträge angehängten Dateien liegen auf Dateiservern, nicht auf Relays. Um auch von ihnen eine eigene Kopie zu behalten, installiere [blossom-server](https://github.com/hzrd149/blossom-server) nach seiner Anleitung.

Setze in seiner Konfigurationsdatei `rules: []` unter `storage`. Die Beispielkonfiguration löscht jede Datei, die eine Woche lang niemand geöffnet hat, und damit auch deine Anhänge.

Seine Adresse beginnt mit `https://`, zum Beispiel `https://blossom.example.com`.

## 3. Füge sie deinem Tresor hinzu

1. Öffne die Tresoreinstellungen und unter **Synchronisierung** den Punkt **Relays**.
2. Drücke auf **Relay hinzufügen**, gib die Adresse deines Relays ein, schalte **Privat halten** ein und drücke auf **Hinzufügen**.
3. Drücke auf **Speichern**.
4. Öffne wieder in den Tresoreinstellungen **Dateiserver** und füge deinen Dateiserver genauso mit **Server hinzufügen** hinzu.

Wiederhole das für jeden deiner Tresore. **Privat halten** verschlüsselt die Adresse im Tresor: Sonst könnte jeder sehen, dass dieser Tresor auf deinem Server liegt, und erraten, wem er gehört.

## Behalte ein paar öffentliche Relays

Behalte neben deinem eigenen ein paar öffentliche Relays: Fällt dein Server aus oder verliert er seine Daten, liegt dein Tresor noch dort. Außerdem hat jedes deiner Geräte seine eigene Kopie.
