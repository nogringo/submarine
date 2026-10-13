# Política de privacidad de la extensión del navegador de Submarine

Última actualización: 12 de octubre de 2026.

Submarine es un gestor de contraseñas. Su extensión del navegador muestra las contraseñas, tarjetas y notas de tus cajas fuertes, te permite crearlas y editarlas, las copia por ti y rellena tus inicios de sesión en los sitios web. Esta política explica qué hace la extensión con tus datos. En resumen: no hay ningún servidor de Submarine, y la extensión no envía nada a sus desarrolladores.

## Lo que se queda en tu navegador

- La clave de cada caja fuerte que abres, con el nombre y el color que le das. Se cifran con una clave propia de este navegador, protegida a su vez por tu contraseña de bloqueo en cuanto estableces una.
- Una copia del contenido de tus cajas fuertes, para que se abran sin esperar a la red. También está cifrada.
- Tus ajustes: el tiempo antes del bloqueo, el tiempo antes de vaciar el portapapeles y las opciones del generador de contraseñas.
- Un formulario que dejas sin guardar, para que vuelva a aparecer cuando abras de nuevo la extensión. Se queda en la memoria del navegador, nunca en el disco, y desaparece en cuanto lo guardas, lo descartas, bloqueas la extensión o cierras el navegador.

Quitar una caja fuerte de la extensión borra su clave y su copia de tu navegador. Desinstalar la extensión borra todo lo que había guardado.

## Lo que sale de tu navegador

Tus cajas fuertes se guardan en relays de Nostr: servidores gestionados por operadores independientes, que almacenan datos para cualquiera. Tus elementos se cifran en tus dispositivos antes de llegar a un relay, así que los relays solo guardan datos que no pueden leer.

Para descargar tus cajas fuertes, la extensión se conecta a sus relays: los que indica cada caja fuerte o, si no indica ninguno, los [relays predeterminados](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart) de Submarine, además de tres relays de directorio donde se publica la lista de relays de cada caja fuerte. Cada relay ve tu dirección IP, como cualquier sitio web que visitas, y la clave pública de cada caja fuerte que abres, con la que la extensión se identifica y pide los datos de esa caja fuerte.

Cuando creas, editas, marcas como favorito, mueves a la papelera o restauras un elemento, la extensión cifra su nueva versión en tu dispositivo y la envía a los relays de su caja fuerte. Cuando eliminas un elemento permanentemente, pide a esos relays que eliminen cada una de sus versiones. Un cambio que todavía no ha aceptado ningún relay espera en la copia cifrada de tu navegador, y se vuelve a enviar la próxima vez que abras la extensión o pulses su botón de sincronización.

El generador de contraseñas funciona en tu navegador: lo que genera solo sale de él dentro de un elemento que guardas.

Cuando le pides que rellene un inicio de sesión, desde su ventana o con su atajo de teclado, la extensión escribe el nombre de usuario y la contraseña en el formulario de inicio de sesión de la página actual, y solo si la dirección de la página coincide con la del inicio de sesión. El sitio web los recibe cuando inicias sesión, igual que si los escribieras tú.

## Lo que la extensión no hace

- No tiene cuenta ni servidor propio: sus desarrolladores no reciben ningún dato de ella.
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
