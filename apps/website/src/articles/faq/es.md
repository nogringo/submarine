---
description: "Preguntas frecuentes sobre Submarine, el gestor de contraseñas sin cuenta: clave perdida, servidor caído, uso sin conexión, cajas fuertes compartidas y precio."
---

# Preguntas y respuestas

## ¿Qué pasa si pierdo la clave de mi caja fuerte?

Nadie puede recuperarla, ni siquiera nosotros: no hay cuenta ni enlace para restablecerla. Si Submarine sigue abierto en alguno de tus dispositivos, copia la clave desde los ajustes de la caja fuerte y guárdala en un lugar seguro. Si no, la caja fuerte ya no se podrá volver a abrir.

## ¿Qué pasa si un servidor cierra?

Cada caja fuerte se copia en varios relays, y cada uno de tus dispositivos guarda su propia copia. Si un relay cae, los demás siguen teniendo tu caja fuerte. Puedes añadir o quitar relays en los ajustes de la caja fuerte, en Sincronización.

## ¿Quién gestiona los servidores?

Los relays de Nostr los gestionan operadores independientes, para todas las apps que usan Nostr, no solo para Submarine. Solo ven datos cifrados. También puedes tener tu propio relay y añadirlo a tu caja fuerte.

## ¿Submarine funciona sin conexión?

Sí. Cada cambio se guarda primero en tu dispositivo y se sincroniza en cuanto vuelves a tener conexión. Submarine muestra cuántos cambios faltan por enviar.

## ¿Puedo usarlo en varios dispositivos?

Sí: en Android, Windows, macOS y Linux, y en la web para cualquier otro dispositivo. Abre tu caja fuerte en cada uno de ellos con la misma clave. [Descargar Submarine](/es/download).

## ¿Puedo compartir una caja fuerte?

Sí. Da la clave de la caja fuerte a la persona con quien la compartes: quien la tenga puede abrir y modificar la caja fuerte. Una clave no se puede retirar una vez dada, así que guarda las contraseñas compartidas en una caja fuerte aparte, separadas de las tuyas personales.

## ¿Qué pasa si edito el mismo elemento en dos dispositivos a la vez?

Se conservan las dos ediciones. Submarine nunca sobrescribe una con la otra sin avisar.

## ¿Submarine es gratis?

Sí. No hay nada que pagar, ni versión premium, ni anuncios. Submarine es de código abierto, con licencia MIT.

## ¿En qué se diferencia de otros gestores de contraseñas?

Con la mayoría de los gestores de contraseñas, tu caja fuerte vive en los servidores de la empresa que los crea, detrás de una cuenta. Submarine no tiene cuenta ni servidor propio: tu caja fuerte se copia en servidores abiertos que eliges tú, y solo tu clave la abre. La otra cara es que nadie puede recuperar una clave perdida. Además, Submarine es más joven y todavía no está auditado.

## ¿Puedo importar mis contraseñas?

Sí, desde Bitwarden, y desde la mayoría de los demás gestores de contraseñas a través de Bitwarden. [Importar desde Bitwarden](/es/import-bitwarden). Puedes exportar tus cajas fuertes en cualquier momento, en un formato que otros gestores de contraseñas pueden importar.

## ¿Es seguro Submarine?

Tu caja fuerte se cifra en tus dispositivos, y los servidores solo ven datos cifrados. Sin embargo, ninguna empresa independiente ha auditado todavía Submarine. [Cómo protege Submarine tus contraseñas](/es/security).

## ¿Qué es Nostr?

Un protocolo abierto para intercambiar datos a través de relays: servidores que cualquiera puede gestionar. Submarine lo usa para sincronizar tu caja fuerte sin una empresa de por medio. No necesitas conocer Nostr, ni tener una cuenta de Nostr, para usar Submarine.

## ¿Cómo informo de un problema?

[Infórmalo en GitHub](https://github.com/nogringo/submarine/issues) o [contáctanos en Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).
