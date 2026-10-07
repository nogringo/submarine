// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get allVaults => 'Todos os cofres';

  @override
  String get vaults => 'Cofres';

  @override
  String get addVault => 'Adicionar um cofre';

  @override
  String get createVault => 'Criar um cofre';

  @override
  String get createVaultDescription =>
      'Um cofre novo e vazio, com a sua própria chave.';

  @override
  String get openVault => 'Abrir um cofre';

  @override
  String get openVaultDescription =>
      'De outro dispositivo, ou partilhado consigo.';

  @override
  String get openVaultTitle => 'Abrir um cofre';

  @override
  String get vaultName => 'Nome';

  @override
  String get vaultNameHelper =>
      'Só neste dispositivo. Cada pessoa com quem partilha o cofre dá-lhe o nome que quiser.';

  @override
  String get vaultNameRequired => 'Dê um nome ao cofre.';

  @override
  String get vaultColor => 'Cor';

  @override
  String vaultColorOption(int number) {
    return 'Cor $number';
  }

  @override
  String get vaultKey => 'Chave do cofre';

  @override
  String get vaultKeyInvalid => 'Isto não é uma chave de cofre.';

  @override
  String vaultAlreadyOpen(String name) {
    return 'Este cofre já está aberto, com o nome $name.';
  }

  @override
  String get vaultSaveFailed =>
      'Não foi possível guardar o cofre neste dispositivo.';

  @override
  String get saveVaultKeyTitle => 'Guarde a chave do cofre';

  @override
  String get saveVaultKeyBody =>
      'Quem tiver esta chave pode abrir o cofre. Guarde-a num local seguro: precisa dela para abrir o cofre noutro dispositivo, ou para o partilhar.';

  @override
  String get vaultSettings => 'Definições do cofre';

  @override
  String get vaultNameAndColor => 'Nome e cor';

  @override
  String get vaultPublicKey => 'Chave pública';

  @override
  String get vaultKeyDescription =>
      'Quem a tiver pode abrir este cofre. Introduza-a noutro dispositivo para lá abrir o cofre, ou dê-a a alguém para partilhar o cofre com essa pessoa.';

  @override
  String get vaultKeyHelper =>
      'A chave guardada ao criar o cofre, ou partilhada consigo.';

  @override
  String get vaultKeyPassword => 'Palavra-passe da chave';

  @override
  String get vaultKeyPasswordWrong => 'Esta palavra-passe não abre a chave.';

  @override
  String get vaultKeyDecrypting => 'A desencriptar a chave';

  @override
  String get otherWaysToOpen => 'Outras formas de o abrir';

  @override
  String get signersDescription =>
      'Com um assinante que guarda a chave fora do Submarine. Também pode colar um endereço bunker:// no campo da chave.';

  @override
  String get browserExtension => 'Extensão do navegador';

  @override
  String get signerApp => 'Aplicação de assinatura';

  @override
  String get bunker => 'Bunker';

  @override
  String get nostrConnect => 'Nostr Connect';

  @override
  String get nostrConnectBody =>
      'Digitalize este código com o seu bunker ou aplicação de assinatura, ou cole lá o endereço.';

  @override
  String get noBrowserExtension => 'Nenhuma extensão Nostr neste navegador.';

  @override
  String get noSignerApp =>
      'Nenhuma aplicação de assinatura, como o Amber, neste dispositivo.';

  @override
  String get signerRefused => 'O pedido foi recusado.';

  @override
  String get waitingForAnswer => 'A aguardar resposta';

  @override
  String get bunkerUrlInvalid =>
      'Falta um relay ou um segredo a este endereço de bunker.';

  @override
  String get bunkerNoAnswer => 'O bunker não respondeu.';

  @override
  String get bunkerApproval =>
      'O bunker pede-lhe que aprove o Submarine na página dele.';

  @override
  String get openApprovalPage => 'Abrir a página';

  @override
  String get nothingConnected => 'Nada se ligou a tempo.';

  @override
  String get useAnotherKey => 'Utilizar outra chave';

  @override
  String get vaultSignerDescription =>
      'Guarda a chave do cofre, que nunca entra no Submarine. Noutro dispositivo, abra o cofre da mesma forma.';

  @override
  String get askSignerAtStart => 'Pedir ao assinante em cada arranque';

  @override
  String get askSignerAtStartDescription =>
      'Desativado: uma chave guardada neste dispositivo lê o cofre mesmo com o assinante inacessível. Ativado: o cofre fica fechado até o assinante o abrir.';

  @override
  String get askSignerFailed => 'O assinante recusou ou falhou.';

  @override
  String signerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos aguardam o seu assinante',
      one: '1 pedido aguarda o seu assinante',
    );
    return '$_temp0';
  }

  @override
  String get signerRequestsTitle => 'A aguardar o seu assinante';

  @override
  String get signerRequestsDescription =>
      'Aprove estes pedidos no seu assinante, ou cancele-os.';

  @override
  String get requestOpenVault => 'Abrir o cofre';

  @override
  String get requestLockVault => 'Bloquear o cofre com o assinante';

  @override
  String requestDecryptVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Desencriptar $count versões de itens',
      one: 'Desencriptar uma versão de um item',
    );
    return '$_temp0';
  }

  @override
  String requestSaveVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardar $count versões de itens',
      one: 'Guardar uma versão de um item',
    );
    return '$_temp0';
  }

  @override
  String requestDeleteVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar permanentemente $count versões de itens',
      one: 'Eliminar permanentemente uma versão de um item',
    );
    return '$_temp0';
  }

  @override
  String get requestSaveRelays => 'Guardar a lista de relays';

  @override
  String get requestReadRelays => 'Ler os relays privados';

  @override
  String get requestEncryptRelays => 'Encriptar os relays privados';

  @override
  String requestRelayAuth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Iniciar sessão em $count relays',
      one: 'Iniciar sessão num relay',
    );
    return '$_temp0';
  }

  @override
  String requestOther(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outros pedidos ($method)',
      one: 'Outro pedido ($method)',
    );
    return '$_temp0';
  }

  @override
  String get cancelAll => 'Cancelar tudo';

  @override
  String get close => 'Fechar';

  @override
  String get sync => 'Sincronização';

  @override
  String get syncAllSent => 'Todas as alterações estão guardadas online.';

  @override
  String get relays => 'Relays';

  @override
  String get relaysDescription =>
      'Este cofre é copiado para cada um destes relays. Eles só veem dados encriptados e a chave pública do cofre.';

  @override
  String get relayConnected => 'Ligado';

  @override
  String get relayNotConnected => 'Sem ligação';

  @override
  String get relayPrivate => 'Privado';

  @override
  String get removeRelay => 'Remover este relay';

  @override
  String get addRelay => 'Adicionar um relay';

  @override
  String get relayAddress => 'Endereço do relay';

  @override
  String get relayAddressInvalid => 'Isto não é um endereço de relay.';

  @override
  String get relayAlreadyListed => 'Este relay já está na lista.';

  @override
  String get relayKeepPrivate => 'Manter privado';

  @override
  String get relayKeepPrivateDescription =>
      'Encriptado na lista de relays do cofre: só quem tem a chave do cofre sabe que o cofre está neste relay.';

  @override
  String get relaysSaveFailed => 'Não foi possível guardar os relays.';

  @override
  String get relaysWaitForSync =>
      'Pode alterar os relays quando o cofre estiver sincronizado.';

  @override
  String get relayAdded => 'Novo';

  @override
  String get relayRemoved => 'Removido';

  @override
  String get keepRelay => 'Manter este relay';

  @override
  String get relaysNeedOne => 'O cofre precisa de pelo menos um relay.';

  @override
  String get add => 'Adicionar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Criar';

  @override
  String get open => 'Abrir';

  @override
  String get done => 'Concluído';

  @override
  String get welcomeTagline =>
      'As suas palavras-passe, encriptadas e sincronizadas. Não precisa de conta.';

  @override
  String get builtOnNostr => 'Baseado no Nostr';

  @override
  String get builtOnNostrBody =>
      'Os seus cofres ficam guardados em relays Nostr: servidores abertos que qualquer pessoa pode alojar e que só veem dados encriptados. A chave de um cofre é uma chave Nostr, por isso um assinante Nostr pode guardá-la.';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
      zero: 'Nenhum item',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sincronizar agora';

  @override
  String get syncing => 'A sincronizar';

  @override
  String get syncNever => 'Nunca sincronizado';

  @override
  String get syncFailed => 'Falha na sincronização';

  @override
  String get signerDidNotOpen => 'O assinante não abriu o cofre';

  @override
  String get syncedJustNow => 'Sincronizado há instantes';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Sincronizado há $minutes min';
  }

  @override
  String syncedHoursAgo(int hours) {
    return 'Sincronizado há $hours h';
  }

  @override
  String syncedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Sincronizado a $dateString';
  }

  @override
  String get noItems => 'Ainda não há itens neste cofre.';

  @override
  String get lookingForItems => 'A procurar os seus itens';

  @override
  String get signerDidNotOpenVault =>
      'O assinante não abriu este cofre. Sincronize para lhe voltar a pedir.';

  @override
  String get selectItem => 'Selecione um item para o ver aqui.';

  @override
  String get itemNotFound => 'Este item já não está no cofre.';

  @override
  String get typeLogin => 'Credencial';

  @override
  String get typeSecureNote => 'Nota segura';

  @override
  String get typeCard => 'Cartão';

  @override
  String get typeIdentity => 'Identidade';

  @override
  String get typeSshKey => 'Chave SSH';

  @override
  String get typeBankAccount => 'Conta bancária';

  @override
  String get typeDriversLicense => 'Carta de condução';

  @override
  String get typePassport => 'Passaporte';

  @override
  String get typeUnknown => 'Item';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get openWebsite => 'Abrir site';

  @override
  String get username => 'Nome de utilizador';

  @override
  String get password => 'Palavra-passe';

  @override
  String get verificationCode => 'Código de verificação';

  @override
  String get totpInvalid => 'Não é possível ler esta chave de verificação.';

  @override
  String get website => 'Site';

  @override
  String get passkey => 'Chave de acesso';

  @override
  String passkeyCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Criada a $dateString';
  }

  @override
  String get notes => 'Notas';

  @override
  String get customFields => 'Campos personalizados';

  @override
  String get passwordHistory => 'Histórico de palavras-passe';

  @override
  String itemDates(DateTime updated, DateTime created) {
    final intl.DateFormat updatedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String updatedString = updatedDateFormat.format(updated);
    final intl.DateFormat createdDateFormat = intl.DateFormat.yMMMd(localeName);
    final String createdString = createdDateFormat.format(created);

    return 'Atualizado a $updatedString, criado a $createdString';
  }

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String linkedTo(String field) {
    return 'Associado a $field';
  }

  @override
  String get cardholderName => 'Titular do cartão';

  @override
  String get cardBrand => 'Marca';

  @override
  String get cardNumber => 'Número';

  @override
  String get cardExpiration => 'Validade';

  @override
  String get cardExpMonth => 'Mês de validade';

  @override
  String get cardExpYear => 'Ano de validade';

  @override
  String get cardCode => 'Código de segurança';

  @override
  String get fullName => 'Nome';

  @override
  String get identityTitle => 'Título';

  @override
  String get firstName => 'Nome próprio';

  @override
  String get middleName => 'Nome do meio';

  @override
  String get lastName => 'Apelido';

  @override
  String get company => 'Empresa';

  @override
  String get email => 'E-mail';

  @override
  String get phone => 'Telefone';

  @override
  String get address => 'Morada';

  @override
  String get city => 'Cidade';

  @override
  String get state => 'Estado ou região';

  @override
  String get postalCode => 'Código postal';

  @override
  String get country => 'País';

  @override
  String get ssn => 'Número de segurança social';

  @override
  String get passportNumber => 'Número do passaporte';

  @override
  String get licenseNumber => 'Número da carta de condução';

  @override
  String get privateKey => 'Chave privada';

  @override
  String get publicKey => 'Chave pública';

  @override
  String get fingerprint => 'Impressão digital';

  @override
  String get bankName => 'Banco';

  @override
  String get accountHolder => 'Titular da conta';

  @override
  String get accountType => 'Tipo de conta';

  @override
  String get accountNumber => 'Número da conta';

  @override
  String get routingNumber => 'Número de encaminhamento';

  @override
  String get branchNumber => 'Número da agência';

  @override
  String get pin => 'PIN';

  @override
  String get swiftCode => 'Código SWIFT';

  @override
  String get iban => 'IBAN';

  @override
  String get bankPhone => 'Telefone do banco';

  @override
  String get accountTypeChecking => 'Conta à ordem';

  @override
  String get accountTypeSavings => 'Poupança';

  @override
  String get accountTypeCertificateOfDeposit => 'Depósito a prazo';

  @override
  String get accountTypeLineOfCredit => 'Linha de crédito';

  @override
  String get accountTypeInvestmentBrokerage => 'Conta de títulos';

  @override
  String get accountTypeMoneyMarket => 'Mercado monetário';

  @override
  String get accountTypeOther => 'Outro';

  @override
  String get dateOfBirth => 'Data de nascimento';

  @override
  String get issuingCountry => 'País de emissão';

  @override
  String get issuingState => 'Estado ou região de emissão';

  @override
  String get issueDate => 'Data de emissão';

  @override
  String get expirationDate => 'Data de validade';

  @override
  String get issuingAuthority => 'Autoridade emissora';

  @override
  String get licenseClass => 'Categoria';

  @override
  String get surname => 'Apelido';

  @override
  String get givenName => 'Nome próprio';

  @override
  String get sex => 'Sexo';

  @override
  String get birthPlace => 'Local de nascimento';

  @override
  String get nationality => 'Nacionalidade';

  @override
  String get passportType => 'Tipo';

  @override
  String get nationalId => 'Número de identificação nacional';

  @override
  String get filterAllItems => 'Todos os itens';

  @override
  String get filterAllShort => 'Todos';

  @override
  String get filterFavorites => 'Favoritos';

  @override
  String get filterLogins => 'Credenciais';

  @override
  String get filterSecureNotes => 'Notas seguras';

  @override
  String get filterCards => 'Cartões';

  @override
  String get filterIdentities => 'Identidades';

  @override
  String get filterSshKeys => 'Chaves SSH';

  @override
  String get filterBankAccounts => 'Contas bancárias';

  @override
  String get filterDriversLicenses => 'Cartas de condução';

  @override
  String get filterPassports => 'Passaportes';

  @override
  String get filterTrash => 'Lixo';

  @override
  String get noItemsHere => 'Nenhum item aqui.';

  @override
  String get searchItems => 'Procurar';

  @override
  String get clearSearch => 'Limpar a pesquisa';

  @override
  String get noSearchResults => 'Nenhum item corresponde à sua pesquisa.';

  @override
  String changesNotSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações por enviar',
      one: '1 alteração por enviar',
    );
    return '$_temp0';
  }

  @override
  String get newItem => 'Novo item';

  @override
  String get newLogin => 'Nova credencial';

  @override
  String get newCard => 'Novo cartão';

  @override
  String get newSecureNote => 'Nova nota segura';

  @override
  String get editItem => 'Editar item';

  @override
  String get edit => 'Editar';

  @override
  String get save => 'Guardar';

  @override
  String get itemSaveFailed => 'Não foi possível guardar o item.';

  @override
  String get vault => 'Cofre';

  @override
  String get itemName => 'Nome';

  @override
  String get itemNameRequired => 'Dê um nome ao item.';

  @override
  String get authenticatorKey => 'Chave de autenticação';

  @override
  String get authenticatorKeyHint => 'Segredo Base32 ou URI otpauth://';

  @override
  String get addWebsite => 'Adicionar um site';

  @override
  String get addField => 'Adicionar um campo';

  @override
  String get customField => 'Campo personalizado';

  @override
  String get editField => 'Editar o campo';

  @override
  String get fieldType => 'Tipo de campo';

  @override
  String get fieldTypeText => 'Texto';

  @override
  String get fieldTypeHidden => 'Oculto';

  @override
  String get fieldTypeCheckbox => 'Caixa de verificação';

  @override
  String get fieldTypeLinked => 'Associado';

  @override
  String get textFieldHelp =>
      'Utilize campos de texto para dados como perguntas de segurança.';

  @override
  String get hiddenFieldHelp =>
      'Utilize campos ocultos para dados sensíveis como uma palavra-passe.';

  @override
  String get checkboxFieldHelp =>
      'Utilize caixas de verificação para preencher a caixa de um formulário, como lembrar o meu e-mail.';

  @override
  String get linkedFieldHelp =>
      'Utilize um campo associado quando o preenchimento automático tem problemas com um site específico.';

  @override
  String get fieldLabel => 'Etiqueta do campo';

  @override
  String get linkedFieldLabelHelp =>
      'Introduza o id HTML, o name, o aria-label ou o placeholder do campo.';

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
  String get cardBrandOther => 'Outra';

  @override
  String get cardExpYearHint => 'AAAA';

  @override
  String get notSet => 'Não definido';

  @override
  String get favorite => 'Favorito';

  @override
  String get addToFavorites => 'Adicionar aos favoritos';

  @override
  String get removeFromFavorites => 'Remover dos favoritos';

  @override
  String get discardChanges => 'Descartar as alterações?';

  @override
  String get keepEditing => 'Continuar a editar';

  @override
  String get discard => 'Descartar';

  @override
  String get moreActions => 'Mais ações';

  @override
  String get copyUsername => 'Copiar nome de utilizador';

  @override
  String get copyPassword => 'Copiar palavra-passe';

  @override
  String get copyTotp => 'Copiar código de verificação';

  @override
  String get copyNumber => 'Copiar número';

  @override
  String get moveToTrash => 'Mover para o lixo';

  @override
  String get restore => 'Restaurar';

  @override
  String get deletePermanently => 'Eliminar permanentemente';

  @override
  String get deleteItemTitle => 'Eliminar este item permanentemente?';

  @override
  String get deleteItemBody =>
      'Será apagado do cofre, em todos os dispositivos. Esta ação não pode ser anulada.';

  @override
  String get delete => 'Eliminar';

  @override
  String get generatePassword => 'Gerar uma palavra-passe';

  @override
  String get generateUsername => 'Gerar um nome de utilizador';

  @override
  String get generator => 'Gerador';

  @override
  String get passphrase => 'Frase de acesso';

  @override
  String get regenerate => 'Gerar novamente';

  @override
  String get passwordLength => 'Comprimento';

  @override
  String get includeCharacters => 'Incluir';

  @override
  String get uppercaseLetters => 'Letras maiúsculas';

  @override
  String get lowercaseLetters => 'Letras minúsculas';

  @override
  String get digits => 'Números';

  @override
  String get specialCharacters => 'Caracteres especiais';

  @override
  String get minNumbers => 'Mínimo de números';

  @override
  String get minSpecial => 'Mínimo de caracteres especiais';

  @override
  String get avoidAmbiguous => 'Evitar caracteres ambíguos';

  @override
  String get numberOfWords => 'Número de palavras';

  @override
  String get wordSeparator => 'Separador de palavras';

  @override
  String get capitalize => 'Iniciais maiúsculas';

  @override
  String get includeNumber => 'Incluir um número';

  @override
  String get usePassword => 'Utilizar esta palavra-passe';

  @override
  String get usePassphrase => 'Utilizar esta frase de acesso';

  @override
  String get useUsername => 'Utilizar este nome de utilizador';

  @override
  String get usernameCapitalize => 'Inicial maiúscula';

  @override
  String get usernameIncludeNumber => 'Incluir um número';

  @override
  String get decrease => 'Diminuir';

  @override
  String get increase => 'Aumentar';

  @override
  String get settings => 'Definições';

  @override
  String get security => 'Segurança';

  @override
  String get unlockWithBiometrics => 'Desbloquear com biometria';

  @override
  String get unlockWithBiometricsDescription =>
      'Ou com o código ou a palavra-passe deste dispositivo. As chaves dos cofres ficam no armazenamento seguro do dispositivo.';

  @override
  String get lockNeedsScreenLock =>
      'Configure primeiro um bloqueio de ecrã neste dispositivo.';

  @override
  String get lockAfter => 'Bloquear após';

  @override
  String get lockImmediately => 'Imediatamente';

  @override
  String get lockOnRestart => 'Ao reiniciar a aplicação';

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
  String get clearClipboardAfter => 'Limpar palavras-passe copiadas após';

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
  String get allowScreenCapture => 'Permitir captura de ecrã';

  @override
  String get allowScreenCaptureDescription =>
      'Permite que capturas de ecrã, gravações e partilha de ecrã mostrem as suas palavras-passe.';

  @override
  String get lock => 'Bloquear';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get vaultsLocked => 'Os seus cofres estão bloqueados.';

  @override
  String get unlockReason => 'Desbloquear os seus cofres';

  @override
  String get enableLockReason => 'Ativar o bloqueio';

  @override
  String get authLockedOut =>
      'Demasiadas tentativas. Tente novamente mais tarde.';

  @override
  String get authFailed =>
      'Este dispositivo não conseguiu confirmar a sua identidade.';

  @override
  String get vaultTab => 'Cofre';

  @override
  String get storageReadFailed => 'Não foi possível ler os seus cofres.';

  @override
  String get storageReadFailedBody =>
      'O armazenamento seguro deste dispositivo recusou-se a abri-los. Nada foi apagado: tente novamente. Os seus itens continuam online, e a chave de um cofre abre-o em qualquer dispositivo.';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get appearance => 'Aspeto';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageName => 'Português (Portugal)';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get importExport => 'Importar e exportar';

  @override
  String get importFromBitwarden => 'Importar do Bitwarden';

  @override
  String get importFromBitwardenDescription =>
      'Uma exportação JSON do Bitwarden.';

  @override
  String get importButton => 'Importar';

  @override
  String get importReadFailed => 'Não foi possível ler o ficheiro.';

  @override
  String get importNotBitwarden =>
      'Este ficheiro não é uma exportação JSON do Bitwarden.';

  @override
  String get importEncrypted =>
      'Esta exportação está restringida à sua conta Bitwarden, e só o Bitwarden a consegue abrir. Exporte novamente o seu cofre a partir do Bitwarden, protegido por palavra-passe ou no formato .json.';

  @override
  String get importEmpty => 'Esta exportação não tem itens.';

  @override
  String importFound(int count, String file) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens encontrados em $file.',
      one: '1 item encontrado em $file.',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return '$done de $total itens importados';
  }

  @override
  String importDone(int count, String vault) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens importados para $vault.',
      one: '1 item importado para $vault.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(int done, int total) {
    return 'A importação parou: $done de $total itens foram guardados.';
  }

  @override
  String get exportVault => 'Exportar um cofre';

  @override
  String get exportVaultDescription =>
      'Um ficheiro JSON do Bitwarden, protegido por palavra-passe ou não encriptado.';

  @override
  String get exportButton => 'Exportar';

  @override
  String exportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens. O lixo não é incluído.',
      one: '1 item. O lixo não é incluído.',
      zero: 'Este cofre não tem itens para exportar.',
    );
    return '$_temp0';
  }

  @override
  String get exportWarning =>
      'O ficheiro não está encriptado. Não o envie por e-mail, e elimine-o quando já não precisar dele.';

  @override
  String get exportFailed => 'Não foi possível guardar o ficheiro.';

  @override
  String get importPasswordBody =>
      'Esta exportação está protegida por uma palavra-passe. Introduza-a para abrir o ficheiro.';

  @override
  String get filePassword => 'Palavra-passe do ficheiro';

  @override
  String get wrongFilePassword => 'Esta palavra-passe não abre o ficheiro.';

  @override
  String get exportProtect => 'Proteger com palavra-passe';

  @override
  String get confirmFilePassword => 'Confirmar a palavra-passe do ficheiro';

  @override
  String get filePasswordHelper =>
      'O Submarine e o Bitwarden pedem-na para importar o ficheiro. Não pode ser recuperada.';

  @override
  String get filePasswordRequired => 'Escolha uma palavra-passe.';

  @override
  String get filePasswordMismatch => 'As palavras-passe não coincidem.';

  @override
  String get lockPassword => 'Palavra-passe de bloqueio';

  @override
  String get lockPasswordDescription =>
      'Encripta as chaves dos cofres neste dispositivo e desbloqueia a aplicação. Não pode ser recuperada.';

  @override
  String get setLockPassword => 'Definir';

  @override
  String get changeLockPassword => 'Alterar';

  @override
  String get removeLockPassword => 'Remover';

  @override
  String get setLockPasswordTitle => 'Definir uma palavra-passe de bloqueio';

  @override
  String get changeLockPasswordTitle => 'Alterar a palavra-passe de bloqueio';

  @override
  String get removeLockPasswordTitle => 'Remover a palavra-passe de bloqueio';

  @override
  String get removeLockPasswordBody =>
      'A aplicação deixa de a pedir. As chaves dos cofres deste dispositivo passam a depender só do armazenamento seguro.';

  @override
  String get currentLockPassword => 'Palavra-passe atual';

  @override
  String get newLockPassword => 'Nova palavra-passe';

  @override
  String get confirmLockPassword => 'Confirmar a palavra-passe';

  @override
  String lockPasswordHelper(int count) {
    return 'Pelo menos $count caracteres. Se a esquecer, os cofres serão removidos deste dispositivo.';
  }

  @override
  String lockPasswordTooShort(int count) {
    return 'Pelo menos $count caracteres.';
  }

  @override
  String get lockPasswordMismatch => 'As palavras-passe não coincidem.';

  @override
  String get wrongLockPassword => 'Esta não é a palavra-passe de bloqueio.';

  @override
  String get generatePassphrase => 'Gerar uma frase de acesso';

  @override
  String get unlockWithBiometricsWithPassword =>
      'Em vez de escrever a palavra-passe de bloqueio, que continua a funcionar.';

  @override
  String get forgotLockPassword => 'Esqueceu-se da palavra-passe?';

  @override
  String get forgetVaultsTitle => 'Remover os cofres deste dispositivo?';

  @override
  String get forgetVaultsBody =>
      'Sem a palavra-passe de bloqueio, não podem ser desencriptados aqui. Os seus itens continuam online: volte a abrir cada cofre com a respetiva chave.';

  @override
  String get forgetVaults => 'Remover os cofres';

  @override
  String get removeVault => 'Remover deste dispositivo';

  @override
  String get removeVaultDescription =>
      'O cofre continua online, para o poder voltar a abrir.';

  @override
  String removeVaultTitle(String name) {
    return 'Remover $name deste dispositivo?';
  }

  @override
  String get removeVaultBody =>
      'Os seus itens continuam online: volte a abrir o cofre para os encontrar.';

  @override
  String get removeVaultKeyWarning =>
      'Guarde primeiro a chave: sem ela, não poderá voltar a abrir o cofre.';

  @override
  String removeVaultUnsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações ainda não foram enviadas e vão perder-se.',
      one: '1 alteração ainda não foi enviada e vai perder-se.',
    );
    return '$_temp0';
  }

  @override
  String get removeVaultConfirm => 'Remover';

  @override
  String get removeVaultFailed => 'Não foi possível remover o cofre.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get allVaults => 'Todos os cofres';

  @override
  String get vaults => 'Cofres';

  @override
  String get addVault => 'Adicionar cofre';

  @override
  String get createVault => 'Criar cofre';

  @override
  String get createVaultDescription =>
      'Um cofre novo e vazio, com sua própria chave.';

  @override
  String get openVault => 'Abrir cofre';

  @override
  String get openVaultDescription =>
      'De outro dispositivo, ou compartilhado com você.';

  @override
  String get openVaultTitle => 'Abrir cofre';

  @override
  String get vaultName => 'Nome';

  @override
  String get vaultNameHelper =>
      'Apenas neste dispositivo. Quem recebe o cofre compartilhado por você dá a ele o nome que quiser.';

  @override
  String get vaultNameRequired => 'Dê um nome ao cofre.';

  @override
  String get vaultColor => 'Cor';

  @override
  String vaultColorOption(int number) {
    return 'Cor $number';
  }

  @override
  String get vaultKey => 'Chave do cofre';

  @override
  String get vaultKeyInvalid => 'Isso não é uma chave de cofre.';

  @override
  String vaultAlreadyOpen(String name) {
    return 'Este cofre já está aberto, com o nome $name.';
  }

  @override
  String get vaultSaveFailed =>
      'Não foi possível salvar o cofre neste dispositivo.';

  @override
  String get saveVaultKeyTitle => 'Guarde a chave do cofre';

  @override
  String get saveVaultKeyBody =>
      'Quem tiver esta chave pode abrir o cofre. Guarde-a em um lugar seguro: você vai precisar dela para abrir o cofre em outro dispositivo ou para compartilhá-lo.';

  @override
  String get vaultSettings => 'Configurações do cofre';

  @override
  String get vaultNameAndColor => 'Nome e cor';

  @override
  String get vaultPublicKey => 'Chave pública';

  @override
  String get vaultKeyDescription =>
      'Quem tiver esta chave pode abrir este cofre. Digite-a em outro dispositivo para abrir o cofre lá, ou entregue-a a alguém para compartilhar o cofre.';

  @override
  String get vaultKeyHelper =>
      'A chave guardada ao criar o cofre, ou compartilhada com você.';

  @override
  String get vaultKeyPassword => 'Senha da chave';

  @override
  String get vaultKeyPasswordWrong => 'Esta senha não abre a chave.';

  @override
  String get vaultKeyDecrypting => 'Descriptografando a chave';

  @override
  String get otherWaysToOpen => 'Outras formas de abrir';

  @override
  String get signersDescription =>
      'Com um assinante que guarda a chave fora do Submarine. Um endereço bunker:// também pode ser colado no campo da chave.';

  @override
  String get browserExtension => 'Extensão do navegador';

  @override
  String get signerApp => 'App de assinatura';

  @override
  String get bunker => 'Assinante remoto';

  @override
  String get nostrConnect => 'Nostr Connect';

  @override
  String get nostrConnectBody =>
      'Escaneie este código com seu assinante remoto ou app de assinatura, ou cole o endereço nele.';

  @override
  String get noBrowserExtension => 'Nenhuma extensão Nostr neste navegador.';

  @override
  String get noSignerApp =>
      'Nenhum app de assinatura, como o Amber, neste dispositivo.';

  @override
  String get signerRefused => 'A solicitação foi recusada.';

  @override
  String get waitingForAnswer => 'Aguardando resposta';

  @override
  String get bunkerUrlInvalid =>
      'Falta um relay ou um segredo neste endereço bunker://.';

  @override
  String get bunkerNoAnswer => 'O assinante remoto não respondeu.';

  @override
  String get bunkerApproval =>
      'O assinante remoto pede que você aprove o Submarine na página dele.';

  @override
  String get openApprovalPage => 'Abrir a página';

  @override
  String get nothingConnected => 'Nada se conectou a tempo.';

  @override
  String get useAnotherKey => 'Usar outra chave';

  @override
  String get vaultSignerDescription =>
      'Guarda a chave do cofre, que nunca entra no Submarine. Em outro dispositivo, abra o cofre da mesma forma.';

  @override
  String get askSignerAtStart => 'Consultar o assinante ao abrir o app';

  @override
  String get askSignerAtStartDescription =>
      'Desativado: uma chave guardada neste dispositivo lê o cofre mesmo quando o assinante está fora de alcance. Ativado: o cofre fica fechado até o assinante abri-lo.';

  @override
  String get askSignerFailed => 'O assinante recusou ou falhou.';

  @override
  String signerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count solicitações aguardam seu assinante',
      many: '$count de solicitações aguardam seu assinante',
      one: '$count solicitação aguarda seu assinante',
    );
    return '$_temp0';
  }

  @override
  String get signerRequestsTitle => 'Aguardando seu assinante';

  @override
  String get signerRequestsDescription =>
      'Aprove estas solicitações no seu assinante, ou cancele-as.';

  @override
  String get requestOpenVault => 'Abrir o cofre';

  @override
  String get requestLockVault => 'Bloquear o cofre com o assinante';

  @override
  String requestDecryptVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Descriptografar $count versões de itens',
      many: 'Descriptografar $count de versões de itens',
      one: 'Descriptografar $count versão de item',
    );
    return '$_temp0';
  }

  @override
  String requestSaveVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvar $count versões de itens',
      many: 'Salvar $count de versões de itens',
      one: 'Salvar $count versão de item',
    );
    return '$_temp0';
  }

  @override
  String requestDeleteVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir permanentemente $count versões de itens',
      many: 'Excluir permanentemente $count de versões de itens',
      one: 'Excluir permanentemente $count versão de item',
    );
    return '$_temp0';
  }

  @override
  String get requestSaveRelays => 'Salvar a lista de relays';

  @override
  String get requestReadRelays => 'Ler os relays privados';

  @override
  String get requestEncryptRelays => 'Criptografar os relays privados';

  @override
  String requestRelayAuth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Autenticar em $count relays',
      many: 'Autenticar em $count de relays',
      one: 'Autenticar em $count relay',
    );
    return '$_temp0';
  }

  @override
  String requestOther(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outras solicitações ($method)',
      many: '$count de outras solicitações ($method)',
      one: '$count outra solicitação ($method)',
    );
    return '$_temp0';
  }

  @override
  String get cancelAll => 'Cancelar tudo';

  @override
  String get close => 'Fechar';

  @override
  String get sync => 'Sincronização';

  @override
  String get syncAllSent => 'Todas as alterações estão salvas online.';

  @override
  String get relays => 'Relays';

  @override
  String get relaysDescription =>
      'Este cofre é copiado em cada um destes relays. Eles só veem dados criptografados e a chave pública do cofre.';

  @override
  String get relayConnected => 'Conectado';

  @override
  String get relayNotConnected => 'Sem conexão';

  @override
  String get relayPrivate => 'Privado';

  @override
  String get removeRelay => 'Remover este relay';

  @override
  String get addRelay => 'Adicionar relay';

  @override
  String get relayAddress => 'Endereço do relay';

  @override
  String get relayAddressInvalid => 'Isso não é um endereço de relay.';

  @override
  String get relayAlreadyListed => 'Este relay já está na lista.';

  @override
  String get relayKeepPrivate => 'Manter privado';

  @override
  String get relayKeepPrivateDescription =>
      'Criptografado na lista de relays do cofre: só quem tem a chave do cofre sabe que o cofre está nele.';

  @override
  String get relaysSaveFailed => 'Não foi possível salvar os relays.';

  @override
  String get relaysWaitForSync =>
      'Você poderá alterar os relays depois que o cofre for sincronizado.';

  @override
  String get relayAdded => 'Novo';

  @override
  String get relayRemoved => 'Removido';

  @override
  String get keepRelay => 'Manter este relay';

  @override
  String get relaysNeedOne => 'O cofre precisa de pelo menos um relay.';

  @override
  String get add => 'Adicionar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Criar';

  @override
  String get open => 'Abrir';

  @override
  String get done => 'Concluído';

  @override
  String get welcomeTagline =>
      'Suas senhas, criptografadas e sincronizadas. Sem precisar de conta.';

  @override
  String get builtOnNostr => 'Feito com Nostr';

  @override
  String get builtOnNostrBody =>
      'Seus cofres ficam em relays Nostr: servidores abertos que qualquer pessoa pode manter e que só veem dados criptografados. A chave de um cofre é uma chave Nostr, então um assinante Nostr pode guardá-la.';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      many: '$count de itens',
      one: '$count item',
      zero: 'Nenhum item',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sincronizar agora';

  @override
  String get syncing => 'Sincronizando';

  @override
  String get syncNever => 'Nunca sincronizado';

  @override
  String get syncFailed => 'Falha na sincronização';

  @override
  String get signerDidNotOpen => 'O assinante não abriu o cofre';

  @override
  String get syncedJustNow => 'Sincronizado agora mesmo';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Sincronizado há $minutes min';
  }

  @override
  String syncedHoursAgo(int hours) {
    return 'Sincronizado há $hours h';
  }

  @override
  String syncedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Sincronizado em $dateString';
  }

  @override
  String get noItems => 'Ainda não há itens neste cofre.';

  @override
  String get lookingForItems => 'Procurando seus itens';

  @override
  String get signerDidNotOpenVault =>
      'O assinante não abriu este cofre. Sincronize para pedir de novo.';

  @override
  String get selectItem => 'Selecione um item para vê-lo aqui.';

  @override
  String get itemNotFound => 'Este item não está mais no cofre.';

  @override
  String get typeLogin => 'Credencial';

  @override
  String get typeSecureNote => 'Anotação segura';

  @override
  String get typeCard => 'Cartão';

  @override
  String get typeIdentity => 'Identidade';

  @override
  String get typeSshKey => 'Chave SSH';

  @override
  String get typeBankAccount => 'Conta bancária';

  @override
  String get typeDriversLicense => 'Carteira de habilitação';

  @override
  String get typePassport => 'Passaporte';

  @override
  String get typeUnknown => 'Item';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get openWebsite => 'Abrir site';

  @override
  String get username => 'Nome de usuário';

  @override
  String get password => 'Senha';

  @override
  String get verificationCode => 'Código de verificação';

  @override
  String get totpInvalid => 'Não foi possível ler esta chave de verificação.';

  @override
  String get website => 'Site';

  @override
  String get passkey => 'Chave de acesso';

  @override
  String passkeyCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Criada em $dateString';
  }

  @override
  String get notes => 'Anotações';

  @override
  String get customFields => 'Campos personalizados';

  @override
  String get passwordHistory => 'Histórico de senhas';

  @override
  String itemDates(DateTime updated, DateTime created) {
    final intl.DateFormat updatedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String updatedString = updatedDateFormat.format(updated);
    final intl.DateFormat createdDateFormat = intl.DateFormat.yMMMd(localeName);
    final String createdString = createdDateFormat.format(created);

    return 'Atualizado em $updatedString, criado em $createdString';
  }

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String linkedTo(String field) {
    return 'Vinculado a $field';
  }

  @override
  String get cardholderName => 'Nome do titular do cartão';

  @override
  String get cardBrand => 'Bandeira';

  @override
  String get cardNumber => 'Número';

  @override
  String get cardExpiration => 'Vencimento';

  @override
  String get cardExpMonth => 'Mês de vencimento';

  @override
  String get cardExpYear => 'Ano de vencimento';

  @override
  String get cardCode => 'Código de segurança';

  @override
  String get fullName => 'Nome';

  @override
  String get identityTitle => 'Título';

  @override
  String get firstName => 'Primeiro nome';

  @override
  String get middleName => 'Nome do meio';

  @override
  String get lastName => 'Sobrenome';

  @override
  String get company => 'Empresa';

  @override
  String get email => 'E-mail';

  @override
  String get phone => 'Telefone';

  @override
  String get address => 'Endereço';

  @override
  String get city => 'Cidade';

  @override
  String get state => 'Estado ou região';

  @override
  String get postalCode => 'CEP';

  @override
  String get country => 'País';

  @override
  String get ssn => 'Número de CPF';

  @override
  String get passportNumber => 'Número do passaporte';

  @override
  String get licenseNumber => 'Número da CNH';

  @override
  String get privateKey => 'Chave privada';

  @override
  String get publicKey => 'Chave pública';

  @override
  String get fingerprint => 'Impressão digital';

  @override
  String get bankName => 'Banco';

  @override
  String get accountHolder => 'Titular da conta';

  @override
  String get accountType => 'Tipo de conta';

  @override
  String get accountNumber => 'Número da conta';

  @override
  String get routingNumber => 'Número de roteamento';

  @override
  String get branchNumber => 'Número da agência';

  @override
  String get pin => 'PIN';

  @override
  String get swiftCode => 'Código SWIFT';

  @override
  String get iban => 'IBAN';

  @override
  String get bankPhone => 'Telefone do banco';

  @override
  String get accountTypeChecking => 'Corrente';

  @override
  String get accountTypeSavings => 'Poupança';

  @override
  String get accountTypeCertificateOfDeposit => 'Certificado de depósito';

  @override
  String get accountTypeLineOfCredit => 'Linha de crédito';

  @override
  String get accountTypeInvestmentBrokerage => 'Investimento/corretagem';

  @override
  String get accountTypeMoneyMarket => 'Mercado monetário';

  @override
  String get accountTypeOther => 'Outro';

  @override
  String get dateOfBirth => 'Data de nascimento';

  @override
  String get issuingCountry => 'País de emissão';

  @override
  String get issuingState => 'Estado de emissão';

  @override
  String get issueDate => 'Data de emissão';

  @override
  String get expirationDate => 'Data de validade';

  @override
  String get issuingAuthority => 'Órgão emissor';

  @override
  String get licenseClass => 'Categoria';

  @override
  String get surname => 'Sobrenome';

  @override
  String get givenName => 'Nome';

  @override
  String get sex => 'Sexo';

  @override
  String get birthPlace => 'Local de nascimento';

  @override
  String get nationality => 'Nacionalidade';

  @override
  String get passportType => 'Tipo';

  @override
  String get nationalId => 'Número de identificação nacional';

  @override
  String get filterAllItems => 'Todos os itens';

  @override
  String get filterAllShort => 'Todos';

  @override
  String get filterFavorites => 'Favoritos';

  @override
  String get filterLogins => 'Credenciais';

  @override
  String get filterSecureNotes => 'Anotações seguras';

  @override
  String get filterCards => 'Cartões';

  @override
  String get filterIdentities => 'Identidades';

  @override
  String get filterSshKeys => 'Chaves SSH';

  @override
  String get filterBankAccounts => 'Contas bancárias';

  @override
  String get filterDriversLicenses => 'Carteiras de habilitação';

  @override
  String get filterPassports => 'Passaportes';

  @override
  String get filterTrash => 'Lixeira';

  @override
  String get noItemsHere => 'Nenhum item aqui.';

  @override
  String get searchItems => 'Buscar';

  @override
  String get clearSearch => 'Limpar a busca';

  @override
  String get noSearchResults => 'Nenhum item corresponde à sua busca.';

  @override
  String changesNotSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações ainda não enviadas',
      many: '$count de alterações ainda não enviadas',
      one: '$count alteração ainda não enviada',
    );
    return '$_temp0';
  }

  @override
  String get newItem => 'Novo item';

  @override
  String get newLogin => 'Nova credencial';

  @override
  String get newCard => 'Novo cartão';

  @override
  String get newSecureNote => 'Nova anotação segura';

  @override
  String get editItem => 'Editar item';

  @override
  String get edit => 'Editar';

  @override
  String get save => 'Salvar';

  @override
  String get itemSaveFailed => 'Não foi possível salvar o item.';

  @override
  String get vault => 'Cofre';

  @override
  String get itemName => 'Nome';

  @override
  String get itemNameRequired => 'Dê um nome ao item.';

  @override
  String get authenticatorKey => 'Chave do autenticador';

  @override
  String get authenticatorKeyHint => 'Segredo base32 ou URI otpauth://';

  @override
  String get addWebsite => 'Adicionar site';

  @override
  String get addField => 'Adicionar campo';

  @override
  String get customField => 'Campo personalizado';

  @override
  String get editField => 'Editar campo';

  @override
  String get fieldType => 'Tipo do campo';

  @override
  String get fieldTypeText => 'Texto';

  @override
  String get fieldTypeHidden => 'Oculto';

  @override
  String get fieldTypeCheckbox => 'Caixa de seleção';

  @override
  String get fieldTypeLinked => 'Vinculado';

  @override
  String get textFieldHelp =>
      'Use campos de texto para dados como perguntas de segurança.';

  @override
  String get hiddenFieldHelp =>
      'Use campos ocultos para dados sensíveis, como uma senha.';

  @override
  String get checkboxFieldHelp =>
      'Use caixas de seleção para marcar a caixa de um formulário, como lembrar meu e-mail.';

  @override
  String get linkedFieldHelp =>
      'Use um campo vinculado quando o preenchimento automático tiver problemas com um site específico.';

  @override
  String get fieldLabel => 'Rótulo do campo';

  @override
  String get linkedFieldLabelHelp =>
      'Digite o id HTML, o name, o aria-label ou o placeholder do campo.';

  @override
  String editFieldNamed(String field) {
    return 'Editar $field';
  }

  @override
  String deleteFieldNamed(String field) {
    return 'Excluir $field';
  }

  @override
  String reorderField(String field) {
    return 'Mover $field';
  }

  @override
  String get cardBrandOther => 'Outra';

  @override
  String get cardExpYearHint => 'AAAA';

  @override
  String get notSet => 'Não definido';

  @override
  String get favorite => 'Favorito';

  @override
  String get addToFavorites => 'Adicionar aos favoritos';

  @override
  String get removeFromFavorites => 'Remover dos favoritos';

  @override
  String get discardChanges => 'Descartar alterações?';

  @override
  String get keepEditing => 'Continuar editando';

  @override
  String get discard => 'Descartar';

  @override
  String get moreActions => 'Mais ações';

  @override
  String get copyUsername => 'Copiar nome de usuário';

  @override
  String get copyPassword => 'Copiar senha';

  @override
  String get copyTotp => 'Copiar código de verificação';

  @override
  String get copyNumber => 'Copiar número';

  @override
  String get moveToTrash => 'Mover para a lixeira';

  @override
  String get restore => 'Restaurar';

  @override
  String get deletePermanently => 'Excluir permanentemente';

  @override
  String get deleteItemTitle => 'Excluir este item permanentemente?';

  @override
  String get deleteItemBody =>
      'Ele será apagado do cofre, em todos os dispositivos. Esta ação não pode ser desfeita.';

  @override
  String get delete => 'Excluir';

  @override
  String get generatePassword => 'Gerar senha';

  @override
  String get generateUsername => 'Gerar nome de usuário';

  @override
  String get generator => 'Gerador';

  @override
  String get passphrase => 'Frase secreta';

  @override
  String get regenerate => 'Gerar novamente';

  @override
  String get passwordLength => 'Comprimento';

  @override
  String get includeCharacters => 'Incluir';

  @override
  String get uppercaseLetters => 'Letras maiúsculas';

  @override
  String get lowercaseLetters => 'Letras minúsculas';

  @override
  String get digits => 'Números';

  @override
  String get specialCharacters => 'Caracteres especiais';

  @override
  String get minNumbers => 'Mínimo de números';

  @override
  String get minSpecial => 'Mínimo de caracteres especiais';

  @override
  String get avoidAmbiguous => 'Evitar caracteres ambíguos';

  @override
  String get numberOfWords => 'Número de palavras';

  @override
  String get wordSeparator => 'Separador de palavras';

  @override
  String get capitalize => 'Iniciais maiúsculas';

  @override
  String get includeNumber => 'Incluir número';

  @override
  String get usePassword => 'Usar esta senha';

  @override
  String get usePassphrase => 'Usar esta frase secreta';

  @override
  String get useUsername => 'Usar este nome de usuário';

  @override
  String get usernameCapitalize => 'Inicial maiúscula';

  @override
  String get usernameIncludeNumber => 'Incluir número';

  @override
  String get decrease => 'Diminuir';

  @override
  String get increase => 'Aumentar';

  @override
  String get settings => 'Configurações';

  @override
  String get security => 'Segurança';

  @override
  String get unlockWithBiometrics => 'Desbloquear com biometria';

  @override
  String get unlockWithBiometricsDescription =>
      'Ou com o código ou a senha deste dispositivo. As chaves dos cofres ficam no armazenamento seguro dele.';

  @override
  String get lockNeedsScreenLock =>
      'Configure primeiro um bloqueio de tela neste dispositivo.';

  @override
  String get lockAfter => 'Bloquear após';

  @override
  String get lockImmediately => 'Imediatamente';

  @override
  String get lockOnRestart => 'Ao reiniciar o app';

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      many: '$count de minutos',
      one: '$count minuto',
    );
    return '$_temp0';
  }

  @override
  String hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      many: '$count de horas',
      one: '$count hora',
    );
    return '$_temp0';
  }

  @override
  String get clearClipboardAfter => 'Limpar senhas copiadas após';

  @override
  String get never => 'Nunca';

  @override
  String seconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segundos',
      many: '$count de segundos',
      one: '$count segundo',
    );
    return '$_temp0';
  }

  @override
  String get allowScreenCapture => 'Permitir captura de tela';

  @override
  String get allowScreenCaptureDescription =>
      'Permite que capturas de tela, gravações e compartilhamento de tela mostrem suas senhas.';

  @override
  String get lock => 'Bloquear';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get vaultsLocked => 'Seus cofres estão bloqueados.';

  @override
  String get unlockReason => 'Desbloquear seus cofres';

  @override
  String get enableLockReason => 'Ativar o bloqueio';

  @override
  String get authLockedOut => 'Muitas tentativas. Tente novamente mais tarde.';

  @override
  String get authFailed =>
      'Este dispositivo não conseguiu confirmar que é você.';

  @override
  String get vaultTab => 'Cofre';

  @override
  String get storageReadFailed => 'Não foi possível ler seus cofres.';

  @override
  String get storageReadFailedBody =>
      'O armazenamento seguro deste dispositivo se recusou a abri-los. Nada foi apagado: tente novamente. Seus itens continuam online, e a chave de um cofre o abre em qualquer dispositivo.';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get appearance => 'Aparência';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageName => 'Português (Brasil)';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get importExport => 'Importar e exportar';

  @override
  String get importFromBitwarden => 'Importar do Bitwarden';

  @override
  String get importFromBitwardenDescription =>
      'Uma exportação JSON do Bitwarden.';

  @override
  String get importButton => 'Importar';

  @override
  String get importReadFailed => 'Não foi possível ler o arquivo.';

  @override
  String get importNotBitwarden =>
      'Este arquivo não é uma exportação JSON do Bitwarden.';

  @override
  String get importEncrypted =>
      'Esta exportação é restrita à sua conta do Bitwarden, e só o Bitwarden consegue abri-la. Exporte seu cofre do Bitwarden novamente, com proteção por senha ou no formato .json.';

  @override
  String get importEmpty => 'Esta exportação não tem itens.';

  @override
  String importFound(int count, String file) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens encontrados em $file.',
      many: '$count de itens encontrados em $file.',
      one: '$count item encontrado em $file.',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return '$done de $total itens importados';
  }

  @override
  String importDone(int count, String vault) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens importados para $vault.',
      many: '$count de itens importados para $vault.',
      one: '$count item importado para $vault.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(int done, int total) {
    return 'A importação parou: $done de $total itens foram salvos.';
  }

  @override
  String get exportVault => 'Exportar cofre';

  @override
  String get exportVaultDescription =>
      'Um arquivo JSON do Bitwarden, protegido por senha ou sem criptografia.';

  @override
  String get exportButton => 'Exportar';

  @override
  String exportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens. A lixeira fica de fora.',
      many: '$count de itens. A lixeira fica de fora.',
      one: '$count item. A lixeira fica de fora.',
      zero: 'Este cofre não tem itens para exportar.',
    );
    return '$_temp0';
  }

  @override
  String get exportWarning =>
      'O arquivo não é criptografado. Não o envie por e-mail e exclua-o quando não precisar mais dele.';

  @override
  String get exportFailed => 'Não foi possível salvar o arquivo.';

  @override
  String get importPasswordBody =>
      'Esta exportação é protegida por senha. Digite-a para abrir o arquivo.';

  @override
  String get filePassword => 'Senha do arquivo';

  @override
  String get wrongFilePassword => 'Esta senha não abre o arquivo.';

  @override
  String get exportProtect => 'Proteger com senha';

  @override
  String get confirmFilePassword => 'Confirmar senha do arquivo';

  @override
  String get filePasswordHelper =>
      'O Submarine e o Bitwarden pedem essa senha para importar o arquivo. Ela não pode ser recuperada.';

  @override
  String get filePasswordRequired => 'Escolha uma senha.';

  @override
  String get filePasswordMismatch => 'As senhas não coincidem.';

  @override
  String get lockPassword => 'Senha de bloqueio';

  @override
  String get lockPasswordDescription =>
      'Criptografa as chaves dos cofres neste dispositivo e desbloqueia o app. Ela não pode ser recuperada.';

  @override
  String get setLockPassword => 'Configurar';

  @override
  String get changeLockPassword => 'Alterar';

  @override
  String get removeLockPassword => 'Remover';

  @override
  String get setLockPasswordTitle => 'Definir senha de bloqueio';

  @override
  String get changeLockPasswordTitle => 'Alterar senha de bloqueio';

  @override
  String get removeLockPasswordTitle => 'Remover senha de bloqueio';

  @override
  String get removeLockPasswordBody =>
      'O app deixa de pedir essa senha. As chaves dos cofres neste dispositivo passam a depender só do armazenamento seguro dele.';

  @override
  String get currentLockPassword => 'Senha atual';

  @override
  String get newLockPassword => 'Nova senha';

  @override
  String get confirmLockPassword => 'Confirmar senha';

  @override
  String lockPasswordHelper(int count) {
    return 'Pelo menos $count caracteres. Se você esquecê-la, os cofres serão removidos deste dispositivo.';
  }

  @override
  String lockPasswordTooShort(int count) {
    return 'Pelo menos $count caracteres.';
  }

  @override
  String get lockPasswordMismatch => 'As senhas não coincidem.';

  @override
  String get wrongLockPassword => 'Esta não é a senha de bloqueio.';

  @override
  String get generatePassphrase => 'Gerar frase secreta';

  @override
  String get unlockWithBiometricsWithPassword =>
      'Em vez de digitar a senha de bloqueio, que continua funcionando.';

  @override
  String get forgotLockPassword => 'Esqueceu a senha?';

  @override
  String get forgetVaultsTitle => 'Remover os cofres deste dispositivo?';

  @override
  String get forgetVaultsBody =>
      'Sem a senha de bloqueio, não é possível descriptografá-los aqui. Seus itens continuam online: abra cada cofre de novo com a chave dele.';

  @override
  String get forgetVaults => 'Remover os cofres';

  @override
  String get removeVault => 'Remover deste dispositivo';

  @override
  String get removeVaultDescription =>
      'O cofre continua online, para você abri-lo de novo.';

  @override
  String removeVaultTitle(String name) {
    return 'Remover $name deste dispositivo?';
  }

  @override
  String get removeVaultBody =>
      'Seus itens continuam online: abra o cofre de novo para encontrá-los.';

  @override
  String get removeVaultKeyWarning =>
      'Guarde a chave dele antes: sem ela, você não poderá abrir o cofre de novo.';

  @override
  String removeVaultUnsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações ainda não foram enviadas e serão perdidas.',
      many: '$count de alterações ainda não foram enviadas e serão perdidas.',
      one: '$count alteração ainda não foi enviada e será perdida.',
    );
    return '$_temp0';
  }

  @override
  String get removeVaultConfirm => 'Remover';

  @override
  String get removeVaultFailed => 'Não foi possível remover o cofre.';
}
