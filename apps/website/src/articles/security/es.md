---
description: "Cómo protege Submarine tus contraseñas: se cifran en tus dispositivos, se guardan en servidores abiertos que solo ven datos cifrados y solo tu clave las abre."
---

# Cómo protege Submarine tus contraseñas

Submarine cifra tu caja fuerte en tus dispositivos, antes de que nada salga de ellos. Los servidores que la guardan solo ven datos cifrados, y no hay ninguna cuenta ni ningún servidor de Submarine de por medio. Esta página explica qué está protegido, cómo, y qué falta por hacer.

## La clave de tu caja fuerte

Cada caja fuerte tiene su propia clave, creada en tu dispositivo cuando creas la caja fuerte. Quien tenga esta clave puede abrir la caja fuerte, y nadie más puede hacerlo: ni los servidores, ni nosotros.

- Submarine te muestra la clave cuando creas la caja fuerte. Guárdala en un lugar seguro, por ejemplo en papel o en un gestor de contraseñas que ya uses.
- También puedes guardarla cifrada con una contraseña que elijas. En ese caso necesitarás la clave cifrada y su contraseña para abrir la caja fuerte.
- Nadie puede recuperar una clave perdida. No hay cuenta ni enlace para restablecerla, así que guarda una copia de la clave, o de la clave cifrada y su contraseña.

## En tus dispositivos

- Tus cajas fuertes se cifran en cada dispositivo, con una clave propia de ese dispositivo.
- Tu contraseña de bloqueo protege esa clave. Submarine la convierte en una clave con Argon2id, un método diseñado para que adivinar contraseñas sea lento y costoso. Una contraseña de bloqueo olvidada tampoco se puede recuperar: en ese caso, vuelves a abrir tus cajas fuertes con sus claves.
- Tu huella, tu rostro o el bloqueo de pantalla pueden desbloquear Submarine en lugar de la contraseña de bloqueo.
- Submarine se bloquea solo al cabo del tiempo que elijas, desde al instante hasta unas horas, y borra tus cajas fuertes de la memoria al bloquearse.
- Las contraseñas copiadas se borran del portapapeles al cabo del tiempo que elijas.
- En Android, las capturas y grabaciones de pantalla de Submarine están bloqueadas, salvo que las permitas.

## En los servidores

Tus cajas fuertes se guardan en relays de Nostr: servidores abiertos gestionados por operadores independientes, que cualquiera puede usar o gestionar. Cada caja fuerte se copia en varios relays, así que sobrevive si uno de ellos cae, y tú eliges qué relays la guardan, incluidos los tuyos.

Cada cambio que haces se cifra en tu dispositivo y se envía a los relays en un sobre sellado. Un relay ve:

- datos cifrados que no puede leer,
- la clave pública de la caja fuerte, que le indica qué sobres van juntos, pero no qué contienen,
- una fecha elegida al azar dentro de los dos días anteriores al cambio, en lugar de la hora del cambio,
- tu dirección IP, como cualquier sitio web que visitas.

Un relay tampoco puede modificar tus contraseñas. Cada cambio se firma con la clave de la caja fuerte, y Submarine ignora todo lo que la caja fuerte no haya firmado.

## Sin cuenta, sin rastreo

- No hay cuenta de Submarine, y ningún servidor de Submarine guarda tus datos.
- Submarine no tiene analíticas, ni informes de fallos, ni anuncios.
- El código es abierto, con licencia MIT, así que cualquiera puede comprobar qué hace Submarine. [Ver el código fuente](https://github.com/nogringo/submarine).

## Lo que falta por hacer

Ninguna empresa independiente ha auditado todavía la seguridad de Submarine. Hasta que eso ocurra, guarda tus contraseñas más críticas, como las de tu correo y tu banco, en un gestor de contraseñas con más trayectoria, y empieza con las demás.

Si encuentras un problema de seguridad, [infórmanos](https://github.com/nogringo/submarine/issues) o [contáctanos en Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).

## Detalles técnicos

El formato completo se describe en el [protocolo Nostr Passwords](https://openspecs.uid.ovh/spec/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te/nostr-passwords).

- Una caja fuerte es un par de claves de Nostr. Su clave se muestra como una `nsec`, y su forma cifrada es una `ncryptsec` de NIP-49 (scrypt y después XChaCha20-Poly1305).
- Cada cambio es una nueva versión del elemento: un evento firmado por la caja fuerte, cifrado para la caja fuerte con NIP-44 (ChaCha20 y HMAC-SHA256, con relleno para ocultar la longitud exacta) y metido en un gift wrap de NIP-59, firmado por una clave de un solo uso y fechado al azar dentro de los dos días anteriores.
- Los elementos son elementos de Bitwarden, y por eso Submarine importa y exporta el formato de Bitwarden.
- En un dispositivo, las claves de las cajas fuertes se cifran con AES-256-CBC y HMAC-SHA256 con una clave del dispositivo. Esa clave está protegida por la contraseña de bloqueo mediante Argon2id, o se guarda en el almacenamiento seguro del sistema. La copia local de las cajas fuertes se cifra con AES-256-GCM.
- Si usas Nostr, un firmante puede guardar la clave de la caja fuerte para que nunca entre en Submarine: un bunker (NIP-46), una app de firma como Amber (NIP-55) o una extensión del navegador (NIP-07).
