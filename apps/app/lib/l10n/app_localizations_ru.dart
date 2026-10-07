// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get allVaults => 'Все хранилища';

  @override
  String get vaults => 'Хранилища';

  @override
  String get addVault => 'Добавить хранилище';

  @override
  String get createVault => 'Создать хранилище';

  @override
  String get createVaultDescription =>
      'Новое пустое хранилище со своим ключом.';

  @override
  String get openVault => 'Открыть хранилище';

  @override
  String get openVaultDescription =>
      'Созданное на другом устройстве или переданное вам.';

  @override
  String get openVaultTitle => 'Открыть хранилище';

  @override
  String get vaultName => 'Название';

  @override
  String get vaultNameHelper =>
      'Только на этом устройстве. Тот, с кем вы поделитесь хранилищем, назовёт его по-своему.';

  @override
  String get vaultNameRequired => 'Укажите название хранилища.';

  @override
  String get vaultColor => 'Цвет';

  @override
  String vaultColorOption(int number) {
    return 'Цвет $number';
  }

  @override
  String get vaultKey => 'Ключ хранилища';

  @override
  String get vaultKeyInvalid => 'Это не ключ хранилища.';

  @override
  String vaultAlreadyOpen(String name) {
    return 'Это хранилище уже открыто под названием $name.';
  }

  @override
  String get vaultSaveFailed =>
      'Не удалось сохранить хранилище на этом устройстве.';

  @override
  String get saveVaultKeyTitle => 'Сохраните ключ хранилища';

  @override
  String get saveVaultKeyBody =>
      'Любой, у кого есть этот ключ, может открыть хранилище. Храните его в надёжном месте: он понадобится, чтобы открыть хранилище на другом устройстве или поделиться им.';

  @override
  String get vaultSettings => 'Настройки хранилища';

  @override
  String get vaultNameAndColor => 'Название и цвет';

  @override
  String get vaultPublicKey => 'Публичный ключ';

  @override
  String get vaultKeyDescription =>
      'Любой, у кого он есть, может открыть это хранилище. Введите его на другом устройстве, чтобы открыть хранилище там, или передайте кому-нибудь, чтобы поделиться хранилищем.';

  @override
  String get vaultKeyHelper =>
      'Ключ, сохранённый при создании хранилища или переданный вам.';

  @override
  String get vaultKeyPassword => 'Пароль ключа';

  @override
  String get vaultKeyPasswordWrong => 'Этот пароль не подходит к ключу.';

  @override
  String get vaultKeyDecrypting => 'Расшифровка ключа';

  @override
  String get otherWaysToOpen => 'Другие способы открыть';

  @override
  String get signersDescription =>
      'Через средство подписи, которое хранит ключ вне Submarine. Адрес bunker:// тоже можно вставить в поле ключа.';

  @override
  String get browserExtension => 'Расширение браузера';

  @override
  String get signerApp => 'Приложение для подписи';

  @override
  String get bunker => 'Удалённая подпись';

  @override
  String get nostrConnect => 'Nostr Connect';

  @override
  String get nostrConnectBody =>
      'Отсканируйте этот код в сервисе удалённой подписи или в приложении для подписи либо вставьте туда адрес.';

  @override
  String get noBrowserExtension => 'В этом браузере нет расширения Nostr.';

  @override
  String get noSignerApp =>
      'На этом устройстве нет приложения для подписи, например Amber.';

  @override
  String get signerRefused => 'Запрос отклонён.';

  @override
  String get waitingForAnswer => 'Ожидание ответа';

  @override
  String get bunkerUrlInvalid =>
      'В этом адресе удалённой подписи нет реле или секрета.';

  @override
  String get bunkerNoAnswer => 'Сервис удалённой подписи не ответил.';

  @override
  String get bunkerApproval =>
      'Сервис удалённой подписи просит подтвердить Submarine на своей странице.';

  @override
  String get openApprovalPage => 'Открыть страницу';

  @override
  String get nothingConnected => 'Время ожидания подключения истекло.';

  @override
  String get useAnotherKey => 'Использовать другой ключ';

  @override
  String get vaultSignerDescription =>
      'Держит у себя ключ хранилища, который никогда не попадает в Submarine. На другом устройстве откройте хранилище тем же способом.';

  @override
  String get askSignerAtStart => 'Открывать через средство подписи при запуске';

  @override
  String get askSignerAtStartDescription =>
      'Если выключено, ключ, сохранённый на этом устройстве, открывает хранилище, даже когда средство подписи недоступно. Если включено, хранилище остаётся закрытым, пока его не откроет средство подписи.';

  @override
  String get askSignerFailed =>
      'Средство подписи отклонило запрос или произошла ошибка.';

  @override
  String signerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запроса ждут ответа средства подписи',
      many: '$count запросов ждут ответа средства подписи',
      few: '$count запроса ждут ответа средства подписи',
      one: '$count запрос ждёт ответа средства подписи',
    );
    return '$_temp0';
  }

  @override
  String get signerRequestsTitle => 'Ожидание средства подписи';

  @override
  String get signerRequestsDescription =>
      'Подтвердите эти запросы в средстве подписи или отмените их.';

  @override
  String get requestOpenVault => 'Открыть хранилище';

  @override
  String get requestLockVault => 'Защитить хранилище средством подписи';

  @override
  String requestDecryptVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Расшифровать $count версии элементов',
      many: 'Расшифровать $count версий элементов',
      few: 'Расшифровать $count версии элементов',
      one: 'Расшифровать $count версию элемента',
    );
    return '$_temp0';
  }

  @override
  String requestSaveVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сохранить $count версии элементов',
      many: 'Сохранить $count версий элементов',
      few: 'Сохранить $count версии элементов',
      one: 'Сохранить $count версию элемента',
    );
    return '$_temp0';
  }

  @override
  String requestDeleteVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Окончательно удалить $count версии элементов',
      many: 'Окончательно удалить $count версий элементов',
      few: 'Окончательно удалить $count версии элементов',
      one: 'Окончательно удалить $count версию элемента',
    );
    return '$_temp0';
  }

  @override
  String get requestSaveRelays => 'Сохранить список реле';

  @override
  String get requestReadRelays => 'Прочитать приватные реле';

  @override
  String get requestEncryptRelays => 'Зашифровать приватные реле';

  @override
  String requestRelayAuth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Войти на $count реле',
      many: 'Войти на $count реле',
      few: 'Войти на $count реле',
      one: 'Войти на $count реле',
    );
    return '$_temp0';
  }

  @override
  String requestOther(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count другого запроса ($method)',
      many: '$count других запросов ($method)',
      few: '$count других запроса ($method)',
      one: '$count другой запрос ($method)',
    );
    return '$_temp0';
  }

  @override
  String get cancelAll => 'Отменить все';

  @override
  String get close => 'Закрыть';

  @override
  String get sync => 'Синхронизация';

  @override
  String get syncAllSent => 'Все изменения сохранены в сети.';

  @override
  String get relays => 'Реле';

  @override
  String get relaysDescription =>
      'Это хранилище копируется на каждое из этих реле. Они видят только зашифрованные данные и его публичный ключ.';

  @override
  String get relayConnected => 'Подключено';

  @override
  String get relayNotConnected => 'Не подключено';

  @override
  String get relayPrivate => 'Приватное';

  @override
  String get removeRelay => 'Удалить это реле';

  @override
  String get addRelay => 'Добавить реле';

  @override
  String get relayAddress => 'Адрес реле';

  @override
  String get relayAddressInvalid => 'Это не адрес реле.';

  @override
  String get relayAlreadyListed => 'Это реле уже есть в списке.';

  @override
  String get relayKeepPrivate => 'Сделать приватным';

  @override
  String get relayKeepPrivateDescription =>
      'Зашифровано в списке реле хранилища: только те, у кого есть его ключ, знают, что хранилище на этом реле.';

  @override
  String get relaysSaveFailed => 'Не удалось сохранить реле.';

  @override
  String get relaysWaitForSync =>
      'Реле можно будет изменить после синхронизации хранилища.';

  @override
  String get relayAdded => 'Новое';

  @override
  String get relayRemoved => 'Удалено';

  @override
  String get keepRelay => 'Оставить это реле';

  @override
  String get relaysNeedOne => 'Хранилищу нужно хотя бы одно реле.';

  @override
  String get add => 'Добавить';

  @override
  String get cancel => 'Отмена';

  @override
  String get create => 'Создать';

  @override
  String get open => 'Открыть';

  @override
  String get done => 'Готово';

  @override
  String get welcomeTagline =>
      'Ваши пароли зашифрованы и синхронизированы. Без регистрации.';

  @override
  String get builtOnNostr => 'Работает на Nostr';

  @override
  String get builtOnNostrBody =>
      'Ваши хранилища находятся на реле Nostr. Это открытые серверы: их может запустить любой, и они видят только зашифрованные данные. Ключ хранилища является ключом Nostr, поэтому его может хранить средство подписи Nostr.';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элемента',
      many: '$count элементов',
      few: '$count элемента',
      one: '$count элемент',
      zero: 'Нет элементов',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Синхронизировать';

  @override
  String get syncing => 'Синхронизация';

  @override
  String get syncNever => 'Ни разу не синхронизировано';

  @override
  String get syncFailed => 'Ошибка синхронизации';

  @override
  String get signerDidNotOpen => 'Средство подписи не открыло хранилище';

  @override
  String get syncedJustNow => 'Синхронизировано только что';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Синхронизировано $minutes мин назад';
  }

  @override
  String syncedHoursAgo(int hours) {
    return 'Синхронизировано $hours ч назад';
  }

  @override
  String syncedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Синхронизировано $dateString';
  }

  @override
  String get noItems => 'В этом хранилище пока нет элементов.';

  @override
  String get lookingForItems => 'Поиск ваших элементов';

  @override
  String get signerDidNotOpenVault =>
      'Средство подписи не открыло это хранилище. Запустите синхронизацию, чтобы запросить ещё раз.';

  @override
  String get selectItem => 'Выберите элемент, чтобы просмотреть его здесь.';

  @override
  String get itemNotFound => 'Этого элемента больше нет в хранилище.';

  @override
  String get typeLogin => 'Логин';

  @override
  String get typeSecureNote => 'Защищённая заметка';

  @override
  String get typeCard => 'Карта';

  @override
  String get typeIdentity => 'Личная информация';

  @override
  String get typeSshKey => 'Ключ SSH';

  @override
  String get typeBankAccount => 'Банковский счёт';

  @override
  String get typeDriversLicense => 'Водительское удостоверение';

  @override
  String get typePassport => 'Паспорт';

  @override
  String get typeUnknown => 'Элемент';

  @override
  String get copy => 'Скопировать';

  @override
  String get copied => 'Скопировано';

  @override
  String get show => 'Показать';

  @override
  String get hide => 'Скрыть';

  @override
  String get openWebsite => 'Открыть сайт';

  @override
  String get username => 'Имя пользователя';

  @override
  String get password => 'Пароль';

  @override
  String get verificationCode => 'Код подтверждения';

  @override
  String get totpInvalid => 'Не удаётся прочитать ключ аутентификатора.';

  @override
  String get website => 'Сайт';

  @override
  String get passkey => 'Passkey';

  @override
  String passkeyCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Создан $dateString';
  }

  @override
  String get notes => 'Заметки';

  @override
  String get customFields => 'Пользовательские поля';

  @override
  String get passwordHistory => 'История паролей';

  @override
  String itemDates(DateTime updated, DateTime created) {
    final intl.DateFormat updatedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String updatedString = updatedDateFormat.format(updated);
    final intl.DateFormat createdDateFormat = intl.DateFormat.yMMMd(localeName);
    final String createdString = createdDateFormat.format(created);

    return 'Изменён $updatedString, создан $createdString';
  }

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String linkedTo(String field) {
    return 'Связано с полем $field';
  }

  @override
  String get cardholderName => 'Имя владельца карты';

  @override
  String get cardBrand => 'Тип карты';

  @override
  String get cardNumber => 'Номер';

  @override
  String get cardExpiration => 'Срок действия';

  @override
  String get cardExpMonth => 'Месяц истечения срока';

  @override
  String get cardExpYear => 'Год истечения срока';

  @override
  String get cardCode => 'Код безопасности';

  @override
  String get fullName => 'Полное имя';

  @override
  String get identityTitle => 'Обращение';

  @override
  String get firstName => 'Имя';

  @override
  String get middleName => 'Отчество';

  @override
  String get lastName => 'Фамилия';

  @override
  String get company => 'Компания';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Телефон';

  @override
  String get address => 'Адрес';

  @override
  String get city => 'Город';

  @override
  String get state => 'Область или регион';

  @override
  String get postalCode => 'Почтовый индекс';

  @override
  String get country => 'Страна';

  @override
  String get ssn => 'Номер социального страхования';

  @override
  String get passportNumber => 'Номер паспорта';

  @override
  String get licenseNumber => 'Номер удостоверения';

  @override
  String get privateKey => 'Приватный ключ';

  @override
  String get publicKey => 'Публичный ключ';

  @override
  String get fingerprint => 'Отпечаток';

  @override
  String get bankName => 'Банк';

  @override
  String get accountHolder => 'Владелец счёта';

  @override
  String get accountType => 'Тип счёта';

  @override
  String get accountNumber => 'Номер счёта';

  @override
  String get routingNumber => 'Маршрутный номер';

  @override
  String get branchNumber => 'Номер отделения';

  @override
  String get pin => 'PIN-код';

  @override
  String get swiftCode => 'Код SWIFT';

  @override
  String get iban => 'IBAN';

  @override
  String get bankPhone => 'Телефон банка';

  @override
  String get accountTypeChecking => 'Текущий счёт';

  @override
  String get accountTypeSavings => 'Сберегательный счёт';

  @override
  String get accountTypeCertificateOfDeposit => 'Депозитный сертификат';

  @override
  String get accountTypeLineOfCredit => 'Кредитная линия';

  @override
  String get accountTypeInvestmentBrokerage => 'Брокерский счёт';

  @override
  String get accountTypeMoneyMarket => 'Счёт денежного рынка';

  @override
  String get accountTypeOther => 'Другой';

  @override
  String get dateOfBirth => 'Дата рождения';

  @override
  String get issuingCountry => 'Страна выдачи';

  @override
  String get issuingState => 'Регион выдачи';

  @override
  String get issueDate => 'Дата выдачи';

  @override
  String get expirationDate => 'Срок действия';

  @override
  String get issuingAuthority => 'Выдавший орган';

  @override
  String get licenseClass => 'Категория';

  @override
  String get surname => 'Фамилия';

  @override
  String get givenName => 'Имя';

  @override
  String get sex => 'Пол';

  @override
  String get birthPlace => 'Место рождения';

  @override
  String get nationality => 'Гражданство';

  @override
  String get passportType => 'Тип';

  @override
  String get nationalId => 'Национальный идентификационный номер';

  @override
  String get filterAllItems => 'Все элементы';

  @override
  String get filterAllShort => 'Все';

  @override
  String get filterFavorites => 'Избранные';

  @override
  String get filterLogins => 'Логины';

  @override
  String get filterSecureNotes => 'Защищённые заметки';

  @override
  String get filterCards => 'Карты';

  @override
  String get filterIdentities => 'Личная информация';

  @override
  String get filterSshKeys => 'Ключи SSH';

  @override
  String get filterBankAccounts => 'Банковские счета';

  @override
  String get filterDriversLicenses => 'Водительские удостоверения';

  @override
  String get filterPassports => 'Паспорта';

  @override
  String get filterTrash => 'Корзина';

  @override
  String get noItemsHere => 'Здесь нет элементов.';

  @override
  String get searchItems => 'Поиск';

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get noSearchResults => 'По вашему запросу ничего не найдено.';

  @override
  String changesNotSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count изменения ещё не отправлены',
      many: '$count изменений ещё не отправлены',
      few: '$count изменения ещё не отправлены',
      one: '$count изменение ещё не отправлено',
    );
    return '$_temp0';
  }

  @override
  String get newItem => 'Новый элемент';

  @override
  String get newLogin => 'Новый логин';

  @override
  String get newCard => 'Новая карта';

  @override
  String get newSecureNote => 'Новая защищённая заметка';

  @override
  String get editItem => 'Изменение элемента';

  @override
  String get edit => 'Изменить';

  @override
  String get save => 'Сохранить';

  @override
  String get itemSaveFailed => 'Не удалось сохранить элемент.';

  @override
  String get vault => 'Хранилище';

  @override
  String get itemName => 'Название';

  @override
  String get itemNameRequired => 'Укажите название элемента.';

  @override
  String get authenticatorKey => 'Ключ аутентификатора';

  @override
  String get authenticatorKeyHint => 'Секрет Base32 или URI otpauth://';

  @override
  String get addWebsite => 'Добавить сайт';

  @override
  String get addField => 'Добавить поле';

  @override
  String get customField => 'Пользовательское поле';

  @override
  String get editField => 'Изменить поле';

  @override
  String get fieldType => 'Тип поля';

  @override
  String get fieldTypeText => 'Текстовое';

  @override
  String get fieldTypeHidden => 'Скрытое';

  @override
  String get fieldTypeCheckbox => 'Флажок';

  @override
  String get fieldTypeLinked => 'Связанное';

  @override
  String get textFieldHelp =>
      'Используйте текстовые поля для таких данных, как контрольные вопросы.';

  @override
  String get hiddenFieldHelp =>
      'Используйте скрытые поля для конфиденциальных данных, например пароля.';

  @override
  String get checkboxFieldHelp =>
      'Используйте флажки для флажков в формах, например для запоминания email.';

  @override
  String get linkedFieldHelp =>
      'Используйте связанное поле, если автозаполнение не справляется с конкретным сайтом.';

  @override
  String get fieldLabel => 'Метка поля';

  @override
  String get linkedFieldLabelHelp =>
      'Введите HTML id, name, aria-label или placeholder поля.';

  @override
  String editFieldNamed(String field) {
    return 'Изменить поле $field';
  }

  @override
  String deleteFieldNamed(String field) {
    return 'Удалить поле $field';
  }

  @override
  String reorderField(String field) {
    return 'Переместить поле $field';
  }

  @override
  String get cardBrandOther => 'Другой';

  @override
  String get cardExpYearHint => 'ГГГГ';

  @override
  String get notSet => 'Не указано';

  @override
  String get favorite => 'Избранный';

  @override
  String get addToFavorites => 'Добавить в избранное';

  @override
  String get removeFromFavorites => 'Удалить из избранного';

  @override
  String get discardChanges => 'Не сохранять изменения?';

  @override
  String get keepEditing => 'Продолжить редактирование';

  @override
  String get discard => 'Не сохранять';

  @override
  String get moreActions => 'Другие действия';

  @override
  String get copyUsername => 'Скопировать имя пользователя';

  @override
  String get copyPassword => 'Скопировать пароль';

  @override
  String get copyTotp => 'Скопировать код подтверждения';

  @override
  String get copyNumber => 'Скопировать номер';

  @override
  String get moveToTrash => 'Отправить в корзину';

  @override
  String get restore => 'Восстановить';

  @override
  String get deletePermanently => 'Удалить окончательно';

  @override
  String get deleteItemTitle => 'Окончательно удалить этот элемент?';

  @override
  String get deleteItemBody =>
      'Он будет стёрт из хранилища на всех устройствах. Это действие нельзя отменить.';

  @override
  String get delete => 'Удалить';

  @override
  String get generatePassword => 'Сгенерировать пароль';

  @override
  String get generateUsername => 'Сгенерировать имя пользователя';

  @override
  String get generator => 'Генератор';

  @override
  String get passphrase => 'Парольная фраза';

  @override
  String get regenerate => 'Сгенерировать заново';

  @override
  String get passwordLength => 'Длина';

  @override
  String get includeCharacters => 'Включить';

  @override
  String get uppercaseLetters => 'Заглавные буквы';

  @override
  String get lowercaseLetters => 'Строчные буквы';

  @override
  String get digits => 'Цифры';

  @override
  String get specialCharacters => 'Специальные символы';

  @override
  String get minNumbers => 'Минимум цифр';

  @override
  String get minSpecial => 'Минимум специальных символов';

  @override
  String get avoidAmbiguous => 'Избегать неоднозначных символов';

  @override
  String get numberOfWords => 'Количество слов';

  @override
  String get wordSeparator => 'Разделитель слов';

  @override
  String get capitalize => 'С заглавной буквы';

  @override
  String get includeNumber => 'Добавить цифру';

  @override
  String get usePassword => 'Использовать этот пароль';

  @override
  String get usePassphrase => 'Использовать эту парольную фразу';

  @override
  String get useUsername => 'Использовать это имя пользователя';

  @override
  String get usernameCapitalize => 'С заглавной буквы';

  @override
  String get usernameIncludeNumber => 'Добавить число';

  @override
  String get decrease => 'Уменьшить';

  @override
  String get increase => 'Увеличить';

  @override
  String get settings => 'Настройки';

  @override
  String get security => 'Безопасность';

  @override
  String get unlockWithBiometrics => 'Разблокировать с помощью биометрии';

  @override
  String get unlockWithBiometricsDescription =>
      'Или с помощью кода либо пароля этого устройства. Ключи хранилищ остаются в его защищённой памяти.';

  @override
  String get lockNeedsScreenLock =>
      'Сначала настройте блокировку экрана на этом устройстве.';

  @override
  String get lockAfter => 'Блокировать через';

  @override
  String get lockImmediately => 'Немедленно';

  @override
  String get lockOnRestart => 'При перезапуске приложения';

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты',
      many: '$count минут',
      few: '$count минуты',
      one: '$count минута',
    );
    return '$_temp0';
  }

  @override
  String hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа',
      many: '$count часов',
      few: '$count часа',
      one: '$count час',
    );
    return '$_temp0';
  }

  @override
  String get clearClipboardAfter => 'Стирать скопированные пароли через';

  @override
  String get never => 'Никогда';

  @override
  String seconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count секунды',
      many: '$count секунд',
      few: '$count секунды',
      one: '$count секунда',
    );
    return '$_temp0';
  }

  @override
  String get allowScreenCapture => 'Разрешить захват экрана';

  @override
  String get allowScreenCaptureDescription =>
      'Ваши пароли будут видны на снимках, записях и при демонстрации экрана.';

  @override
  String get lock => 'Заблокировать';

  @override
  String lockWithShortcut(String shortcut) {
    return 'Заблокировать ($shortcut)';
  }

  @override
  String get unlock => 'Разблокировать';

  @override
  String get vaultsLocked => 'Ваши хранилища заблокированы.';

  @override
  String get unlockReason => 'Разблокировать хранилища';

  @override
  String get enableLockReason => 'Включить блокировку';

  @override
  String get authLockedOut => 'Слишком много попыток. Попробуйте позже.';

  @override
  String get authFailed => 'Устройству не удалось подтвердить, что это вы.';

  @override
  String get vaultTab => 'Хранилище';

  @override
  String get storageReadFailed => 'Не удалось прочитать ваши хранилища.';

  @override
  String get storageReadFailedBody =>
      'Защищённая память этого устройства отказалась их открыть. Ничего не стёрто: попробуйте снова. Ваши элементы остаются в сети, а ключ хранилища открывает его на любом устройстве.';

  @override
  String get tryAgain => 'Повторить';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Системный';

  @override
  String get languageName => 'Русский';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get importExport => 'Импорт и экспорт';

  @override
  String get importFromBitwarden => 'Импорт из Bitwarden';

  @override
  String get importFromBitwardenDescription =>
      'Экспорт из Bitwarden в формате JSON.';

  @override
  String get importButton => 'Импортировать';

  @override
  String get importReadFailed => 'Не удалось прочитать файл.';

  @override
  String get importNotBitwarden =>
      'Этот файл не является экспортом Bitwarden в формате JSON.';

  @override
  String get importEncrypted =>
      'Этот экспорт ограничен вашим аккаунтом Bitwarden, и открыть его может только Bitwarden. Экспортируйте хранилище из Bitwarden ещё раз, с защитой паролем или в формате .json.';

  @override
  String get importEmpty => 'В этом экспорте нет элементов.';

  @override
  String importFound(int count, String file) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'В файле $file найдено $count элемента.',
      many: 'В файле $file найдено $count элементов.',
      few: 'В файле $file найдено $count элемента.',
      one: 'В файле $file найден $count элемент.',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return 'Импортировано элементов: $done из $total';
  }

  @override
  String importDone(int count, String vault) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'В хранилище $vault импортировано $count элемента.',
      many: 'В хранилище $vault импортировано $count элементов.',
      few: 'В хранилище $vault импортировано $count элемента.',
      one: 'В хранилище $vault импортирован $count элемент.',
    );
    return '$_temp0';
  }

  @override
  String importFailed(int done, int total) {
    return 'Импорт прерван. Сохранено элементов: $done из $total.';
  }

  @override
  String get exportVault => 'Экспорт хранилища';

  @override
  String get exportVaultDescription =>
      'Файл JSON в формате Bitwarden, защищённый паролем или незашифрованный.';

  @override
  String get exportButton => 'Экспортировать';

  @override
  String exportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элемента. Корзина не экспортируется.',
      many: '$count элементов. Корзина не экспортируется.',
      few: '$count элемента. Корзина не экспортируется.',
      one: '$count элемент. Корзина не экспортируется.',
      zero: 'В этом хранилище нет элементов для экспорта.',
    );
    return '$_temp0';
  }

  @override
  String get exportWarning =>
      'Файл не зашифрован. Не отправляйте его по электронной почте и удалите, когда он больше не будет нужен.';

  @override
  String get exportFailed => 'Не удалось сохранить файл.';

  @override
  String get importPasswordBody =>
      'Этот экспорт защищён паролем. Введите его, чтобы открыть файл.';

  @override
  String get filePassword => 'Пароль к файлу';

  @override
  String get wrongFilePassword => 'Этот пароль не подходит к файлу.';

  @override
  String get exportProtect => 'Защитить паролем';

  @override
  String get confirmFilePassword => 'Подтвердите пароль к файлу';

  @override
  String get filePasswordHelper =>
      'Submarine и Bitwarden запросят его при импорте файла. Восстановить его нельзя.';

  @override
  String get filePasswordRequired => 'Придумайте пароль.';

  @override
  String get filePasswordMismatch => 'Пароли не совпадают.';

  @override
  String get lockPassword => 'Пароль блокировки';

  @override
  String get lockPasswordDescription =>
      'Шифрует ключи хранилищ на этом устройстве и разблокирует приложение. Восстановить его нельзя.';

  @override
  String get setLockPassword => 'Задать';

  @override
  String get changeLockPassword => 'Изменить';

  @override
  String get removeLockPassword => 'Удалить';

  @override
  String get setLockPasswordTitle => 'Задать пароль блокировки';

  @override
  String get changeLockPasswordTitle => 'Изменить пароль блокировки';

  @override
  String get removeLockPasswordTitle => 'Удалить пароль блокировки';

  @override
  String get removeLockPasswordBody =>
      'Приложение больше не будет его запрашивать. Безопасность ключей хранилищ на этом устройстве будет зависеть только от его защищённой памяти.';

  @override
  String get currentLockPassword => 'Текущий пароль';

  @override
  String get newLockPassword => 'Новый пароль';

  @override
  String get confirmLockPassword => 'Подтвердите пароль';

  @override
  String lockPasswordHelper(int count) {
    return 'Не менее $count символов. Если вы его забудете, хранилища будут удалены с этого устройства.';
  }

  @override
  String lockPasswordTooShort(int count) {
    return 'Не менее $count символов.';
  }

  @override
  String get lockPasswordMismatch => 'Пароли не совпадают.';

  @override
  String get wrongLockPassword => 'Неверный пароль блокировки.';

  @override
  String get generatePassphrase => 'Сгенерировать парольную фразу';

  @override
  String get unlockWithBiometricsWithPassword =>
      'Вместо ввода пароля блокировки, который продолжит работать.';

  @override
  String get forgotLockPassword => 'Забыли пароль?';

  @override
  String get forgetVaultsTitle => 'Удалить хранилища с этого устройства?';

  @override
  String get forgetVaultsBody =>
      'Без пароля блокировки их не расшифровать на этом устройстве. Ваши элементы остаются в сети: откройте каждое хранилище заново с помощью его ключа.';

  @override
  String get forgetVaults => 'Удалить хранилища';

  @override
  String get removeVault => 'Удалить с этого устройства';

  @override
  String get removeVaultDescription =>
      'Хранилище останется в сети, и вы сможете открыть его снова.';

  @override
  String removeVaultTitle(String name) {
    return 'Удалить хранилище $name с этого устройства?';
  }

  @override
  String get removeVaultBody =>
      'Ваши элементы останутся в сети: откройте хранилище снова, чтобы их вернуть.';

  @override
  String get removeVaultKeyWarning =>
      'Сначала сохраните его ключ: без него вы не сможете снова открыть хранилище.';

  @override
  String removeVaultUnsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count изменения ещё не отправлены и будут потеряны.',
      many: '$count изменений ещё не отправлены и будут потеряны.',
      few: '$count изменения ещё не отправлены и будут потеряны.',
      one: '$count изменение ещё не отправлено и будет потеряно.',
    );
    return '$_temp0';
  }

  @override
  String get removeVaultConfirm => 'Удалить';

  @override
  String get removeVaultFailed => 'Не удалось удалить хранилище.';
}
