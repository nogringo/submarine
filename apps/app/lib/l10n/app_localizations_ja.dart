// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get allVaults => 'すべての保管庫';

  @override
  String get vaults => '保管庫';

  @override
  String get addVault => '保管庫を追加';

  @override
  String get createVault => '保管庫を作成';

  @override
  String get createVaultDescription => '専用の鍵を持つ、空の保管庫を新しく作成します。';

  @override
  String get openVault => '保管庫を開く';

  @override
  String get openVaultDescription => '別のデバイスで使っている保管庫や、共有された保管庫を開きます。';

  @override
  String get openVaultTitle => '保管庫を開く';

  @override
  String get vaultName => '名前';

  @override
  String get vaultNameHelper => 'このデバイスでのみ有効です。保管庫を共有した相手は、それぞれ自分で名前を付けます。';

  @override
  String get vaultNameRequired => '保管庫の名前を入力してください。';

  @override
  String get vaultColor => '色';

  @override
  String vaultColorOption(int number) {
    return '色 $number';
  }

  @override
  String get vaultKey => '保管庫の鍵';

  @override
  String get vaultKeyInvalid => '保管庫の鍵ではありません。';

  @override
  String vaultAlreadyOpen(String name) {
    return 'この保管庫は $name という名前ですでに開いています。';
  }

  @override
  String get vaultSaveFailed => '保管庫をこのデバイスに保存できませんでした。';

  @override
  String get saveVaultKeyTitle => '保管庫の鍵を保存してください';

  @override
  String get saveVaultKeyBody =>
      'この鍵を持っている人は誰でも保管庫を開けます。安全な場所に保管してください。別のデバイスで保管庫を開くときや、保管庫を共有するときに必要です。';

  @override
  String get vaultSettings => '保管庫の設定';

  @override
  String get vaultNameAndColor => '名前と色';

  @override
  String get vaultPublicKey => '公開鍵';

  @override
  String get vaultKeyDescription =>
      'この鍵を持っている人は誰でもこの保管庫を開けます。別のデバイスで入力するとそこで保管庫を開けるほか、相手に渡して保管庫を共有することもできます。';

  @override
  String get vaultKeyHelper => '保管庫の作成時に保存した鍵か、共有された鍵を入力します。';

  @override
  String get vaultKeyPassword => '鍵のパスワード';

  @override
  String get vaultKeyPasswordWrong => 'このパスワードでは鍵を開けません。';

  @override
  String get vaultKeyDecrypting => '鍵を復号しています';

  @override
  String get otherWaysToOpen => 'その他の開き方';

  @override
  String get signersDescription =>
      '鍵を Submarine の外で管理する外部署名を使って開きます。bunker:// アドレスは鍵の欄にも入力できます。';

  @override
  String get browserExtension => 'ブラウザ拡張機能';

  @override
  String get signerApp => '署名アプリ';

  @override
  String get bunker => 'リモート署名';

  @override
  String get nostrConnect => 'Nostr Connect';

  @override
  String get nostrConnectBody => 'このコードをリモート署名や署名アプリでスキャンするか、アドレスを貼り付けてください。';

  @override
  String get noBrowserExtension => 'このブラウザには Nostr 拡張機能がありません。';

  @override
  String get noSignerApp => 'このデバイスには Amber などの署名アプリがありません。';

  @override
  String get signerRefused => 'リクエストが拒否されました。';

  @override
  String get waitingForAnswer => '応答を待っています';

  @override
  String get bunkerUrlInvalid => 'この bunker:// アドレスには、リレーまたはシークレットが含まれていません。';

  @override
  String get bunkerNoAnswer => 'リモート署名から応答がありませんでした。';

  @override
  String get bunkerApproval => 'リモート署名のページで Submarine を承認するよう求められています。';

  @override
  String get openApprovalPage => 'ページを開く';

  @override
  String get nothingConnected => '時間内に接続されませんでした。';

  @override
  String get useAnotherKey => '別の鍵を使う';

  @override
  String get vaultSignerDescription =>
      '保管庫の鍵を管理しています。鍵が Submarine に渡ることはありません。別のデバイスでも、同じ方法で保管庫を開いてください。';

  @override
  String get askSignerAtStart => '起動のたびに外部署名で開く';

  @override
  String get askSignerAtStartDescription =>
      'オフの場合、外部署名に接続できなくても、このデバイスに保存した鍵で保管庫を読み込めます。オンの場合、外部署名が開くまで保管庫は閉じたままです。';

  @override
  String get askSignerFailed => '外部署名が拒否したか、失敗しました。';

  @override
  String signerWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '外部署名で承認待ちのリクエストが $count 件あります',
      one: '外部署名で承認待ちのリクエストが 1 件あります',
    );
    return '$_temp0';
  }

  @override
  String get signerRequestsTitle => '外部署名の応答待ち';

  @override
  String get signerRequestsDescription => '外部署名でこれらのリクエストを承認するか、キャンセルしてください。';

  @override
  String get requestOpenVault => '保管庫を開く';

  @override
  String get requestLockVault => '保管庫を外部署名でロックする';

  @override
  String requestDecryptVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'アイテムのバージョンを $count 件復号する',
      one: 'アイテムのバージョンを 1 件復号する',
    );
    return '$_temp0';
  }

  @override
  String requestSaveVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'アイテムのバージョンを $count 件保存する',
      one: 'アイテムのバージョンを 1 件保存する',
    );
    return '$_temp0';
  }

  @override
  String requestDeleteVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'アイテムのバージョンを $count 件完全に削除する',
      one: 'アイテムのバージョンを 1 件完全に削除する',
    );
    return '$_temp0';
  }

  @override
  String get requestSaveRelays => 'リレーリストを保存する';

  @override
  String get requestReadRelays => '非公開リレーを読み取る';

  @override
  String get requestEncryptRelays => '非公開リレーを暗号化する';

  @override
  String requestRelayAuth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のリレーにログインする',
      one: 'リレーにログインする',
    );
    return '$_temp0';
  }

  @override
  String requestOther(int count, String method) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'その他のリクエスト $count 件（$method）',
      one: 'その他のリクエスト（$method）',
    );
    return '$_temp0';
  }

  @override
  String get cancelAll => 'すべてキャンセル';

  @override
  String get close => '閉じる';

  @override
  String get sync => '同期';

  @override
  String get syncAllSent => 'すべての変更がオンラインに保存されています。';

  @override
  String get relays => 'リレー';

  @override
  String get relaysDescription =>
      'この保管庫は、これらの各リレーにコピーされます。リレーから見えるのは、暗号化されたデータと保管庫の公開鍵だけです。';

  @override
  String get relayConnected => '接続中';

  @override
  String get relayNotConnected => '未接続';

  @override
  String get relayPrivate => '非公開';

  @override
  String get removeRelay => 'このリレーを削除';

  @override
  String get addRelay => 'リレーを追加';

  @override
  String get relayAddress => 'リレーのアドレス';

  @override
  String get relayAddressInvalid => 'リレーのアドレスではありません。';

  @override
  String get relayAlreadyListed => 'このリレーはすでにリストにあります。';

  @override
  String get relayKeepPrivate => '非公開にする';

  @override
  String get relayKeepPrivateDescription =>
      '保管庫のリレーリスト内で暗号化されます。保管庫がこのリレーにあることは、保管庫の鍵を持つ人にしかわかりません。';

  @override
  String get relaysSaveFailed => 'リレーを保存できませんでした。';

  @override
  String get relaysWaitForSync => '保管庫の同期が完了すると、リレーを変更できるようになります。';

  @override
  String get relayAdded => '新規';

  @override
  String get relayRemoved => '削除予定';

  @override
  String get keepRelay => 'このリレーを残す';

  @override
  String get relaysNeedOne => '保管庫には少なくとも 1 つのリレーが必要です。';

  @override
  String get fileServers => 'ファイルサーバー';

  @override
  String get fileServersDescription =>
      'この保管庫に添付されたファイルは、これらの各サーバーにコピーされます。サーバーから見えるのは、暗号化されたファイルだけです。';

  @override
  String get serverPrivate => '非公開';

  @override
  String get removeServer => 'このサーバーを削除';

  @override
  String get keepServer => 'このサーバーを残す';

  @override
  String get addServer => 'サーバーを追加';

  @override
  String get serverAddress => 'サーバーのアドレス';

  @override
  String get serverAddressInvalid => 'サーバーのアドレスではありません。';

  @override
  String get serverAlreadyListed => 'このサーバーはすでにリストにあります。';

  @override
  String get serverKeepPrivate => '非公開にする';

  @override
  String get serverKeepPrivateDescription =>
      '保管庫のサーバーリスト内で暗号化されます。保管庫がこのサーバーを使っていることは、保管庫の鍵を持つ人にしかわかりません。';

  @override
  String get serversSaveFailed => 'サーバーを保存できませんでした。';

  @override
  String get serversWaitForSync => '保管庫の同期が完了すると、サーバーを変更できるようになります。';

  @override
  String get serverAdded => '新規';

  @override
  String get serverRemoved => '削除予定';

  @override
  String get serversNeedOne => '保管庫には少なくとも 1 つのサーバーが必要です。';

  @override
  String get add => '追加';

  @override
  String get cancel => 'キャンセル';

  @override
  String get create => '作成';

  @override
  String get open => '開く';

  @override
  String get done => '完了';

  @override
  String get welcomeTagline => 'パスワードを暗号化して同期。アカウントは不要です。';

  @override
  String get builtOnNostr => 'Nostr を基盤に構築';

  @override
  String get builtOnNostrBody =>
      '保管庫は Nostr のリレーに保存されます。リレーは誰でも運営できるオープンなサーバーで、暗号化されたデータしか見えません。保管庫の鍵は Nostr の鍵なので、Nostr の外部署名で管理することもできます。';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'アイテム $count 件',
      one: 'アイテム 1 件',
      zero: 'アイテムなし',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => '今すぐ同期';

  @override
  String get syncing => '同期中';

  @override
  String get syncNever => '未同期';

  @override
  String get syncFailed => '同期に失敗しました';

  @override
  String get signerDidNotOpen => '外部署名が保管庫を開きませんでした';

  @override
  String get syncedJustNow => 'たった今同期しました';

  @override
  String syncedMinutesAgo(int minutes) {
    return '$minutes 分前に同期';
  }

  @override
  String syncedHoursAgo(int hours) {
    return '$hours 時間前に同期';
  }

  @override
  String syncedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString に同期';
  }

  @override
  String get noItems => 'この保管庫にはまだアイテムがありません。';

  @override
  String get lookingForItems => 'アイテムを探しています';

  @override
  String get signerDidNotOpenVault => '外部署名がこの保管庫を開きませんでした。同期すると、もう一度依頼します。';

  @override
  String get selectItem => 'アイテムを選択すると、ここに表示されます。';

  @override
  String get itemNotFound => 'このアイテムはもう保管庫にありません。';

  @override
  String get typeLogin => 'ログイン';

  @override
  String get typeSecureNote => 'セキュアメモ';

  @override
  String get typeCard => 'カード';

  @override
  String get typeIdentity => 'ID';

  @override
  String get typeSshKey => 'SSH 鍵';

  @override
  String get typeBankAccount => '銀行口座';

  @override
  String get typeDriversLicense => '運転免許証';

  @override
  String get typePassport => 'パスポート';

  @override
  String get typeUnknown => 'アイテム';

  @override
  String get copy => 'コピー';

  @override
  String get copied => 'コピーしました';

  @override
  String get show => '表示';

  @override
  String get hide => '非表示';

  @override
  String get hiddenValue => '非表示の値';

  @override
  String get openWebsite => 'ウェブサイトを開く';

  @override
  String get username => 'ユーザー名';

  @override
  String get password => 'パスワード';

  @override
  String get verificationCode => '認証コード';

  @override
  String get totpInvalid => 'この認証キーを読み取れません。';

  @override
  String get website => 'ウェブサイト';

  @override
  String get passkey => 'パスキー';

  @override
  String passkeyCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString に作成';
  }

  @override
  String get notes => 'メモ';

  @override
  String get customFields => 'カスタムフィールド';

  @override
  String get passwordHistory => 'パスワードの履歴';

  @override
  String itemDates(DateTime updated, DateTime created) {
    final intl.DateFormat updatedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String updatedString = updatedDateFormat.format(updated);
    final intl.DateFormat createdDateFormat = intl.DateFormat.yMMMd(localeName);
    final String createdString = createdDateFormat.format(created);

    return '$updatedString に更新、$createdString に作成';
  }

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String linkedTo(String field) {
    return '$field にリンク';
  }

  @override
  String get cardholderName => 'カード名義人';

  @override
  String get cardBrand => 'ブランド';

  @override
  String get cardNumber => 'カード番号';

  @override
  String get cardExpiration => '有効期限';

  @override
  String get cardExpMonth => '有効期限（月）';

  @override
  String get cardExpYear => '有効期限（年）';

  @override
  String get cardCode => 'セキュリティコード';

  @override
  String get fullName => '氏名';

  @override
  String get identityTitle => '敬称';

  @override
  String get firstName => '名';

  @override
  String get middleName => 'ミドルネーム';

  @override
  String get lastName => '姓';

  @override
  String get company => '会社名';

  @override
  String get email => 'メールアドレス';

  @override
  String get phone => '電話番号';

  @override
  String get address => '住所';

  @override
  String get city => '市区町村';

  @override
  String get state => '都道府県';

  @override
  String get postalCode => '郵便番号';

  @override
  String get country => '国';

  @override
  String get ssn => '社会保障番号';

  @override
  String get passportNumber => 'パスポート番号';

  @override
  String get licenseNumber => '免許証番号';

  @override
  String get privateKey => '秘密鍵';

  @override
  String get publicKey => '公開鍵';

  @override
  String get fingerprint => 'フィンガープリント';

  @override
  String get bankName => '銀行名';

  @override
  String get accountHolder => '口座名義人';

  @override
  String get accountType => '口座種別';

  @override
  String get accountNumber => '口座番号';

  @override
  String get routingNumber => 'ルーティングナンバー';

  @override
  String get branchNumber => '支店番号';

  @override
  String get pin => 'PIN';

  @override
  String get swiftCode => 'SWIFT コード';

  @override
  String get iban => 'IBAN';

  @override
  String get bankPhone => '銀行の電話番号';

  @override
  String get accountTypeChecking => '当座預金';

  @override
  String get accountTypeSavings => '貯蓄預金';

  @override
  String get accountTypeCertificateOfDeposit => '定期預金';

  @override
  String get accountTypeLineOfCredit => '融資枠';

  @override
  String get accountTypeInvestmentBrokerage => '証券口座';

  @override
  String get accountTypeMoneyMarket => 'マネーマーケット';

  @override
  String get accountTypeOther => 'その他';

  @override
  String get dateOfBirth => '生年月日';

  @override
  String get issuingCountry => '発行国';

  @override
  String get issuingState => '発行元の都道府県';

  @override
  String get issueDate => '発行日';

  @override
  String get expirationDate => '有効期限';

  @override
  String get issuingAuthority => '発行機関';

  @override
  String get licenseClass => '免許の種類';

  @override
  String get surname => '姓';

  @override
  String get givenName => '名';

  @override
  String get sex => '性別';

  @override
  String get birthPlace => '出生地';

  @override
  String get nationality => '国籍';

  @override
  String get passportType => '種類';

  @override
  String get nationalId => '国民識別番号';

  @override
  String get filterAllItems => 'すべてのアイテム';

  @override
  String get filterAllShort => 'すべて';

  @override
  String get filterFavorites => 'お気に入り';

  @override
  String get filterLogins => 'ログイン';

  @override
  String get filterSecureNotes => 'セキュアメモ';

  @override
  String get filterCards => 'カード';

  @override
  String get filterIdentities => 'ID';

  @override
  String get filterSshKeys => 'SSH 鍵';

  @override
  String get filterBankAccounts => '銀行口座';

  @override
  String get filterDriversLicenses => '運転免許証';

  @override
  String get filterPassports => 'パスポート';

  @override
  String get filterTrash => 'ごみ箱';

  @override
  String get noItemsHere => 'ここにはアイテムがありません。';

  @override
  String get searchItems => '検索';

  @override
  String get clearSearch => '検索をクリア';

  @override
  String get noSearchResults => '検索に一致するアイテムはありません。';

  @override
  String changesNotSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '未送信の変更 $count 件',
      one: '未送信の変更 1 件',
    );
    return '$_temp0';
  }

  @override
  String get newItem => '新しいアイテム';

  @override
  String get newLogin => '新しいログイン';

  @override
  String get newCard => '新しいカード';

  @override
  String get newSecureNote => '新しいセキュアメモ';

  @override
  String get editItem => 'アイテムを編集';

  @override
  String get edit => '編集';

  @override
  String get save => '保存';

  @override
  String get itemSaveFailed => 'アイテムを保存できませんでした。';

  @override
  String get vault => '保管庫';

  @override
  String get itemName => '名前';

  @override
  String get itemNameRequired => 'アイテムの名前を入力してください。';

  @override
  String get authenticatorKey => '認証キー';

  @override
  String get authenticatorKeyHint => 'Base32 のシークレットまたは otpauth:// URI';

  @override
  String get addWebsite => 'ウェブサイトを追加';

  @override
  String get addField => 'フィールドを追加';

  @override
  String get customField => 'カスタムフィールド';

  @override
  String get editField => 'フィールドを編集';

  @override
  String get fieldType => 'フィールドタイプ';

  @override
  String get fieldTypeText => 'テキスト';

  @override
  String get fieldTypeHidden => '非表示';

  @override
  String get fieldTypeCheckbox => 'チェックボックス';

  @override
  String get fieldTypeLinked => 'リンクされたフィールド';

  @override
  String get textFieldHelp => 'セキュリティに関する質問などのデータには、テキストフィールドを使用します。';

  @override
  String get hiddenFieldHelp => 'パスワードなどの機密データには、非表示フィールドを使用します。';

  @override
  String get checkboxFieldHelp =>
      'フォームのチェックボックス（メールアドレスを記憶するなど）を入力するには、チェックボックスを使用します。';

  @override
  String get linkedFieldHelp => '特定のウェブサイトで自動入力がうまくいかないときは、リンクされたフィールドを使用します。';

  @override
  String get fieldLabel => 'フィールドラベル';

  @override
  String get linkedFieldLabelHelp =>
      'フィールドの HTML の id、name、aria-label、または placeholder を入力してください。';

  @override
  String editFieldNamed(String field) {
    return '$field を編集';
  }

  @override
  String deleteFieldNamed(String field) {
    return '$field を削除';
  }

  @override
  String reorderField(String field) {
    return '$field を移動';
  }

  @override
  String get cardBrandOther => 'その他';

  @override
  String get cardExpYearHint => 'YYYY';

  @override
  String get notSet => '未設定';

  @override
  String get favorite => 'お気に入り';

  @override
  String get addToFavorites => 'お気に入りに追加';

  @override
  String get removeFromFavorites => 'お気に入りから削除';

  @override
  String get discardChanges => '変更を破棄しますか？';

  @override
  String get keepEditing => '編集を続ける';

  @override
  String get discard => '破棄';

  @override
  String get moreActions => 'その他の操作';

  @override
  String get copyUsername => 'ユーザー名をコピー';

  @override
  String get copyPassword => 'パスワードをコピー';

  @override
  String get copyTotp => '認証コードをコピー';

  @override
  String get copyNumber => 'カード番号をコピー';

  @override
  String get moveToTrash => 'ごみ箱に移動';

  @override
  String get restore => '復元';

  @override
  String get deletePermanently => '完全に削除';

  @override
  String get deleteItemTitle => 'このアイテムを完全に削除しますか？';

  @override
  String get deleteItemBody => 'すべてのデバイスで、保管庫から消去されます。この操作は元に戻せません。';

  @override
  String get delete => '削除';

  @override
  String get generatePassword => 'パスワードを生成';

  @override
  String get generateUsername => 'ユーザー名を生成';

  @override
  String get generator => 'ジェネレーター';

  @override
  String get passphrase => 'パスフレーズ';

  @override
  String get regenerate => '再生成';

  @override
  String get passwordLength => '長さ';

  @override
  String characterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 文字',
    );
    return '$_temp0';
  }

  @override
  String get includeCharacters => '含める文字';

  @override
  String get uppercaseLetters => '大文字';

  @override
  String get lowercaseLetters => '小文字';

  @override
  String get digits => '数字';

  @override
  String get specialCharacters => '特殊文字';

  @override
  String get minNumbers => '数字の最小個数';

  @override
  String get minSpecial => '特殊文字の最小個数';

  @override
  String get avoidAmbiguous => 'あいまいな文字を避ける';

  @override
  String get numberOfWords => '単語数';

  @override
  String get wordSeparator => '単語の区切り文字';

  @override
  String get capitalize => '先頭を大文字にする';

  @override
  String get includeNumber => '数字を含める';

  @override
  String get usePassword => 'このパスワードを使用';

  @override
  String get usePassphrase => 'このパスフレーズを使用';

  @override
  String get useUsername => 'このユーザー名を使用';

  @override
  String get usernameCapitalize => '先頭を大文字にする';

  @override
  String get usernameIncludeNumber => '数字を含める';

  @override
  String get decrease => '減らす';

  @override
  String get increase => '増やす';

  @override
  String get settings => '設定';

  @override
  String get security => 'セキュリティ';

  @override
  String get unlockWithBiometrics => '生体認証でロック解除';

  @override
  String get unlockWithBiometricsDescription =>
      'このデバイスのパスコードまたはパスワードでも解除できます。保管庫の鍵はデバイスの安全なストレージに保存されたままです。';

  @override
  String get lockNeedsScreenLock => '先にこのデバイスで画面ロックを設定してください。';

  @override
  String get lockAfter => 'ロックまでの時間';

  @override
  String get lockImmediately => 'すぐに';

  @override
  String get lockOnRestart => 'アプリの再起動時';

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分',
      one: '1 分',
    );
    return '$_temp0';
  }

  @override
  String hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 時間',
      one: '1 時間',
    );
    return '$_temp0';
  }

  @override
  String get clearClipboardAfter => 'コピーしたパスワードを消去するまでの時間';

  @override
  String get never => '消去しない';

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
  String get allowScreenCapture => '画面キャプチャを許可';

  @override
  String get allowScreenCaptureDescription =>
      'スクリーンショット、画面録画、画面共有にパスワードが映るようになります。';

  @override
  String get lock => 'ロック';

  @override
  String lockWithShortcut(String shortcut) {
    return 'ロック（$shortcut）';
  }

  @override
  String get unlock => 'ロック解除';

  @override
  String get vaultsLocked => '保管庫はロックされています。';

  @override
  String get unlockReason => '保管庫のロックを解除';

  @override
  String get enableLockReason => 'ロックを有効にする';

  @override
  String get authLockedOut => '試行回数が多すぎます。しばらくしてからもう一度お試しください。';

  @override
  String get authFailed => 'このデバイスで本人確認ができませんでした。';

  @override
  String get vaultTab => '保管庫';

  @override
  String get storageReadFailed => '保管庫を読み込めませんでした。';

  @override
  String get storageReadFailedBody =>
      'このデバイスの安全なストレージが、保管庫を開くことを拒否しました。何も消去されていないので、もう一度お試しください。アイテムはオンラインに残っており、保管庫の鍵があればどのデバイスでも開けます。';

  @override
  String get tryAgain => '再試行';

  @override
  String get appearance => '外観';

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システム';

  @override
  String get languageName => '日本語';

  @override
  String get theme => 'テーマ';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get importExport => 'インポートとエクスポート';

  @override
  String get importFromBitwarden => 'Bitwarden からインポート';

  @override
  String get importFromBitwardenDescription =>
      'Bitwarden からエクスポートした JSON ファイルです。';

  @override
  String get importButton => 'インポート';

  @override
  String get importReadFailed => 'ファイルを読み込めませんでした。';

  @override
  String get importNotBitwarden => 'このファイルは Bitwarden の JSON エクスポートではありません。';

  @override
  String get importEncrypted =>
      'このエクスポートはお使いの Bitwarden アカウントに制限されているため、Bitwarden でしか開けません。Bitwarden から保管庫をもう一度エクスポートしてください。その際は、パスワード保護ありか .json 形式を選んでください。';

  @override
  String get importEmpty => 'このエクスポートにはアイテムがありません。';

  @override
  String importFound(int count, String file) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$file に $count 件のアイテムが見つかりました。',
      one: '$file に 1 件のアイテムが見つかりました。',
    );
    return '$_temp0';
  }

  @override
  String importProgress(int done, int total) {
    return '$total 件中 $done 件のアイテムをインポートしました';
  }

  @override
  String importDone(int count, String vault) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のアイテムを $vault にインポートしました。',
      one: '1 件のアイテムを $vault にインポートしました。',
    );
    return '$_temp0';
  }

  @override
  String importFailed(int done, int total) {
    return 'インポートが中断されました。$total 件中 $done 件のアイテムを保存しました。';
  }

  @override
  String get exportVault => '保管庫をエクスポート';

  @override
  String get exportVaultDescription =>
      'Bitwarden の JSON ファイルです。パスワードで保護するか、暗号化せずに保存します。';

  @override
  String get exportButton => 'エクスポート';

  @override
  String exportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'アイテム $count 件をエクスポートします。ごみ箱のアイテムは含まれません。',
      one: 'アイテム 1 件をエクスポートします。ごみ箱のアイテムは含まれません。',
      zero: 'この保管庫にはエクスポートするアイテムがありません。',
    );
    return '$_temp0';
  }

  @override
  String get exportWarning => 'このファイルは暗号化されていません。メールで送らず、使い終わったら削除してください。';

  @override
  String get exportFailed => 'ファイルを保存できませんでした。';

  @override
  String get importPasswordBody =>
      'このエクスポートはパスワードで保護されています。ファイルを開くには、パスワードを入力してください。';

  @override
  String get filePassword => 'ファイルパスワード';

  @override
  String get wrongFilePassword => 'このパスワードではファイルを開けません。';

  @override
  String get exportProtect => 'パスワードで保護';

  @override
  String get confirmFilePassword => 'ファイルパスワードの確認';

  @override
  String get filePasswordHelper =>
      'Submarine や Bitwarden でファイルをインポートするときに必要です。このパスワードは復元できません。';

  @override
  String get filePasswordRequired => 'パスワードを入力してください。';

  @override
  String get filePasswordMismatch => 'パスワードが一致しません。';

  @override
  String get lockPassword => 'ロック用パスワード';

  @override
  String get lockPasswordDescription =>
      'このデバイス上の保管庫の鍵を暗号化し、アプリのロックを解除します。このパスワードは復元できません。';

  @override
  String get setLockPassword => '設定';

  @override
  String get changeLockPassword => '変更';

  @override
  String get removeLockPassword => '削除';

  @override
  String get setLockPasswordTitle => 'ロック用パスワードを設定';

  @override
  String get changeLockPasswordTitle => 'ロック用パスワードを変更';

  @override
  String get removeLockPasswordTitle => 'ロック用パスワードを削除';

  @override
  String get removeLockPasswordBody =>
      'アプリでパスワードを求められなくなります。このデバイス上の保管庫の鍵は、デバイスの安全なストレージだけで保護されるようになります。';

  @override
  String get currentLockPassword => '現在のパスワード';

  @override
  String get newLockPassword => '新しいパスワード';

  @override
  String get confirmLockPassword => 'パスワードの確認';

  @override
  String lockPasswordHelper(int count) {
    return '$count 文字以上。忘れた場合は、このデバイスから保管庫を削除することになります。';
  }

  @override
  String lockPasswordTooShort(int count) {
    return '$count 文字以上にしてください。';
  }

  @override
  String get lockPasswordMismatch => 'パスワードが一致しません。';

  @override
  String get wrongLockPassword => 'ロック用パスワードが正しくありません。';

  @override
  String get generatePassphrase => 'パスフレーズを生成';

  @override
  String get unlockWithBiometricsWithPassword =>
      'ロック用パスワードを入力する代わりに使えます。パスワードも引き続き使えます。';

  @override
  String get forgotLockPassword => 'パスワードを忘れた場合';

  @override
  String get forgetVaultsTitle => 'このデバイスから保管庫を削除しますか？';

  @override
  String get forgetVaultsBody =>
      'ロック用パスワードがないと、このデバイスでは保管庫を復号できません。アイテムはオンラインに残っているので、それぞれの保管庫を鍵でもう一度開いてください。';

  @override
  String get forgetVaults => '保管庫を削除';

  @override
  String get removeVault => 'このデバイスから削除';

  @override
  String get removeVaultDescription => '保管庫はオンラインに残るので、あとでもう一度開けます。';

  @override
  String removeVaultTitle(String name) {
    return '$name をこのデバイスから削除しますか？';
  }

  @override
  String get removeVaultBody => 'アイテムはオンラインに残ります。保管庫をもう一度開けば、また表示されます。';

  @override
  String get removeVaultKeyWarning => '先に保管庫の鍵を保存してください。鍵がないと、保管庫をもう一度開けません。';

  @override
  String removeVaultUnsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '未送信の変更が $count 件あり、失われます。',
      one: '未送信の変更が 1 件あり、失われます。',
    );
    return '$_temp0';
  }

  @override
  String get removeVaultConfirm => '削除';

  @override
  String get removeVaultFailed => '保管庫を削除できませんでした。';

  @override
  String get emailSettings => 'メール';

  @override
  String get mailBridge => 'メールブリッジ';

  @override
  String mailBridgeDescription(String domain) {
    return '新しいメールアドレスは @$domain で終わります';
  }

  @override
  String get changeMailBridge => '変更';

  @override
  String get mailBridgeDomain => 'ドメイン';

  @override
  String get mailBridgeExplanation =>
      '今後作成するメールアドレスはこのドメインで終わります。作成済みのアドレスはそのままです。';

  @override
  String get mailBridgeInvalid => 'ドメインではありません。';

  @override
  String get emailAddressField => 'メールアドレス';

  @override
  String get mailboxKey => 'メールボックスの鍵';

  @override
  String get inbox => '受信トレイ';

  @override
  String get inboxFetching => 'メッセージを取得中';

  @override
  String get inboxEmpty => 'まだメッセージはありません';

  @override
  String get noSubject => '(件名なし)';

  @override
  String get privateMessage => 'プライベートメッセージ';

  @override
  String get emailDownloadFailed => 'このメールをダウンロードできませんでした。';

  @override
  String get refreshInbox => '更新';

  @override
  String get mailInboxRelays => '受信リレー';

  @override
  String get mailInboxRelaysExplanation =>
      '新しいアドレスに送られたメールはこれらのリレーに届きます。作成済みのアドレスはそのままです。';

  @override
  String get mailAddressRelays => 'アドレスのリレー';

  @override
  String get mailAddressRelaysExplanation =>
      '新しいアドレスは受信リレーをこれらのリレーに公開し、ブリッジはそこでそれを見つけます。作成済みのアドレスはそのままです。';

  @override
  String get changeMailRelays => '変更';

  @override
  String get mailRelaysNeedOne => '新しいアドレスには少なくとも 1 つのリレーが必要です。';

  @override
  String get resetMailRelays => 'リセット';
}
