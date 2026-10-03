import 'dart:convert';

import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

Map<String, dynamic> roundTrip(Map<String, dynamic> json) =>
    Cipher.fromJson(jsonDecode(jsonEncode(json))).toJson();

void main() {
  test('the login of docs/example.md round-trips unchanged', () {
    final json = {
      'type': 1,
      'name': 'GitHub',
      'notes': 'Personal account',
      'favorite': false,
      'reprompt': 0,
      'folderId': null,
      'fields': [],
      'login': {
        'uris': [
          {'uri': 'https://github.com', 'match': null},
        ],
        'username': 'alice@example.com',
        'password': r']vY$qff.p)iq4y-zDRrg',
        'totp':
            'otpauth://totp/GitHub:alice?secret=JBSWY3DPEHPK3PXP&issuer=GitHub',
        'fido2Credentials': [],
      },
      'passwordHistory': [],
      'creationDate': '2026-09-30T10:00:00.000Z',
      'revisionDate': '2026-09-30T10:00:00.000Z',
      'deletedDate': null,
    };

    expect(roundTrip(json), json);
  });

  test('every cipher type round-trips unchanged', () {
    final items = [
      {
        'type': 1,
        'name': 'Passkey',
        'fields': [
          {'name': 'pin', 'value': '1234', 'type': 1, 'linkedId': null},
          {'name': 'user', 'value': null, 'type': 3, 'linkedId': 100},
        ],
        'login': {
          'uris': [
            {'uri': 'https://example.com', 'match': 3},
          ],
          'username': 'alice',
          'password': 'secret',
          'totp': null,
          'fido2Credentials': [
            {
              'credentialId': 'keyId',
              'keyType': 'public-key',
              'keyAlgorithm': 'ECDSA',
              'keyCurve': 'P-256',
              'keyValue': 'keyValue',
              'rpId': 'example.com',
              'userHandle': 'userHandle',
              'userName': 'alice',
              'counter': '0',
              'rpName': 'Example',
              'userDisplayName': 'Alice',
              'discoverable': 'true',
              'creationDate': '2026-09-30T10:00:00.000Z',
            },
          ],
        },
        'passwordHistory': [
          {'password': 'old', 'lastUsedDate': '2026-09-01T08:00:00.000Z'},
        ],
      },
      {
        'type': 2,
        'name': 'Note',
        'notes': 'Some text',
        'secureNote': {'type': 0},
      },
      {
        'type': 3,
        'name': 'Visa',
        'card': {
          'cardholderName': 'Alice Doe',
          'brand': 'Visa',
          'number': '4242424242424242',
          'expMonth': '1',
          'expYear': '2030',
          'code': '123',
        },
      },
      {
        'type': 4,
        'name': 'Me',
        'identity': {
          'title': 'Ms',
          'firstName': 'Alice',
          'middleName': null,
          'lastName': 'Doe',
          'address1': '1 rue de Rivoli',
          'city': 'Paris',
          'postalCode': '75001',
          'country': 'FR',
          'email': 'alice@example.com',
        },
      },
      {
        'type': 5,
        'name': 'Server',
        'sshKey': {
          'privateKey': '-----BEGIN OPENSSH PRIVATE KEY-----',
          'publicKey': 'ssh-ed25519 AAAA',
          'keyFingerprint': 'SHA256:abc',
        },
      },
      {
        'type': 6,
        'name': 'Bank',
        'bankAccount': {
          'bankName': 'Acme Bank',
          'accountType': 'checking',
          'iban': 'FR7600000000000000000000000',
          'swiftCode': 'ACMEFRPP',
        },
      },
      {
        'type': 7,
        'name': 'License',
        'driversLicense': {
          'firstName': 'Alice',
          'lastName': 'Doe',
          'licenseNumber': '123456',
          'licenseClass': 'B',
          'expirationDate': '2035-01-01',
        },
      },
      {
        'type': 8,
        'name': 'Passport',
        'passport': {
          'surname': 'Doe',
          'givenName': 'Alice',
          'passportNumber': '12AB34567',
          'issuingCountry': 'FR',
        },
      },
    ];

    for (final item in items) {
      final json = {
        'favorite': false,
        'reprompt': 0,
        'fields': [],
        'passwordHistory': [],
        ...item,
      };
      expect(roundTrip(json), json, reason: '${item['name']}');
    }
  });

  test('fields and values this package does not model are kept', () {
    final json = {
      'id': 'bitwarden-id',
      'organizationId': null,
      'collectionIds': ['c1'],
      'key': '2.encryptedKey',
      'type': 42,
      'name': 'From the future',
      'reprompt': 7,
      'favorite': true,
      'fields': [],
      'login': {
        'uris': [
          {'uri': 'https://example.com', 'uriChecksum': '2.abc', 'match': 9},
        ],
        'fido2Credentials': [],
      },
      'passwordHistory': [],
      'somethingNew': {'nested': true},
    };

    expect(roundTrip(json), json);
  });

  test('an edit keeps what was not edited', () {
    final cipher = Cipher.fromJson({
      'type': 1,
      'name': 'Boulanger',
      'key': '2.encryptedKey',
      'login': {'username': 'alice', 'password': 'old'},
    });

    cipher.login!.password = 'new';
    cipher.card = null;

    expect(cipher.toJson(), {
      'type': 1,
      'name': 'Boulanger',
      'key': '2.encryptedKey',
      'favorite': false,
      'reprompt': 0,
      'fields': [],
      'login': {
        'username': 'alice',
        'password': 'new',
        'uris': [],
        'fido2Credentials': [],
      },
      'passwordHistory': [],
    });
  });

  test('a new cipher leaves unset fields out and dates its creation', () {
    final cipher = Cipher(
      type: CipherType.login,
      name: 'Boulanger',
      login: Login(uris: [LoginUri('https://www.boulanger.com')]),
    );

    final json = cipher.toJson();

    expect(cipher.revisionDate, cipher.creationDate);
    expect(
      json
        ..remove('creationDate')
        ..remove('revisionDate'),
      {
        'type': 1,
        'name': 'Boulanger',
        'favorite': false,
        'reprompt': 0,
        'fields': [],
        'login': {
          'uris': [
            {'uri': 'https://www.boulanger.com'},
          ],
          'fido2Credentials': [],
        },
        'passwordHistory': [],
      },
    );
  });
}
