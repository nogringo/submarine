---
description: Pasa tus contraseñas de Bitwarden a Submarine en unos minutos, con sus campos personalizados y sus códigos de dos pasos, y vuelve a sacarlas cuando quieras.
---

# Importa tus contraseñas desde Bitwarden

Submarine lee el archivo de exportación de Bitwarden, así que pasar tus contraseñas lleva unos minutos. Nada cambia en tu cuenta de Bitwarden: la importación solo copia tus elementos.

## 1. Exporta tu caja fuerte desde Bitwarden

1. En la caja fuerte web de Bitwarden, abre Herramientas y luego Exportar caja fuerte. Las apps de Bitwarden tienen el mismo comando en sus ajustes o menús.
2. Elige el formato .json. También puedes elegir el formato .json cifrado, protegido por una contraseña que elijas: Submarine también lo abre.
3. Confirma con tu contraseña maestra de Bitwarden y guarda el archivo.

Una exportación cifrada restringida a tu cuenta de Bitwarden no funciona: solo Bitwarden puede abrirla. Elige en su lugar el tipo protegido por contraseña.

## 2. Importa el archivo en Submarine

1. Abre Submarine y crea o abre la caja fuerte donde quieres guardar tus contraseñas.
2. Ve a **Ajustes**, luego a **Importar y exportar**, y pulsa **Importar** junto a **Importar desde Bitwarden**.
3. Elige el archivo. Si está protegido con contraseña, introdúcela.
4. Comprueba cuántos elementos se han encontrado, elige la caja fuerte si tienes varias y pulsa **Importar**.

Tus elementos se cifran en tu dispositivo y luego se sincronizan con tus otros dispositivos, como cualquier otro cambio.

## 3. Elimina el archivo de exportación

Una exportación .json sin contraseña no está cifrada: cualquiera que la consiga puede leer todas tus contraseñas. Elimínala cuando termine la importación y vacía la papelera de tu ordenador. No la envíes por correo electrónico.

## Qué se importa

- Inicios de sesión, tarjetas, notas seguras, identidades, claves SSH y los demás tipos de elementos de Bitwarden, con sus campos personalizados y sus códigos de autenticación en dos pasos.
- Los inicios de sesión, las tarjetas y las notas seguras se pueden editar en Submarine. Los demás tipos se conservan y se muestran, pero todavía no se pueden editar.
- Las claves de acceso se conservan y se muestran, pero Submarine todavía no puede iniciar sesión con ellas.
- Las carpetas no se importan: Submarine separa los elementos por caja fuerte.
- Los archivos adjuntos no forman parte de la exportación de Bitwarden, así que se quedan en Bitwarden.

## Si vienes de otro gestor de contraseñas

Submarine solo lee el formato de Bitwarden. Bitwarden, en cambio, importa desde la mayoría de los gestores de contraseñas, como 1Password, LastPass, KeePass o tu navegador. Con una cuenta gratuita de Bitwarden, importa primero allí tus contraseñas y luego sigue los pasos anteriores.

## Dejar Submarine

Submarine exporta en el mismo formato. En **Ajustes**, luego **Importar y exportar**, **Exportar caja fuerte** guarda un archivo de Bitwarden, protegido con contraseña o sin cifrar, que Bitwarden y otros gestores de contraseñas pueden importar. La papelera no se incluye.

¿Eres nuevo en Submarine? [Descárgalo](/es/download) o lee [cómo protege tus contraseñas](/es/security).
