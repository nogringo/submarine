// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get allVaults => 'Todas las cajas fuertes';

  @override
  String get vaults => 'Cajas fuertes';

  @override
  String get addVault => 'Añadir caja fuerte';

  @override
  String get createVault => 'Crear caja fuerte';

  @override
  String get createVaultDescription =>
      'Una caja fuerte nueva y vacía, con su propia clave.';

  @override
  String get openVault => 'Abrir caja fuerte';

  @override
  String get openVaultDescription =>
      'Desde otro dispositivo o compartida contigo.';

  @override
  String get openVaultTitle => 'Abrir caja fuerte';

  @override
  String get vaultName => 'Nombre';

  @override
  String get vaultNameHelper =>
      'Solo en este dispositivo. Si compartes la caja fuerte, cada persona le pone su propio nombre.';

  @override
  String get vaultNameRequired => 'Ponle un nombre a la caja fuerte.';

  @override
  String get vaultColor => 'Color';

  @override
  String get vaultColorBlue => 'Azul';

  @override
  String get vaultColorOrange => 'Naranja';

  @override
  String get vaultColorGreen => 'Verde';

  @override
  String get vaultColorPurple => 'Morado';

  @override
  String get vaultColorPink => 'Rosa';

  @override
  String get vaultColorGray => 'Gris';

  @override
  String get vaultKey => 'Clave de la caja fuerte';

  @override
  String get vaultKeyInvalid => 'Esto no es una clave de caja fuerte.';

  @override
  String vaultAlreadyOpen(String name) {
    return 'Esta caja fuerte ya está abierta, con el nombre $name.';
  }

  @override
  String get vaultSaveFailed =>
      'No se pudo guardar la caja fuerte en este dispositivo.';

  @override
  String get saveVaultKeyTitle => 'Guarda la clave de la caja fuerte';

  @override
  String get saveVaultKeyBody =>
      'Cualquiera que tenga esta clave puede abrir la caja fuerte. Guárdala en un lugar seguro: la necesitarás para abrir la caja fuerte en otro dispositivo o para compartirla.';

  @override
  String get vaultSettings => 'Ajustes de la caja fuerte';

  @override
  String get vaultNameAndColor => 'Nombre y color';

  @override
  String get vaultPublicKey => 'Clave pública';

  @override
  String get vaultKeyDescription =>
      'Cualquiera que la tenga puede abrir esta caja fuerte. Introdúcela en otro dispositivo para abrirla allí, o dásela a alguien para compartir la caja fuerte.';

  @override
  String get vaultKeyHelper =>
      'La clave que guardaste al crear la caja fuerte o que compartieron contigo.';

  @override
  String get vaultKeyPassword => 'Contraseña de la clave';

  @override
  String get vaultKeyPasswordWrong => 'Esta contraseña no abre la clave.';

  @override
  String get vaultKeyDecrypting => 'Descifrando la clave';

  @override
  String get otherWaysToOpen => 'Otras formas de abrirla';

  @override
  String get signersDescription =>
      'Con un firmante que guarda la clave fuera de Submarine. También puedes pegar una dirección bunker:// en el campo de la clave.';

  @override
  String get browserExtension => 'Extensión del navegador';

  @override
  String get signerApp => 'App de firma';

  @override
  String get bunker => 'Bunker';

  @override
  String get nostrConnect => 'Nostr Connect';

  @override
  String get nostrConnectBody =>
      'Escanea este código con tu bunker o tu app de firma, o pega allí la dirección.';

  @override
  String get noBrowserExtension =>
      'No hay ninguna extensión de Nostr en este navegador.';

  @override
  String get noSignerApp =>
      'No hay ninguna app de firma, como Amber, en este dispositivo.';

  @override
  String get signerRefused => 'Se rechazó la solicitud.';

  @override
  String get waitingForAnswer => 'Esperando una respuesta';

  @override
  String get bunkerUrlInvalid =>
      'A esta dirección de bunker le falta un relay o un secreto.';

  @override
  String get bunkerNoAnswer => 'El bunker no respondió.';

  @override
  String get bunkerApproval =>
      'El bunker te pide que apruebes Submarine en su página.';

  @override
  String get openApprovalPage => 'Abrir la página';

  @override
  String get nothingConnected => 'No se conectó nada a tiempo.';

  @override
  String get useAnotherKey => 'Usar otra clave';

  @override
  String get vaultSignerDescription =>
      'Guarda la clave de la caja fuerte, que nunca entra en Submarine. En otro dispositivo, abre la caja fuerte de la misma forma.';

  @override
  String get askSignerAtStart => 'Preguntar al firmante en cada inicio';

  @override
  String get askSignerAtStartDescription =>
      'Si está desactivado, una clave guardada en este dispositivo lee la caja fuerte aunque el firmante no esté disponible. Si está activado, la caja fuerte sigue cerrada hasta que el firmante la abra.';

  @override
  String get askSignerFailed => 'El firmante se negó o falló.';

  @override
  String signerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count solicitudes pendientes en tu firmante',
      one: '1 solicitud pendiente en tu firmante',
    );
    return '$_temp0';
  }

  @override
  String get signerRequestsTitle => 'Esperando a tu firmante';

  @override
  String get signerRequestsDescription =>
      'Aprueba estas solicitudes en tu firmante o cancélalas.';

  @override
  String get requestOpenVault => 'Abrir la caja fuerte';

  @override
  String get requestLockVault => 'Bloquear la caja fuerte con el firmante';

  @override
  String requestDecryptVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Descifrar $count versiones de elementos',
      one: 'Descifrar una versión de un elemento',
    );
    return '$_temp0';
  }

  @override
  String requestSaveVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardar $count versiones de elementos',
      one: 'Guardar una versión de un elemento',
    );
    return '$_temp0';
  }

  @override
  String requestDeleteVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar permanentemente $count versiones de elementos',
      one: 'Eliminar permanentemente una versión de un elemento',
    );
    return '$_temp0';
  }

  @override
  String get requestSaveRelays => 'Guardar la lista de relays';

  @override
  String get requestReadRelays => 'Leer los relays privados';

  @override
  String get requestEncryptRelays => 'Cifrar los relays privados';

  @override
  String requestRelayAuth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Autenticarse en $count relays',
      one: 'Autenticarse en un relay',
    );
    return '$_temp0';
  }

  @override
  String requestOther(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count solicitudes más ($method)',
      one: 'Otra solicitud ($method)',
    );
    return '$_temp0';
  }

  @override
  String get cancelAll => 'Cancelar todo';

  @override
  String get close => 'Cerrar';

  @override
  String get sync => 'Sincronización';

  @override
  String get syncAllSent => 'Todos los cambios están guardados en línea.';

  @override
  String get relays => 'Relays';

  @override
  String get relaysDescription =>
      'Esta caja fuerte se copia en cada uno de estos relays. Solo ven datos cifrados y la clave pública de la caja fuerte.';

  @override
  String get relayConnected => 'Conectado';

  @override
  String get relayNotConnected => 'Sin conexión';

  @override
  String get relayPrivate => 'Privado';

  @override
  String get removeRelay => 'Quitar este relay';

  @override
  String get addRelay => 'Añadir relay';

  @override
  String get relayAddress => 'Dirección del relay';

  @override
  String get relayAddressInvalid => 'Esto no es una dirección de relay.';

  @override
  String get relayAlreadyListed => 'Este relay ya está en la lista.';

  @override
  String get relayKeepPrivate => 'Mantener privado';

  @override
  String get relayKeepPrivateDescription =>
      'Cifrado en la lista de relays de la caja fuerte: solo quienes tienen su clave saben que la caja fuerte está en él.';

  @override
  String get relaysSaveFailed => 'No se pudieron guardar los relays.';

  @override
  String get relaysWaitForSync =>
      'Podrás cambiar los relays cuando la caja fuerte se haya sincronizado.';

  @override
  String get relayAdded => 'Nuevo';

  @override
  String get relayRemoved => 'Quitado';

  @override
  String get keepRelay => 'Conservar este relay';

  @override
  String get relaysNeedOne => 'La caja fuerte necesita al menos un relay.';

  @override
  String get fileServers => 'Servidores de archivos';

  @override
  String get fileServersDescription =>
      'Los archivos adjuntos a esta caja fuerte se copian en cada uno de estos servidores. Solo ven archivos cifrados.';

  @override
  String relaysConnected(int connected, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      connected,
      locale: localeName,
      other: '$connected de $count conectados',
      one: '1 de $count conectado',
    );
    return '$_temp0';
  }

  @override
  String fileServerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servidores',
      one: '1 servidor',
    );
    return '$_temp0';
  }

  @override
  String relayLeftOut(String reason) {
    return 'Sin sincronizar: $reason';
  }

  @override
  String get fullSync => 'Sincronización completa';

  @override
  String get fullSyncDescription =>
      'Lee toda la caja fuerte en cada relay y luego le da a cada uno lo que le falta, como lo que perdió con el tiempo.';

  @override
  String get fullSyncStart => 'Iniciar';

  @override
  String get fullSyncDone => 'Cada relay tiene toda la caja fuerte.';

  @override
  String fullSyncLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relays siguen sin sincronizar.',
      one: '1 relay sigue sin sincronizar.',
    );
    return '$_temp0';
  }

  @override
  String get fullSyncFailed => 'La sincronización completa no pudo terminar.';

  @override
  String get serverPrivate => 'Privado';

  @override
  String get removeServer => 'Quitar este servidor';

  @override
  String get keepServer => 'Conservar este servidor';

  @override
  String get addServer => 'Añadir servidor';

  @override
  String get serverAddress => 'Dirección del servidor';

  @override
  String get serverAddressInvalid => 'Esto no es una dirección de servidor.';

  @override
  String get serverAlreadyListed => 'Este servidor ya está en la lista.';

  @override
  String get serverKeepPrivate => 'Mantener privado';

  @override
  String get serverKeepPrivateDescription =>
      'Cifrado en la lista de servidores de la caja fuerte: solo quienes tienen su clave saben que la caja fuerte lo usa.';

  @override
  String get serversSaveFailed => 'No se pudieron guardar los servidores.';

  @override
  String get serversWaitForSync =>
      'Podrás cambiar los servidores cuando la caja fuerte se haya sincronizado.';

  @override
  String get serverAdded => 'Nuevo';

  @override
  String get serverRemoved => 'Quitado';

  @override
  String get serversNeedOne => 'La caja fuerte necesita al menos un servidor.';

  @override
  String get add => 'Añadir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Crear';

  @override
  String get open => 'Abrir';

  @override
  String get done => 'Listo';

  @override
  String get welcomeTagline =>
      'Tus contraseñas, cifradas y sincronizadas. Sin necesidad de cuenta.';

  @override
  String get builtOnNostr => 'Basado en Nostr';

  @override
  String get builtOnNostrBody =>
      'Tus cajas fuertes se guardan en relays de Nostr: servidores abiertos que cualquiera puede poner en marcha y que solo ven datos cifrados. La clave de una caja fuerte es una clave de Nostr, así que un firmante de Nostr puede guardarla.';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
      zero: 'Sin elementos',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get syncing => 'Sincronizando';

  @override
  String get syncNever => 'Nunca sincronizada';

  @override
  String get syncFailed => 'No se pudo sincronizar';

  @override
  String get signerDidNotOpen => 'El firmante no abrió la caja fuerte';

  @override
  String get syncedJustNow => 'Sincronizada hace un momento';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Sincronizada hace $minutes min';
  }

  @override
  String syncedHoursAgo(int hours) {
    return 'Sincronizada hace $hours h';
  }

  @override
  String syncedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Sincronizada el $dateString';
  }

  @override
  String get noItems => 'Todavía no hay elementos en esta caja fuerte.';

  @override
  String get lookingForItems => 'Buscando tus elementos';

  @override
  String get signerDidNotOpenVault =>
      'El firmante no abrió esta caja fuerte. Sincroniza para volver a pedírselo.';

  @override
  String get selectItem => 'Selecciona un elemento para verlo aquí.';

  @override
  String get itemNotFound => 'Este elemento ya no está en la caja fuerte.';

  @override
  String get typeLogin => 'Inicio de sesión';

  @override
  String get typeSecureNote => 'Nota segura';

  @override
  String get typeCard => 'Tarjeta';

  @override
  String get typeIdentity => 'Identidad';

  @override
  String get typeSshKey => 'Clave SSH';

  @override
  String get typeBankAccount => 'Cuenta bancaria';

  @override
  String get typeDriversLicense => 'Licencia de conducir';

  @override
  String get typePassport => 'Pasaporte';

  @override
  String get typeUnknown => 'Elemento';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get hiddenValue => 'Valor oculto';

  @override
  String get openWebsite => 'Abrir página web';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get verificationCode => 'Código de verificación';

  @override
  String get totpInvalid => 'No se puede leer esta clave de verificación.';

  @override
  String get website => 'Página web';

  @override
  String get passkey => 'Clave de acceso';

  @override
  String passkeyCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Creada el $dateString';
  }

  @override
  String get notes => 'Notas';

  @override
  String get customFields => 'Campos personalizados';

  @override
  String get passwordHistory => 'Historial de contraseñas';

  @override
  String itemDates(DateTime updated, DateTime created) {
    final intl.DateFormat updatedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String updatedString = updatedDateFormat.format(updated);
    final intl.DateFormat createdDateFormat = intl.DateFormat.yMMMd(localeName);
    final String createdString = createdDateFormat.format(created);

    return 'Actualizado el $updatedString, creado el $createdString';
  }

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String linkedTo(String field) {
    return 'Vinculado a $field';
  }

  @override
  String get cardholderName => 'Nombre en la tarjeta';

  @override
  String get cardBrand => 'Marca';

  @override
  String get cardNumber => 'Número';

  @override
  String get cardExpiration => 'Expiración';

  @override
  String get cardExpMonth => 'Mes de expiración';

  @override
  String get cardExpYear => 'Año de expiración';

  @override
  String get cardCode => 'Código de seguridad';

  @override
  String get fullName => 'Nombre';

  @override
  String get identityTitle => 'Tratamiento';

  @override
  String get firstName => 'Nombre';

  @override
  String get middleName => 'Segundo nombre';

  @override
  String get lastName => 'Apellido';

  @override
  String get company => 'Empresa';

  @override
  String get email => 'Correo electrónico';

  @override
  String get phone => 'Teléfono';

  @override
  String get address => 'Dirección';

  @override
  String get city => 'Ciudad';

  @override
  String get state => 'Estado o provincia';

  @override
  String get postalCode => 'Código postal';

  @override
  String get country => 'País';

  @override
  String get ssn => 'Número de seguridad social';

  @override
  String get passportNumber => 'Número de pasaporte';

  @override
  String get licenseNumber => 'Número de licencia';

  @override
  String get privateKey => 'Clave privada';

  @override
  String get publicKey => 'Clave pública';

  @override
  String get fingerprint => 'Huella digital';

  @override
  String get bankName => 'Banco';

  @override
  String get accountHolder => 'Titular de la cuenta';

  @override
  String get accountType => 'Tipo de cuenta';

  @override
  String get accountNumber => 'Número de cuenta';

  @override
  String get routingNumber => 'Número de ruta bancaria';

  @override
  String get branchNumber => 'Número de sucursal';

  @override
  String get pin => 'PIN';

  @override
  String get swiftCode => 'Código SWIFT';

  @override
  String get iban => 'IBAN';

  @override
  String get bankPhone => 'Teléfono del banco';

  @override
  String get accountTypeChecking => 'Cuenta corriente';

  @override
  String get accountTypeSavings => 'Cuenta de ahorro';

  @override
  String get accountTypeCertificateOfDeposit => 'Depósito a plazo';

  @override
  String get accountTypeLineOfCredit => 'Línea de crédito';

  @override
  String get accountTypeInvestmentBrokerage => 'Cuenta de inversión';

  @override
  String get accountTypeMoneyMarket => 'Mercado monetario';

  @override
  String get accountTypeOther => 'Otro';

  @override
  String get dateOfBirth => 'Fecha de nacimiento';

  @override
  String get issuingCountry => 'País de expedición';

  @override
  String get issuingState => 'Región de expedición';

  @override
  String get issueDate => 'Fecha de expedición';

  @override
  String get expirationDate => 'Fecha de expiración';

  @override
  String get issuingAuthority => 'Autoridad emisora';

  @override
  String get licenseClass => 'Clase';

  @override
  String get surname => 'Apellidos';

  @override
  String get givenName => 'Nombre';

  @override
  String get sex => 'Sexo';

  @override
  String get birthPlace => 'Lugar de nacimiento';

  @override
  String get nationality => 'Nacionalidad';

  @override
  String get passportType => 'Tipo';

  @override
  String get nationalId => 'Número de identificación nacional';

  @override
  String get filterAllItems => 'Todos los elementos';

  @override
  String get filterAllShort => 'Todos';

  @override
  String get filterFavorites => 'Favoritos';

  @override
  String get filterLogins => 'Inicios de sesión';

  @override
  String get filterSecureNotes => 'Notas seguras';

  @override
  String get filterCards => 'Tarjetas';

  @override
  String get filterIdentities => 'Identidades';

  @override
  String get filterSshKeys => 'Claves SSH';

  @override
  String get filterBankAccounts => 'Cuentas bancarias';

  @override
  String get filterDriversLicenses => 'Licencias de conducir';

  @override
  String get filterPassports => 'Pasaportes';

  @override
  String get filterTrash => 'Papelera';

  @override
  String get noItemsHere => 'No hay elementos aquí.';

  @override
  String get searchItems => 'Buscar';

  @override
  String get clearSearch => 'Borrar la búsqueda';

  @override
  String get noSearchResults => 'Ningún elemento coincide con tu búsqueda.';

  @override
  String changesNotSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios aún sin enviar',
      one: '1 cambio aún sin enviar',
    );
    return '$_temp0';
  }

  @override
  String get newItem => 'Nuevo elemento';

  @override
  String get newLogin => 'Nuevo inicio de sesión';

  @override
  String get newCard => 'Nueva tarjeta';

  @override
  String get newSecureNote => 'Nueva nota segura';

  @override
  String get editItem => 'Editar elemento';

  @override
  String get edit => 'Editar';

  @override
  String get save => 'Guardar';

  @override
  String get itemSaveFailed => 'No se pudo guardar el elemento.';

  @override
  String get vault => 'Caja fuerte';

  @override
  String get itemName => 'Nombre';

  @override
  String get itemNameRequired => 'Ponle un nombre al elemento.';

  @override
  String get authenticatorKey => 'Clave de autenticación';

  @override
  String get authenticatorKeyHint => 'Secreto Base32 o URI otpauth://';

  @override
  String get addWebsite => 'Añadir página web';

  @override
  String get addField => 'Añadir campo';

  @override
  String get customField => 'Campo personalizado';

  @override
  String get editField => 'Editar campo';

  @override
  String get fieldType => 'Tipo de campo';

  @override
  String get fieldTypeText => 'Texto';

  @override
  String get fieldTypeHidden => 'Oculto';

  @override
  String get fieldTypeCheckbox => 'Casilla de verificación';

  @override
  String get fieldTypeLinked => 'Vinculado';

  @override
  String get textFieldHelp =>
      'Usa campos de texto para datos como preguntas de seguridad.';

  @override
  String get hiddenFieldHelp =>
      'Usa campos ocultos para datos sensibles como una contraseña.';

  @override
  String get checkboxFieldHelp =>
      'Usa casillas de verificación para marcar la casilla de un formulario, como recordar mi correo.';

  @override
  String get linkedFieldHelp =>
      'Usa un campo vinculado cuando el autocompletado tenga problemas con una página web concreta.';

  @override
  String get fieldLabel => 'Etiqueta del campo';

  @override
  String get linkedFieldLabelHelp =>
      'Introduce el id HTML, el name, el aria-label o el placeholder del campo.';

  @override
  String editFieldNamed(String field) {
    return 'Editar $field';
  }

  @override
  String deleteFieldNamed(String field) {
    return 'Eliminar $field';
  }

  @override
  String reorderField(String field) {
    return 'Mover $field';
  }

  @override
  String get cardBrandOther => 'Otra';

  @override
  String get cardExpYearHint => 'AAAA';

  @override
  String get notSet => 'Sin especificar';

  @override
  String get favorite => 'Favorito';

  @override
  String get addToFavorites => 'Añadir a favoritos';

  @override
  String get removeFromFavorites => 'Quitar de favoritos';

  @override
  String get discardChanges => '¿Descartar los cambios?';

  @override
  String get keepEditing => 'Seguir editando';

  @override
  String get discard => 'Descartar';

  @override
  String get moreActions => 'Más acciones';

  @override
  String get copyUsername => 'Copiar nombre de usuario';

  @override
  String get copyPassword => 'Copiar contraseña';

  @override
  String get copyTotp => 'Copiar código de verificación';

  @override
  String get copyNumber => 'Copiar número';

  @override
  String get moveToTrash => 'Mover a la papelera';

  @override
  String get restore => 'Restaurar';

  @override
  String get deletePermanently => 'Eliminar permanentemente';

  @override
  String get deleteItemTitle => '¿Eliminar permanentemente este elemento?';

  @override
  String get deleteItemBody =>
      'Se borrará de la caja fuerte en todos los dispositivos. Esta acción no se puede deshacer.';

  @override
  String get delete => 'Eliminar';

  @override
  String get generatePassword => 'Generar contraseña';

  @override
  String get generateUsername => 'Generar nombre de usuario';

  @override
  String get generator => 'Generador';

  @override
  String get passphrase => 'Frase de contraseña';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get passwordLength => 'Longitud';

  @override
  String characterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caracteres',
      one: '1 carácter',
    );
    return '$_temp0';
  }

  @override
  String get includeCharacters => 'Incluir';

  @override
  String get uppercaseLetters => 'Letras mayúsculas';

  @override
  String get lowercaseLetters => 'Letras minúsculas';

  @override
  String get digits => 'Números';

  @override
  String get specialCharacters => 'Caracteres especiales';

  @override
  String get minNumbers => 'Mínimo de números';

  @override
  String get minSpecial => 'Mínimo de caracteres especiales';

  @override
  String get avoidAmbiguous => 'Evitar caracteres ambiguos';

  @override
  String get numberOfWords => 'Número de palabras';

  @override
  String get wordSeparator => 'Separador de palabras';

  @override
  String get capitalize => 'Iniciales en mayúscula';

  @override
  String get includeNumber => 'Incluir un número';

  @override
  String get usePassword => 'Usar esta contraseña';

  @override
  String get usePassphrase => 'Usar esta frase de contraseña';

  @override
  String get useUsername => 'Usar este nombre de usuario';

  @override
  String get usernameCapitalize => 'Empezar con mayúscula';

  @override
  String get usernameIncludeNumber => 'Incluir un número';

  @override
  String get decrease => 'Disminuir';

  @override
  String get increase => 'Aumentar';

  @override
  String get settings => 'Ajustes';

  @override
  String get security => 'Seguridad';

  @override
  String get unlockWithBiometrics => 'Desbloquear con biometría';

  @override
  String get unlockWithBiometricsDescription =>
      'O con el código o la contraseña de este dispositivo. Las claves de las cajas fuertes se quedan en su almacenamiento seguro.';

  @override
  String get lockNeedsScreenLock =>
      'Primero configura un bloqueo de pantalla en este dispositivo.';

  @override
  String get lockAfter => 'Bloquear después de';

  @override
  String get lockImmediately => 'Inmediatamente';

  @override
  String get lockOnRestart => 'Al reiniciar la app';

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String get clearClipboardAfter =>
      'Borrar las contraseñas copiadas después de';

  @override
  String get never => 'Nunca';

  @override
  String seconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segundos',
      one: '1 segundo',
    );
    return '$_temp0';
  }

  @override
  String get allowScreenCapture => 'Permitir capturas de pantalla';

  @override
  String get allowScreenCaptureDescription =>
      'Las capturas de pantalla, las grabaciones y la pantalla compartida podrán mostrar tus contraseñas.';

  @override
  String get lock => 'Bloquear';

  @override
  String lockWithShortcut(String shortcut) {
    return 'Bloquear ($shortcut)';
  }

  @override
  String get unlock => 'Desbloquear';

  @override
  String get vaultsLocked => 'Tus cajas fuertes están bloqueadas.';

  @override
  String get unlockReason => 'Desbloquear tus cajas fuertes';

  @override
  String get enableLockReason => 'Activar el bloqueo';

  @override
  String get authLockedOut => 'Demasiados intentos. Inténtalo más tarde.';

  @override
  String get authFailed => 'Este dispositivo no pudo comprobar que eres tú.';

  @override
  String get vaultTab => 'Caja fuerte';

  @override
  String get storageReadFailed => 'No se pudieron leer tus cajas fuertes.';

  @override
  String get storageReadFailedBody =>
      'El almacenamiento seguro de este dispositivo se negó a abrirlas. No se borró nada: inténtalo de nuevo. Tus elementos siguen en línea y la clave de una caja fuerte la abre en cualquier dispositivo.';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get appearance => 'Apariencia';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageName => 'Español';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get importExport => 'Importar y exportar';

  @override
  String get importFromBitwarden => 'Importar desde Bitwarden';

  @override
  String get importFromBitwardenDescription =>
      'Una exportación JSON de Bitwarden.';

  @override
  String get importButton => 'Importar';

  @override
  String get importReadFailed => 'No se pudo leer el archivo.';

  @override
  String get importNotBitwarden =>
      'Este archivo no es una exportación JSON de Bitwarden.';

  @override
  String get importEncrypted =>
      'Esta exportación está restringida a tu cuenta de Bitwarden y solo Bitwarden puede abrirla. Vuelve a exportar tu caja fuerte desde Bitwarden, protegida con contraseña o en formato .json.';

  @override
  String get importEmpty => 'Esta exportación no tiene elementos.';

  @override
  String importFound(int count, String file) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos encontrados en $file.',
      one: '1 elemento encontrado en $file.',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return '$done de $total elementos importados';
  }

  @override
  String importDone(int count, String vault) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos importados en $vault.',
      one: '1 elemento importado en $vault.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(int done, int total) {
    return 'La importación se detuvo: se guardaron $done de $total elementos.';
  }

  @override
  String get exportVault => 'Exportar caja fuerte';

  @override
  String get exportVaultDescription =>
      'Un archivo JSON de Bitwarden, protegido con contraseña o sin cifrar.';

  @override
  String get exportButton => 'Exportar';

  @override
  String exportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos. La papelera no se incluye.',
      one: '1 elemento. La papelera no se incluye.',
      zero: 'Esta caja fuerte no tiene elementos que exportar.',
    );
    return '$_temp0';
  }

  @override
  String get exportWarning =>
      'El archivo no está cifrado. No lo envíes por correo electrónico y elimínalo cuando ya no lo necesites.';

  @override
  String get exportFailed => 'No se pudo guardar el archivo.';

  @override
  String get importPasswordBody =>
      'Esta exportación está protegida con contraseña. Introdúcela para abrir el archivo.';

  @override
  String get filePassword => 'Contraseña del archivo';

  @override
  String get wrongFilePassword => 'Esta contraseña no abre el archivo.';

  @override
  String get exportProtect => 'Proteger con contraseña';

  @override
  String get confirmFilePassword => 'Confirmar contraseña del archivo';

  @override
  String get filePasswordHelper =>
      'Submarine y Bitwarden la piden para importar el archivo. No se puede recuperar.';

  @override
  String get filePasswordRequired => 'Elige una contraseña.';

  @override
  String get filePasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get lockPassword => 'Contraseña de bloqueo';

  @override
  String get lockPasswordDescription =>
      'Cifra las claves de las cajas fuertes en este dispositivo y desbloquea la app. No se puede recuperar.';

  @override
  String get setLockPassword => 'Configurar';

  @override
  String get changeLockPassword => 'Cambiar';

  @override
  String get removeLockPassword => 'Quitar';

  @override
  String get setLockPasswordTitle => 'Establecer contraseña de bloqueo';

  @override
  String get changeLockPasswordTitle => 'Cambiar la contraseña de bloqueo';

  @override
  String get removeLockPasswordTitle => 'Quitar la contraseña de bloqueo';

  @override
  String get removeLockPasswordBody =>
      'La app dejará de pedirla. Las claves de las cajas fuertes de este dispositivo quedarán protegidas solo por su almacenamiento seguro.';

  @override
  String get currentLockPassword => 'Contraseña actual';

  @override
  String get newLockPassword => 'Nueva contraseña';

  @override
  String get confirmLockPassword => 'Confirmar contraseña';

  @override
  String lockPasswordHelper(int count) {
    return 'Al menos $count caracteres. Si la olvidas, las cajas fuertes se quitarán de este dispositivo.';
  }

  @override
  String lockPasswordTooShort(int count) {
    return 'Al menos $count caracteres.';
  }

  @override
  String get lockPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get wrongLockPassword => 'Esta no es la contraseña de bloqueo.';

  @override
  String get generatePassphrase => 'Generar frase de contraseña';

  @override
  String get unlockWithBiometricsWithPassword =>
      'En lugar de escribir la contraseña de bloqueo, que sigue funcionando.';

  @override
  String get forgotLockPassword => '¿Olvidaste la contraseña?';

  @override
  String get forgetVaultsTitle =>
      '¿Quitar las cajas fuertes de este dispositivo?';

  @override
  String get forgetVaultsBody =>
      'Sin la contraseña de bloqueo, no se pueden descifrar aquí. Tus elementos siguen en línea: vuelve a abrir cada caja fuerte con su clave.';

  @override
  String get forgetVaults => 'Quitar las cajas fuertes';

  @override
  String get removeVault => 'Quitar de este dispositivo';

  @override
  String get removeVaultDescription =>
      'La caja fuerte sigue en línea, para que puedas volver a abrirla.';

  @override
  String removeVaultTitle(String name) {
    return '¿Quitar $name de este dispositivo?';
  }

  @override
  String get removeVaultBody =>
      'Tus elementos siguen en línea: vuelve a abrir la caja fuerte para encontrarlos.';

  @override
  String get removeVaultKeyWarning =>
      'Guarda primero su clave: sin ella, no podrás volver a abrir la caja fuerte.';

  @override
  String removeVaultUnsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios aún no se han enviado y se perderán.',
      one: '1 cambio aún no se ha enviado y se perderá.',
    );
    return '$_temp0';
  }

  @override
  String get removeVaultConfirm => 'Quitar';

  @override
  String get removeVaultFailed => 'No se pudo quitar la caja fuerte.';

  @override
  String get emailSettings => 'Correo electrónico';

  @override
  String get mailBridge => 'Puente de correo';

  @override
  String mailBridgeDescription(String domain) {
    return 'Las nuevas direcciones de correo terminan en @$domain';
  }

  @override
  String get changeMailBridge => 'Cambiar';

  @override
  String get mailBridgeDomain => 'Dominio';

  @override
  String get mailBridgeExplanation =>
      'Las direcciones de correo creadas a partir de ahora terminan en este dominio. Las creadas antes conservan el suyo.';

  @override
  String get mailBridgeInvalid => 'Esto no es un dominio.';

  @override
  String get emailAddressField => 'Dirección de correo';

  @override
  String get mailboxKey => 'Clave del buzón';

  @override
  String get inbox => 'Bandeja de entrada';

  @override
  String get inboxFetching => 'Obteniendo mensajes';

  @override
  String get inboxEmpty => 'Aún no hay mensajes';

  @override
  String get noSubject => '(sin asunto)';

  @override
  String get privateMessage => 'Mensaje privado';

  @override
  String get emailDownloadFailed => 'No se pudo descargar este correo.';

  @override
  String get refreshInbox => 'Actualizar';

  @override
  String get mailInboxRelays => 'Relays de recepción';

  @override
  String get mailInboxRelaysExplanation =>
      'Los correos enviados a las nuevas direcciones llegan a estos relays. Las direcciones creadas antes conservan los suyos.';

  @override
  String get mailAddressRelays => 'Relays de la dirección';

  @override
  String get mailAddressRelaysExplanation =>
      'Las nuevas direcciones publican sus relays de recepción en estos relays, donde el puente los encuentra. Las direcciones creadas antes conservan los suyos.';

  @override
  String get changeMailRelays => 'Cambiar';

  @override
  String get mailRelaysNeedOne =>
      'Las nuevas direcciones necesitan al menos un relay.';

  @override
  String get resetMailRelays => 'Restablecer';

  @override
  String get mailServers => 'Servidores de correos grandes';

  @override
  String get mailServersExplanation =>
      'Las nuevas direcciones reciben en estos servidores, cifrados, los correos demasiado grandes para un relay. Las direcciones creadas antes conservan los suyos.';

  @override
  String get mailServersNeedOne =>
      'Las nuevas direcciones necesitan al menos un servidor.';
}
