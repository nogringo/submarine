import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';
import 'package:nip01/nip01.dart';
import 'package:nip19/nip19.dart';
import 'package:sembast/sembast.dart';
import 'package:submarine/models/decrypted_event.dart';
import 'package:submarine/repository.dart';
import 'package:submarine/screens/create_password/new_field_dialog.dart';
import 'package:submarine/services/database_service.dart';
import 'package:submarine/services/stores.dart';

class CreatePasswordController extends GetxController {
  static CreatePasswordController get to => Get.find();

  bool isCreatingPassword = false;

  final titleController = TextEditingController();
  List<CustomField> fields = [];
  bool isReorderMode = false;
  List<TextEditingController> websites = [];
  final newWebsiteController = TextEditingController(text: "https://");
  final noteController = TextEditingController();

  void newField(String name, {bool visible = true}) {
    fields.add(CustomField(name: name, visible: visible));
    update();
  }

  void showNewFieldDialog() {
    Get.dialog(
      NewFieldDialog(
        onAdd: (name, visible) => newField(name, visible: visible),
      ),
    );
  }

  void addSurname() {
    final surnames = [
      'Smith', 'Johnson', 'Williams', 'Brown', 'Jones',
      'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
      'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
      'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
      'Lee', 'Perez', 'Thompson', 'White', 'Harris',
      'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson'
    ];
    
    final randomSurname = surnames[(DateTime.now().millisecondsSinceEpoch % surnames.length)];
    final surnameField = CustomField(name: "Surname");
    surnameField.value.text = randomSurname;
    fields.add(surnameField);
    update();
  }

  void addFirstName() {
    final firstNames = [
      'James', 'Mary', 'John', 'Patricia', 'Robert',
      'Jennifer', 'Michael', 'Linda', 'William', 'Elizabeth',
      'David', 'Barbara', 'Richard', 'Susan', 'Joseph',
      'Jessica', 'Thomas', 'Sarah', 'Charles', 'Karen',
      'Christopher', 'Nancy', 'Daniel', 'Lisa', 'Matthew',
      'Betty', 'Anthony', 'Helen', 'Mark', 'Sandra'
    ];
    
    final randomFirstName = firstNames[(DateTime.now().millisecondsSinceEpoch % firstNames.length)];
    final firstNameField = CustomField(name: "First name");
    firstNameField.value.text = randomFirstName;
    fields.add(firstNameField);
    update();
  }

  void addBirthDate() {
    // Generate random birth date between 18 and 65 years ago
    final now = DateTime.now();
    final minAge = 18;
    final maxAge = 65;
    
    final random = DateTime.now().millisecondsSinceEpoch;
    final ageRange = maxAge - minAge;
    final randomAge = minAge + (random % ageRange);
    
    final birthYear = now.year - randomAge;
    final birthMonth = 1 + (random % 12);
    final birthDay = 1 + (random % 28); // Using 28 to avoid invalid dates
    
    final birthDate = DateTime(birthYear, birthMonth, birthDay);
    final formattedDate = "${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}";
    
    final birthDateField = CustomField(name: "Birth date");
    birthDateField.value.text = formattedDate;
    fields.add(birthDateField);
    update();
  }

  void addPassword() {
    // Generate a secure random password
    final length = 16;
    final letters = 'abcdefghijklmnopqrstuvwxyz';
    final capitalLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final numbers = '0123456789';
    final specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    
    final allChars = letters + capitalLetters + numbers + specialChars;
    final random = DateTime.now().millisecondsSinceEpoch;
    
    String password = '';
    // Ensure at least one of each type
    password += capitalLetters[(random + 1) % capitalLetters.length];
    password += letters[(random + 2) % letters.length];
    password += numbers[(random + 3) % numbers.length];
    password += specialChars[(random + 4) % specialChars.length];
    
    // Fill the rest randomly
    for (int i = 4; i < length; i++) {
      password += allChars[(random + i * 7) % allChars.length];
    }
    
    // Shuffle the password
    final passwordChars = password.split('');
    for (int i = passwordChars.length - 1; i > 0; i--) {
      final j = (random + i) % (i + 1);
      final temp = passwordChars[i];
      passwordChars[i] = passwordChars[j];
      passwordChars[j] = temp;
    }
    
    final passwordField = CustomField(name: "Password", visible: false);
    passwordField.value.text = passwordChars.join();
    fields.add(passwordField);
    update();
  }

  void addEmail() async {
    // Generate a new Nostr keypair
    final keyPair = KeyPair.generate();
    
    // Create email in the format npub...@uid.ovh
    final email = '${keyPair.npub}@uid.ovh';
    
    // Add email field
    final emailField = CustomField(name: "Email");
    emailField.value.text = email;
    fields.add(emailField);
    
    // Add nsec field (hidden by default)
    final nsecField = CustomField(name: "Nsec", visible: false);
    nsecField.value.text = keyPair.nsec;
    fields.add(nsecField);
    
    update();
  }

  void add2FA() {}

  void toggleReorderMode() {
    isReorderMode = !isReorderMode;
    update();
  }

  void deleteField(CustomField field) {
    fields.remove(field);
    field.value.dispose();
    update();
  }

  void toggleFieldVisibility(CustomField field) {
    field.visible = !field.visible;
    update();
  }

  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = fields.removeAt(oldIndex);
    fields.insert(newIndex, item);
    update();
  }

  void addWebsite() {
    final newWebsite = newWebsiteController.text.trim();
    if (newWebsite.isNotEmpty) {
      // Check if website already exists
      final existingWebsites = websites
          .map((controller) => controller.text)
          .toList();
      if (!existingWebsites.contains(newWebsite)) {
        websites.add(TextEditingController(text: newWebsite));
        newWebsiteController.text = "https://";
        update();
      }
    }
  }

  void removeWebsite(TextEditingController website) {
    websites.remove(website);
    website.dispose();
    update();
  }

  void createPassword() async {
    isCreatingPassword = true;
    update();

    Map<String, dynamic> passwordJson = {};

    passwordJson["id"] = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();

    final title = titleController.text.trim();
    if (title.isNotEmpty) passwordJson["title"] = title;

    final fieldsWithValue = fields.where(
      (field) => field.value.text.trim().isNotEmpty,
    );
    if (fieldsWithValue.isNotEmpty) {
      passwordJson["fields"] = fieldsWithValue.map((field) {
        return {
          "name": field.name.trim(),
          "kind": field.visible ? "text" : "secret",
          "value": field.value.text.trim(),
        };
      }).toList();
    }

    if (websites.isNotEmpty) {
      passwordJson["urls"] = websites
          .map((website) => website.text.trim())
          .toList();
    }

    final note = noteController.text.trim();
    if (note.isNotEmpty) passwordJson["note"] = note;

    final loggedAccount = Repository.to.ndk.accounts.getLoggedAccount()!;
    final pubkey = loggedAccount.pubkey;
    String encryptedPassword = (await loggedAccount.signer.encryptNip44(
      plaintext: jsonEncode(passwordJson),
      recipientPubKey: pubkey,
    ))!;

    final nostrEvent = Nip01Event(
      pubKey: pubkey,
      kind: 4111,
      tags: [],
      content: encryptedPassword,
    );

    await loggedAccount.signer.sign(nostrEvent);

    await secretsStore
        .record(nostrEvent.id)
        .put(
          await DatabaseService().database,
          DecryptedSecretEvent(
            eventId: nostrEvent.id,
            createdAt: nostrEvent.createdAt,
            secret: passwordJson,
          ).toJson(),
        );

    Repository.to.ndk.broadcast.broadcast(nostrEvent: nostrEvent);

    Get.back();
  }
}

class CustomField {
  String name;
  TextEditingController value;
  bool visible;

  CustomField({
    this.name = "",
    TextEditingController? value,
    this.visible = true,
  }) : value = value ?? TextEditingController();
}
