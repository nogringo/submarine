// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get allVaults => '所有密码库';

  @override
  String get vaults => '密码库';

  @override
  String get addVault => '添加密码库';

  @override
  String get createVault => '创建密码库';

  @override
  String get createVaultDescription => '一个全新的空密码库，拥有自己的密钥。';

  @override
  String get openVault => '打开密码库';

  @override
  String get openVaultDescription => '来自其他设备，或由他人共享给您。';

  @override
  String get openVaultTitle => '打开密码库';

  @override
  String get vaultName => '名称';

  @override
  String get vaultNameHelper => '仅用于此设备。与您共享此密码库的人可以自行命名。';

  @override
  String get vaultNameRequired => '请为密码库命名。';

  @override
  String get vaultColor => '颜色';

  @override
  String vaultColorOption(int number) {
    return '颜色 $number';
  }

  @override
  String get vaultKey => '密码库密钥';

  @override
  String get vaultKeyInvalid => '这不是密码库密钥。';

  @override
  String vaultAlreadyOpen(String name) {
    return '此密码库已经打开，名称为 $name。';
  }

  @override
  String get vaultSaveFailed => '无法在此设备上保存密码库。';

  @override
  String get saveVaultKeyTitle => '保存密码库密钥';

  @override
  String get saveVaultKeyBody =>
      '任何拥有此密钥的人都能打开此密码库。请将它保存在安全的地方：在其他设备上打开此密码库或共享它时，都需要用到它。';

  @override
  String get vaultSettings => '密码库设置';

  @override
  String get vaultNameAndColor => '名称和颜色';

  @override
  String get vaultPublicKey => '公钥';

  @override
  String get vaultKeyDescription =>
      '任何拥有它的人都能打开此密码库。在其他设备上输入它即可在该设备上打开密码库，或将它交给他人以共享此密码库。';

  @override
  String get vaultKeyHelper => '创建密码库时保存的密钥，或他人与您共享的密钥。';

  @override
  String get vaultKeyPassword => '密钥密码';

  @override
  String get vaultKeyPasswordWrong => '此密码无法解密该密钥。';

  @override
  String get vaultKeyDecrypting => '正在解密密钥';

  @override
  String get otherWaysToOpen => '其他打开方式';

  @override
  String get signersDescription =>
      '使用签名器打开，由它在 Submarine 之外保管密钥。bunker:// 地址也可以直接填入密钥字段。';

  @override
  String get browserExtension => '浏览器扩展';

  @override
  String get signerApp => '签名应用';

  @override
  String get bunker => '远程签名器';

  @override
  String get nostrConnect => 'Nostr Connect';

  @override
  String get nostrConnectBody => '使用您的远程签名器或签名应用扫描此二维码，或将地址粘贴到其中。';

  @override
  String get noBrowserExtension => '此浏览器中没有 Nostr 扩展。';

  @override
  String get noSignerApp => '此设备上没有安装签名应用（例如 Amber）。';

  @override
  String get signerRefused => '请求被拒绝。';

  @override
  String get waitingForAnswer => '正在等待响应';

  @override
  String get bunkerUrlInvalid => '此远程签名器地址缺少中继或 secret 参数。';

  @override
  String get bunkerNoAnswer => '远程签名器没有响应。';

  @override
  String get bunkerApproval => '远程签名器要求您在其页面上批准 Submarine。';

  @override
  String get openApprovalPage => '打开页面';

  @override
  String get nothingConnected => '等待超时，没有签名器连接。';

  @override
  String get useAnotherKey => '使用其他密钥';

  @override
  String get vaultSignerDescription =>
      '保管密码库密钥，密钥绝不会进入 Submarine。在其他设备上，请用同样的方式打开此密码库。';

  @override
  String get askSignerAtStart => '每次启动时询问签名器';

  @override
  String get askSignerAtStartDescription =>
      '关闭时，即使无法连接签名器，保存在此设备上的密钥也能读取密码库。开启时，密码库会保持关闭，直到签名器将其打开。';

  @override
  String get askSignerFailed => '签名器拒绝了请求，或操作失败。';

  @override
  String signerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个请求等待您的签名器处理',
      one: '1 个请求等待您的签名器处理',
    );
    return '$_temp0';
  }

  @override
  String get signerRequestsTitle => '正在等待您的签名器';

  @override
  String get signerRequestsDescription => '请在您的签名器中批准这些请求，或取消它们。';

  @override
  String get requestOpenVault => '打开密码库';

  @override
  String get requestLockVault => '用签名器锁定密码库';

  @override
  String requestDecryptVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '解密项目的 $count 个版本',
      one: '解密项目的一个版本',
    );
    return '$_temp0';
  }

  @override
  String requestSaveVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '保存项目的 $count 个版本',
      one: '保存项目的一个版本',
    );
    return '$_temp0';
  }

  @override
  String requestDeleteVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '永久删除项目的 $count 个版本',
      one: '永久删除项目的一个版本',
    );
    return '$_temp0';
  }

  @override
  String get requestSaveRelays => '保存中继列表';

  @override
  String get requestReadRelays => '读取私密中继';

  @override
  String get requestEncryptRelays => '加密私密中继';

  @override
  String requestRelayAuth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '登录 $count 个中继',
      one: '登录一个中继',
    );
    return '$_temp0';
  }

  @override
  String requestOther(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个其他请求（$method）',
      one: '其他请求（$method）',
    );
    return '$_temp0';
  }

  @override
  String get cancelAll => '全部取消';

  @override
  String get close => '关闭';

  @override
  String get sync => '同步';

  @override
  String get syncAllSent => '所有更改均已保存到线上。';

  @override
  String get relays => '中继';

  @override
  String get relaysDescription => '此密码库会复制到以下每个中继。它们只能看到加密数据和密码库的公钥。';

  @override
  String get relayConnected => '已连接';

  @override
  String get relayNotConnected => '未连接';

  @override
  String get relayPrivate => '私密';

  @override
  String get removeRelay => '移除此中继';

  @override
  String get addRelay => '添加中继';

  @override
  String get relayAddress => '中继地址';

  @override
  String get relayAddressInvalid => '这不是有效的中继地址。';

  @override
  String get relayAlreadyListed => '此中继已在列表中。';

  @override
  String get relayKeepPrivate => '保持私密';

  @override
  String get relayKeepPrivateDescription =>
      '在密码库的中继列表中加密保存：只有拥有密码库密钥的人才知道密码库位于此中继上。';

  @override
  String get relaysSaveFailed => '无法保存中继。';

  @override
  String get relaysWaitForSync => '密码库同步完成后，您才能更改中继。';

  @override
  String get relayAdded => '新增';

  @override
  String get relayRemoved => '已移除';

  @override
  String get keepRelay => '保留此中继';

  @override
  String get relaysNeedOne => '密码库至少需要一个中继。';

  @override
  String get fileServers => '文件服务器';

  @override
  String get fileServersDescription => '附加到此密码库的文件会复制到以下每个服务器。它们只能看到加密的文件。';

  @override
  String get serverPrivate => '私密';

  @override
  String get removeServer => '移除此服务器';

  @override
  String get keepServer => '保留此服务器';

  @override
  String get addServer => '添加服务器';

  @override
  String get serverAddress => '服务器地址';

  @override
  String get serverAddressInvalid => '这不是有效的服务器地址。';

  @override
  String get serverAlreadyListed => '此服务器已在列表中。';

  @override
  String get serverKeepPrivate => '保持私密';

  @override
  String get serverKeepPrivateDescription =>
      '在密码库的服务器列表中加密保存：只有拥有密码库密钥的人才知道密码库使用此服务器。';

  @override
  String get serversSaveFailed => '无法保存服务器。';

  @override
  String get serversWaitForSync => '密码库同步完成后，您才能更改服务器。';

  @override
  String get serverAdded => '新增';

  @override
  String get serverRemoved => '已移除';

  @override
  String get serversNeedOne => '密码库至少需要一个服务器。';

  @override
  String get add => '添加';

  @override
  String get cancel => '取消';

  @override
  String get create => '创建';

  @override
  String get open => '打开';

  @override
  String get done => '完成';

  @override
  String get welcomeTagline => '您的密码，加密保存，多端同步。无需注册账户。';

  @override
  String get builtOnNostr => '基于 Nostr 构建';

  @override
  String get builtOnNostrBody =>
      '您的密码库存放在 Nostr 中继上：这些开放的服务器任何人都可以运行，而且它们只能看到加密数据。密码库密钥就是 Nostr 密钥，因此可以由 Nostr 签名器保管。';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个项目',
      one: '1 个项目',
      zero: '没有项目',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => '立即同步';

  @override
  String get syncing => '正在同步';

  @override
  String get syncNever => '从未同步';

  @override
  String get syncFailed => '同步失败';

  @override
  String get signerDidNotOpen => '签名器未打开密码库';

  @override
  String get syncedJustNow => '刚刚同步';

  @override
  String syncedMinutesAgo(int minutes) {
    return '$minutes 分钟前同步';
  }

  @override
  String syncedHoursAgo(int hours) {
    return '$hours 小时前同步';
  }

  @override
  String syncedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '同步于 $dateString';
  }

  @override
  String get noItems => '此密码库中还没有项目。';

  @override
  String get lookingForItems => '正在查找您的项目';

  @override
  String get signerDidNotOpenVault => '签名器未打开此密码库。同步即可再次请求。';

  @override
  String get selectItem => '选择一个项目，即可在此处查看。';

  @override
  String get itemNotFound => '此项目已不在密码库中。';

  @override
  String get typeLogin => '登录';

  @override
  String get typeSecureNote => '安全笔记';

  @override
  String get typeCard => '支付卡';

  @override
  String get typeIdentity => '身份';

  @override
  String get typeSshKey => 'SSH 密钥';

  @override
  String get typeBankAccount => '银行账户';

  @override
  String get typeDriversLicense => '驾驶证';

  @override
  String get typePassport => '护照';

  @override
  String get typeUnknown => '项目';

  @override
  String get copy => '复制';

  @override
  String get copied => '已复制';

  @override
  String get show => '显示';

  @override
  String get hide => '隐藏';

  @override
  String get hiddenValue => '已隐藏的值';

  @override
  String get openWebsite => '打开网站';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get verificationCode => '验证码';

  @override
  String get totpInvalid => '无法读取此验证器密钥。';

  @override
  String get website => '网站';

  @override
  String get passkey => '通行密钥';

  @override
  String passkeyCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '创建于 $dateString';
  }

  @override
  String get notes => '备注';

  @override
  String get customFields => '自定义字段';

  @override
  String get passwordHistory => '密码历史记录';

  @override
  String itemDates(DateTime updated, DateTime created) {
    final intl.DateFormat updatedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String updatedString = updatedDateFormat.format(updated);
    final intl.DateFormat createdDateFormat = intl.DateFormat.yMMMd(localeName);
    final String createdString = createdDateFormat.format(created);

    return '更新于 $updatedString，创建于 $createdString';
  }

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String linkedTo(String field) {
    return '链接到 $field';
  }

  @override
  String get cardholderName => '持卡人姓名';

  @override
  String get cardBrand => '品牌';

  @override
  String get cardNumber => '卡号';

  @override
  String get cardExpiration => '有效期';

  @override
  String get cardExpMonth => '过期月份';

  @override
  String get cardExpYear => '过期年份';

  @override
  String get cardCode => '安全码';

  @override
  String get fullName => '姓名';

  @override
  String get identityTitle => '称谓';

  @override
  String get firstName => '名字';

  @override
  String get middleName => '中间名';

  @override
  String get lastName => '姓氏';

  @override
  String get company => '公司';

  @override
  String get email => '电子邮箱';

  @override
  String get phone => '电话';

  @override
  String get address => '地址';

  @override
  String get city => '城市';

  @override
  String get state => '州 / 省 / 地区';

  @override
  String get postalCode => '邮政编码';

  @override
  String get country => '国家 / 地区';

  @override
  String get ssn => '社会保障号码';

  @override
  String get passportNumber => '护照号码';

  @override
  String get licenseNumber => '驾驶证号码';

  @override
  String get privateKey => '私钥';

  @override
  String get publicKey => '公钥';

  @override
  String get fingerprint => '指纹';

  @override
  String get bankName => '银行名称';

  @override
  String get accountHolder => '账户持有人';

  @override
  String get accountType => '账户类型';

  @override
  String get accountNumber => '账户号码';

  @override
  String get routingNumber => '路由号码';

  @override
  String get branchNumber => '分行号码';

  @override
  String get pin => 'PIN 码';

  @override
  String get swiftCode => 'SWIFT 代码';

  @override
  String get iban => 'IBAN';

  @override
  String get bankPhone => '银行电话';

  @override
  String get accountTypeChecking => '支票';

  @override
  String get accountTypeSavings => '储蓄';

  @override
  String get accountTypeCertificateOfDeposit => '定期存款';

  @override
  String get accountTypeLineOfCredit => '信用额度';

  @override
  String get accountTypeInvestmentBrokerage => '证券';

  @override
  String get accountTypeMoneyMarket => '货币市场';

  @override
  String get accountTypeOther => '其他';

  @override
  String get dateOfBirth => '出生日期';

  @override
  String get issuingCountry => '签发国家 / 地区';

  @override
  String get issuingState => '签发州 / 省 / 地区';

  @override
  String get issueDate => '签发日期';

  @override
  String get expirationDate => '到期日期';

  @override
  String get issuingAuthority => '签发机构';

  @override
  String get licenseClass => '准驾车型';

  @override
  String get surname => '姓';

  @override
  String get givenName => '名';

  @override
  String get sex => '性别';

  @override
  String get birthPlace => '出生地点';

  @override
  String get nationality => '国籍';

  @override
  String get passportType => '类型';

  @override
  String get nationalId => '身份证号码';

  @override
  String get filterAllItems => '所有项目';

  @override
  String get filterAllShort => '全部';

  @override
  String get filterFavorites => '收藏夹';

  @override
  String get filterLogins => '登录';

  @override
  String get filterSecureNotes => '安全笔记';

  @override
  String get filterCards => '支付卡';

  @override
  String get filterIdentities => '身份';

  @override
  String get filterSshKeys => 'SSH 密钥';

  @override
  String get filterBankAccounts => '银行账户';

  @override
  String get filterDriversLicenses => '驾驶证';

  @override
  String get filterPassports => '护照';

  @override
  String get filterTrash => '回收站';

  @override
  String get noItemsHere => '这里没有项目。';

  @override
  String get searchItems => '搜索';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get noSearchResults => '没有与搜索匹配的项目。';

  @override
  String changesNotSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项更改尚未发送',
      one: '1 项更改尚未发送',
    );
    return '$_temp0';
  }

  @override
  String get newItem => '新增项目';

  @override
  String get newLogin => '新增登录';

  @override
  String get newCard => '新增支付卡';

  @override
  String get newSecureNote => '新增安全笔记';

  @override
  String get editItem => '编辑项目';

  @override
  String get edit => '编辑';

  @override
  String get save => '保存';

  @override
  String get itemSaveFailed => '无法保存项目。';

  @override
  String get vault => '密码库';

  @override
  String get itemName => '名称';

  @override
  String get itemNameRequired => '请为项目命名。';

  @override
  String get authenticatorKey => '验证器密钥';

  @override
  String get authenticatorKeyHint => 'Base32 密钥或 otpauth:// URI';

  @override
  String get addWebsite => '添加网站';

  @override
  String get addField => '添加字段';

  @override
  String get customField => '自定义字段';

  @override
  String get editField => '编辑字段';

  @override
  String get fieldType => '字段类型';

  @override
  String get fieldTypeText => '文本型';

  @override
  String get fieldTypeHidden => '隐藏型';

  @override
  String get fieldTypeCheckbox => '复选框型';

  @override
  String get fieldTypeLinked => '链接型';

  @override
  String get textFieldHelp => '文本型字段适用于安全问题等数据。';

  @override
  String get hiddenFieldHelp => '隐藏型字段适用于密码等敏感数据。';

  @override
  String get checkboxFieldHelp => '复选框型字段用于勾选表单中的复选框，例如记住电子邮箱。';

  @override
  String get linkedFieldHelp => '当自动填充在特定网站上出现问题时，请使用链接型字段。';

  @override
  String get fieldLabel => '字段标签';

  @override
  String get linkedFieldLabelHelp => '输入字段的 HTML id、name、aria-label 或占位符。';

  @override
  String editFieldNamed(String field) {
    return '编辑 $field';
  }

  @override
  String deleteFieldNamed(String field) {
    return '删除 $field';
  }

  @override
  String reorderField(String field) {
    return '移动 $field';
  }

  @override
  String get cardBrandOther => '其他';

  @override
  String get cardExpYearHint => 'YYYY';

  @override
  String get notSet => '未设置';

  @override
  String get favorite => '收藏';

  @override
  String get addToFavorites => '添加到收藏夹';

  @override
  String get removeFromFavorites => '从收藏夹中移除';

  @override
  String get discardChanges => '要放弃更改吗？';

  @override
  String get keepEditing => '继续编辑';

  @override
  String get discard => '放弃';

  @override
  String get moreActions => '更多操作';

  @override
  String get copyUsername => '复制用户名';

  @override
  String get copyPassword => '复制密码';

  @override
  String get copyTotp => '复制验证码';

  @override
  String get copyNumber => '复制卡号';

  @override
  String get moveToTrash => '移至回收站';

  @override
  String get restore => '恢复';

  @override
  String get deletePermanently => '永久删除';

  @override
  String get deleteItemTitle => '要永久删除此项目吗？';

  @override
  String get deleteItemBody => '它将从所有设备上的密码库中清除。此操作无法撤销。';

  @override
  String get delete => '删除';

  @override
  String get generatePassword => '生成密码';

  @override
  String get generateUsername => '生成用户名';

  @override
  String get generator => '生成器';

  @override
  String get passphrase => '密码短语';

  @override
  String get regenerate => '重新生成';

  @override
  String get passwordLength => '长度';

  @override
  String characterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个字符',
    );
    return '$_temp0';
  }

  @override
  String get includeCharacters => '包含';

  @override
  String get uppercaseLetters => '大写字母';

  @override
  String get lowercaseLetters => '小写字母';

  @override
  String get digits => '数字';

  @override
  String get specialCharacters => '特殊字符';

  @override
  String get minNumbers => '数字最少个数';

  @override
  String get minSpecial => '特殊字符最少个数';

  @override
  String get avoidAmbiguous => '避免易混淆的字符';

  @override
  String get numberOfWords => '单词个数';

  @override
  String get wordSeparator => '单词分隔符';

  @override
  String get capitalize => '首字母大写';

  @override
  String get includeNumber => '包含数字';

  @override
  String get usePassword => '使用此密码';

  @override
  String get usePassphrase => '使用此密码短语';

  @override
  String get useUsername => '使用此用户名';

  @override
  String get usernameCapitalize => '首字母大写';

  @override
  String get usernameIncludeNumber => '包含数字';

  @override
  String get decrease => '减少';

  @override
  String get increase => '增加';

  @override
  String get settings => '设置';

  @override
  String get security => '安全';

  @override
  String get unlockWithBiometrics => '使用生物识别解锁';

  @override
  String get unlockWithBiometricsDescription =>
      '也可以使用此设备的 PIN 码或密码解锁。密码库密钥仍保存在设备的安全存储中。';

  @override
  String get lockNeedsScreenLock => '请先为此设备设置锁屏。';

  @override
  String get lockAfter => '自动锁定';

  @override
  String get lockImmediately => '立即';

  @override
  String get lockOnRestart => '应用重启时';

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分钟',
      one: '1 分钟',
    );
    return '$_temp0';
  }

  @override
  String hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 小时',
      one: '1 小时',
    );
    return '$_temp0';
  }

  @override
  String get clearClipboardAfter => '自动清除已复制的密码';

  @override
  String get never => '从不';

  @override
  String seconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 秒',
      one: '1 秒',
    );
    return '$_temp0';
  }

  @override
  String get allowScreenCapture => '允许截屏';

  @override
  String get allowScreenCaptureDescription => '开启后，截屏、录屏和屏幕共享中会显示您的密码。';

  @override
  String get lock => '锁定';

  @override
  String lockWithShortcut(String shortcut) {
    return '锁定（$shortcut）';
  }

  @override
  String get unlock => '解锁';

  @override
  String get vaultsLocked => '您的密码库已锁定。';

  @override
  String get unlockReason => '解锁您的密码库';

  @override
  String get enableLockReason => '启用锁定';

  @override
  String get authLockedOut => '尝试次数过多。请稍后再试。';

  @override
  String get authFailed => '此设备无法验证您的身份。';

  @override
  String get vaultTab => '密码库';

  @override
  String get storageReadFailed => '无法读取您的密码库。';

  @override
  String get storageReadFailedBody =>
      '此设备的安全存储拒绝打开它们。没有任何数据被清除，请重试。您的项目仍保存在线上，凭密码库密钥即可在任何设备上打开密码库。';

  @override
  String get tryAgain => '重试';

  @override
  String get appearance => '外观';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageName => '简体中文';

  @override
  String get theme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get importExport => '导入与导出';

  @override
  String get importFromBitwarden => '从 Bitwarden 导入';

  @override
  String get importFromBitwardenDescription => 'Bitwarden 导出的 JSON 文件。';

  @override
  String get importButton => '导入';

  @override
  String get importReadFailed => '无法读取该文件。';

  @override
  String get importNotBitwarden => '此文件不是 Bitwarden 导出的 JSON 文件。';

  @override
  String get importEncrypted =>
      '此导出文件仅限您的 Bitwarden 账户使用，只有 Bitwarden 能打开。请从 Bitwarden 重新导出密码库，选择密码保护或 .json 格式。';

  @override
  String get importEmpty => '此导出文件中没有项目。';

  @override
  String importFound(int count, String file) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '在 $file 中找到 $count 个项目。',
      one: '在 $file 中找到 1 个项目。',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return '已导入 $done / $total 个项目';
  }

  @override
  String importDone(int count, String vault) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已将 $count 个项目导入 $vault。',
      one: '已将 1 个项目导入 $vault。',
    );
    return '$_temp0';
  }

  @override
  String importFailed(int done, int total) {
    return '导入已中断：$total 个项目中已保存 $done 个。';
  }

  @override
  String get exportVault => '导出密码库';

  @override
  String get exportVaultDescription => 'Bitwarden JSON 文件，可用密码保护，也可不加密。';

  @override
  String get exportButton => '导出';

  @override
  String exportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个项目。回收站中的项目不会导出。',
      one: '1 个项目。回收站中的项目不会导出。',
      zero: '此密码库中没有可导出的项目。',
    );
    return '$_temp0';
  }

  @override
  String get exportWarning => '此文件未加密。请勿通过电子邮件发送，使用完后请立即删除。';

  @override
  String get exportFailed => '无法保存文件。';

  @override
  String get importPasswordBody => '此导出文件受密码保护。请输入密码以打开文件。';

  @override
  String get filePassword => '文件密码';

  @override
  String get wrongFilePassword => '此密码无法打开该文件。';

  @override
  String get exportProtect => '使用密码保护';

  @override
  String get confirmFilePassword => '确认文件密码';

  @override
  String get filePasswordHelper => 'Submarine 和 Bitwarden 导入此文件时需要此密码。密码无法找回。';

  @override
  String get filePasswordRequired => '请设置一个密码。';

  @override
  String get filePasswordMismatch => '两次输入的密码不一致。';

  @override
  String get lockPassword => '锁定密码';

  @override
  String get lockPasswordDescription => '用于加密此设备上的密码库密钥，并解锁应用。此密码无法找回。';

  @override
  String get setLockPassword => '设置';

  @override
  String get changeLockPassword => '更改';

  @override
  String get removeLockPassword => '移除';

  @override
  String get setLockPasswordTitle => '设置锁定密码';

  @override
  String get changeLockPasswordTitle => '更改锁定密码';

  @override
  String get removeLockPasswordTitle => '移除锁定密码';

  @override
  String get removeLockPasswordBody => '应用将不再要求输入此密码。此设备上的密码库密钥将仅受设备安全存储的保护。';

  @override
  String get currentLockPassword => '当前密码';

  @override
  String get newLockPassword => '新密码';

  @override
  String get confirmLockPassword => '确认密码';

  @override
  String lockPasswordHelper(int count) {
    return '至少 $count 个字符。忘记此密码将导致密码库从此设备中移除。';
  }

  @override
  String lockPasswordTooShort(int count) {
    return '至少需要 $count 个字符。';
  }

  @override
  String get lockPasswordMismatch => '两次输入的密码不一致。';

  @override
  String get wrongLockPassword => '锁定密码不正确。';

  @override
  String get generatePassphrase => '生成密码短语';

  @override
  String get unlockWithBiometricsWithPassword => '无需输入锁定密码，但锁定密码仍可使用。';

  @override
  String get forgotLockPassword => '忘记密码？';

  @override
  String get forgetVaultsTitle => '要从此设备移除密码库吗？';

  @override
  String get forgetVaultsBody =>
      '没有锁定密码，就无法在此设备上解密它们。您的项目仍保存在线上：请用各自的密钥重新打开每个密码库。';

  @override
  String get forgetVaults => '移除密码库';

  @override
  String get removeVault => '从此设备移除';

  @override
  String get removeVaultDescription => '密码库仍保存在线上，您可以再次打开它。';

  @override
  String removeVaultTitle(String name) {
    return '要从此设备移除 $name 吗？';
  }

  @override
  String get removeVaultBody => '您的项目仍保存在线上：再次打开此密码库即可找回它们。';

  @override
  String get removeVaultKeyWarning => '请先保存好它的密钥：没有密钥，您将无法再次打开此密码库。';

  @override
  String removeVaultUnsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项更改尚未发送，将会丢失。',
      one: '1 项更改尚未发送，将会丢失。',
    );
    return '$_temp0';
  }

  @override
  String get removeVaultConfirm => '移除';

  @override
  String get removeVaultFailed => '无法移除密码库。';

  @override
  String get emailSettings => '邮件';

  @override
  String get mailBridge => '邮件桥接';

  @override
  String mailBridgeDescription(String domain) {
    return '新的邮箱地址以 @$domain 结尾';
  }

  @override
  String get changeMailBridge => '更改';

  @override
  String get mailBridgeDomain => '域名';

  @override
  String get mailBridgeExplanation => '从现在起创建的邮箱地址以此域名结尾。之前创建的地址保持不变。';

  @override
  String get mailBridgeInvalid => '这不是一个域名。';

  @override
  String get emailAddressField => '邮箱地址';

  @override
  String get mailboxKey => '邮箱密钥';

  @override
  String get inbox => '收件箱';

  @override
  String get inboxFetching => '正在获取消息';

  @override
  String get inboxEmpty => '还没有消息';

  @override
  String get noSubject => '(无主题)';

  @override
  String get privateMessage => '私信';

  @override
  String get emailDownloadFailed => '无法下载此邮件。';

  @override
  String get refreshInbox => '刷新';

  @override
  String get mailInboxRelays => '收件中继';

  @override
  String get mailInboxRelaysExplanation => '发送到新地址的邮件会到达这些中继。之前创建的地址保持不变。';

  @override
  String get mailAddressRelays => '地址中继';

  @override
  String get mailAddressRelaysExplanation =>
      '新地址在这些中继上发布其收件中继，桥接在那里找到它们。之前创建的地址保持不变。';

  @override
  String get changeMailRelays => '更改';

  @override
  String get mailRelaysNeedOne => '新地址至少需要一个中继。';

  @override
  String get resetMailRelays => '重置';
}
