import 'package:uuid/uuid.dart';

abstract class Item {
  String id;
  DateTime date;
  String name;

  Item({required this.name, String? id, DateTime? date})
      : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  Map<String, dynamic> toJson();

  factory Item.fromJson(Map<String, dynamic> json) {
    // This method will need to be overridden by subclasses
    throw UnimplementedError();
  }
}
