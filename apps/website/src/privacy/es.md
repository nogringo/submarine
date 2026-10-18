# Política de privacidad de la extensión del navegador de Submarine

Última actualización: 18 de octubre de 2026.

Submarine es un gestor de contraseñas. Su extensión del navegador muestra las contraseñas, tarjetas y notas de tus cajas fuertes, te permite crearlas y editarlas, las copia por ti, rellena tus inicios de sesión en los sitios web y muestra los correos enviados a las direcciones de correo que das a tus inicios de sesión. Esta política explica qué hace la extensión con tus datos. En resumen: no hay ningún servidor de Submarine, y la extensión no envía nada a sus desarrolladores.

## Lo que se queda en tu navegador

- La clave de cada caja fuerte que creas o abres, con el nombre y el color que le das. Se cifran con una clave propia de este navegador, protegida a su vez por tu contraseña de bloqueo en cuanto estableces una.
- Una copia del contenido de tus cajas fuertes, para que se abran sin esperar a la red. También está cifrada.
- Los mensajes de una dirección de correo, tal como llegaron: cifrados para la clave de esa dirección. La extensión los descifra cada vez que los muestra, y nunca los guarda descifrados.
- Tus ajustes: el tiempo antes del bloqueo, el tiempo antes de vaciar el portapapeles, las opciones del generador de contraseñas, así como el puente de correo, los relays y los servidores que se asignan a las nuevas direcciones de correo.
- Un formulario que dejas sin guardar, para que vuelva a aparecer cuando abras de nuevo la extensión. Se queda en la memoria del navegador, nunca en el disco, y desaparece en cuanto lo guardas, lo descartas, bloqueas la extensión o cierras el navegador.

Quitar una caja fuerte de la extensión borra su clave y su copia de tu navegador. Desinstalar la extensión borra todo lo que había guardado.

## Lo que sale de tu navegador

Tus cajas fuertes se guardan en relays de Nostr: servidores gestionados por operadores independientes, que almacenan datos para cualquiera. Tus elementos se cifran en tus dispositivos antes de llegar a un relay, así que los relays solo guardan datos que no pueden leer.

Para descargar tus cajas fuertes, la extensión se conecta a sus relays: los que indica cada caja fuerte o, si no indica ninguno, los [relays predeterminados](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) de Submarine, además de tres relays de directorio donde se publica la lista de relays de cada caja fuerte. Cada relay ve tu dirección IP, como cualquier sitio web que visitas, y la clave pública de cada caja fuerte que abres, con la que la extensión se identifica y pide los datos de esa caja fuerte.

Cuando creas, editas, marcas como favorito, mueves a la papelera o restauras un elemento, la extensión cifra su nueva versión en tu dispositivo y la envía a los relays de su caja fuerte. Cuando eliminas un elemento permanentemente, pide a esos relays que eliminen cada una de sus versiones. Un cambio que todavía no ha aceptado ningún relay espera en la copia cifrada de tu navegador, y se vuelve a enviar la próxima vez que abras la extensión o pulses su botón de sincronización.

El generador de contraseñas funciona en tu navegador: lo que genera solo sale de él dentro de un elemento que guardas.

Cuando importas una exportación de Bitwarden, la extensión lee en tu navegador el archivo que eliges y luego guarda sus elementos en la caja fuerte que indicas, como elementos que creas tú. Cuando exportas una caja fuerte, guarda el archivo en tu ordenador, cifrado con la contraseña que eliges, o sin cifrar si desactivas esa opción. El archivo no va a ningún otro sitio.

Cuando le pides que rellene un inicio de sesión, desde su ventana o con su atajo de teclado, la extensión escribe el nombre de usuario y la contraseña en el formulario de inicio de sesión de la página actual, y solo si la dirección de la página coincide con la del inicio de sesión. El sitio web los recibe cuando inicias sesión, igual que si los escribieras tú.

## Direcciones de correo

Puedes dar a un inicio de sesión su propia dirección de correo, como `npub1...@uid.ovh`, desde el menú para añadir un campo. La extensión crea una clave nueva para cada dirección, sin relación con tus cajas fuertes, y la guarda en un campo oculto del inicio de sesión, cifrada con el resto del elemento. El dominio es el de un puente de correo, `uid.ovh` salvo que elijas otro en los ajustes: un servidor gestionado por un operador independiente, que recibe los correos enviados a la dirección, como cualquier servidor de correo, los cifra para la clave de la dirección y los pasa a los relays de la dirección. La extensión nunca envía un correo y nunca se conecta al puente.

Cuando guardas un inicio de sesión con una dirección de correo nueva, la extensión publica tres listas públicas firmadas con la clave de la dirección, para que el puente sepa dónde entregar los correos: la lista de relays de la dirección, enviada a esos relays y a los tres relays de directorio; la de los relays a los que llegan sus correos; y la de los servidores que reciben los correos demasiado grandes para un relay. Estas listas indican la clave de la dirección y sus relays y servidores, nunca tus cajas fuertes. Por defecto, son los [relays y servidores de correo predeterminados](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) de Submarine; puedes cambiar en los ajustes los que se asignan a las nuevas direcciones.

Mientras se muestra un inicio de sesión con una dirección de correo, la extensión se conecta a los relays de esa dirección, que encuentra en los relays de directorio, se identifica en ellos con la clave de la dirección, descarga sus últimos mensajes y recibe los nuevos hasta que cierres el inicio de sesión. Cada relay ve tu dirección IP y la clave pública de la dirección. La extensión también recibe los mensajes privados (NIP-17) enviados a esa clave. Un correo demasiado grande para un relay se descarga, cifrado, cuando lo abres, desde uno de los servidores de la dirección o del puente o, si no, desde los servidores predeterminados de Submarine; ese servidor ve tu dirección IP.

Cuando guardas un correo, la extensión escribe el mensaje completo, con sus archivos adjuntos, en un archivo de tu ordenador. Cuando eliminas un mensaje, pide a los relays de la dirección que lo eliminen. Eliminar un inicio de sesión permanentemente no elimina sus mensajes de los relays. Un enlace de un mensaje solo se abre en una pestaña nueva cuando lo has confirmado, después de que la extensión te haya mostrado adónde lleva.

## Lo que la extensión no hace

- No tiene cuenta ni servidor propio: sus desarrolladores no reciben ningún dato de ella.
- Nunca envía un correo, y nunca muestra las imágenes ni otros contenidos que un correo cargaría desde la web: muestra los correos como texto sin formato.
- No tiene analíticas, ni rastreo, ni anuncios.
- No lee nada de las páginas que visitas, salvo los campos de la página actual cuando le pides que rellene un inicio de sesión, para saber dónde van el nombre de usuario y la contraseña. Al abrirla, lee la dirección de la pestaña actual para mostrar primero los inicios de sesión de ese sitio. Ninguno de los dos sale de tu navegador.
- Solo escribe en el portapapeles lo que copias y el código de verificación de un inicio de sesión que rellena, y luego vacía el portapapeles pasado el tiempo elegido en los ajustes. Nunca lee el portapapeles.

## Permisos

- Almacenamiento: guarda tus cajas fuertes y tus ajustes en tu navegador, como se describe arriba.
- Escritura en el portapapeles: copia una contraseña, un código o cualquier otro campo cuando lo pides.
- Alarmas: bloquea las cajas fuertes cuando pasa el tiempo antes del bloqueo.
- Pestaña activa: da a la extensión la pestaña sobre la que la abres o en la que usas su atajo, y solo esa: su dirección, para mostrar primero los inicios de sesión de ese sitio, y su página, para rellenar un inicio de sesión cuando lo pides.
- Scripts: rellena un inicio de sesión en la página de esa pestaña cuando lo pides.
- Documentos fuera de pantalla, solo en Chrome: copia el código de verificación de un inicio de sesión rellenado y vacía el portapapeles cuando pasa su tiempo, incluso con la ventana de la extensión cerrada.

## Cambios y contacto

Esta política cambia con la extensión. Su historial es el de este archivo en el [repositorio de Submarine](https://github.com/nogringo/submarine). Para cualquier pregunta, abre una [incidencia](https://github.com/nogringo/submarine/issues).
