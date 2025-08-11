import 'package:ndk/ndk.dart';

class Mail {
  final String id;
  final Nip01Event event;

  Mail({required this.id, required this.event});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mail && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
