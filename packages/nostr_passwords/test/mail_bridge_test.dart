import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

void main() {
  test('reads a domain as a user types it', () {
    expect(parseMailBridge('uid.ovh'), 'uid.ovh');
    expect(parseMailBridge('  Mail.Example.COM '), 'mail.example.com');
    expect(parseMailBridge('@uid.ovh'), 'uid.ovh');
    expect(parseMailBridge('my-bridge.example'), 'my-bridge.example');
  });

  test('refuses what is not a domain', () {
    for (final text in [
      '',
      'localhost',
      'https://uid.ovh',
      'uid.ovh/',
      'npub1abc@uid.ovh',
      'uid..ovh',
      '-uid.ovh',
      'uid.ovh.',
      'uid ovh.example',
    ]) {
      expect(parseMailBridge(text), isNull, reason: text);
    }
  });
}
