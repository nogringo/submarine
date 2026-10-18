---
description: "Guarda una copia de tus cajas fuertes, y de las de los tuyos, en servidores que gestionas tú: un relay de Nostr para las cajas fuertes y un servidor de archivos para sus adjuntos."
---

# Aloja servidores para ti y los tuyos

Submarine no tiene servidor propio: por defecto, tus cajas fuertes se copian en relays públicos de Nostr gestionados por operadores independientes. Puedes añadir servidores gestionados por ti, o por alguien de confianza: así una copia de tu caja fuerte se queda con gente que conoces.

## Para ti y los tuyos

Un solo servidor puede guardar las cajas fuertes de toda tu gente: dales su dirección y la añaden a sus cajas fuertes como en el paso 3.

- Si apagas tu servidor, no pierden nada: sus cajas fuertes siguen en sus otros relays y en cada uno de sus dispositivos.
- Tu servidor solo ve datos cifrados: no puede ni leer sus contraseñas ni cambiarlas. Como cualquier relay, ve su dirección IP.
- Si un amigo también tiene un servidor, añadid cada uno el del otro: así cada uno guarda una copia para el otro.

## Qué necesitas

- Una máquina accesible desde internet, como un servidor alquilado o un ordenador en casa.
- Un nombre de dominio que apunte a ella, con HTTPS.
- Docker, para instalar los dos servidores de abajo.

## 1. Instala un relay

Instala [nostr-relay](https://github.com/nogringo/nostr-relay) siguiendo sus instrucciones. A diferencia de la mayoría de los relays, solo entrega los datos de una caja fuerte a quien tiene su clave, y te deja eliminarlos.

Pon delante un proxy HTTPS que reenvíe la cabecera Host original: el relay la necesita para comprobar que Submarine tiene la clave de la caja fuerte.

Su dirección empieza por `wss://`, por ejemplo `wss://relay.example.com`.

## 2. Instala un servidor de archivos

Los archivos adjuntos a tus elementos se guardan en servidores de archivos, no en los relays. Para tener también una copia de ellos, instala [blossom-server](https://github.com/hzrd149/blossom-server) siguiendo sus instrucciones.

En su archivo de configuración, añade esta regla al principio de las reglas de `storage`:

```yaml
- type: application/octet-stream
  expiration: 100 years
```

Así, los archivos cifrados de Submarine se conservan. Sin esta regla, la configuración de ejemplo elimina cualquier archivo que nadie haya abierto en una semana.

Su dirección empieza por `https://`, por ejemplo `https://blossom.example.com`.

## 3. Añádelos a tu caja fuerte

1. Abre los ajustes de la caja fuerte y, en **Sincronización**, abre **Relays**.
2. Pulsa **Añadir relay**, escribe la dirección de tu relay, activa **Mantener privado** y pulsa **Añadir**.
3. Pulsa **Guardar**.
4. De vuelta en los ajustes de la caja fuerte, abre **Servidores de archivos** y añade tu servidor de archivos de la misma forma con **Añadir servidor**.

Repítelo con cada una de tus cajas fuertes. **Mantener privado** cifra la dirección dentro de la caja fuerte: si no, cualquiera podría ver que esta caja fuerte se guarda en tu servidor, y adivinar de quién es.

## Conserva algunos relays públicos

Conserva algunos relays públicos junto al tuyo: si tu servidor cae o pierde sus datos, tu caja fuerte sigue en ellos. Además, cada uno de tus dispositivos guarda su propia copia.
