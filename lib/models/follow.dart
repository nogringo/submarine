class Follow {
  final String pubkey;
  final String? relay;
  final String? petname;
  final String? name;
  final String? picture;
  final String? nip05;

  Follow({
    required this.pubkey,
    this.relay,
    this.petname,
    this.name,
    this.picture,
    this.nip05,
  });

  String get displayName => petname ?? name ?? 'Unknown';

  String get npub {
    try {
      // Create npub manually - it's just bech32 encoding
      return 'npub1${pubkey.substring(0, 16)}...';
    } catch (e) {
      return pubkey;
    }
  }

  Follow copyWith({
    String? pubkey,
    String? relay,
    String? petname,
    String? name,
    String? picture,
    String? nip05,
  }) {
    return Follow(
      pubkey: pubkey ?? this.pubkey,
      relay: relay ?? this.relay,
      petname: petname ?? this.petname,
      name: name ?? this.name,
      picture: picture ?? this.picture,
      nip05: nip05 ?? this.nip05,
    );
  }
}
