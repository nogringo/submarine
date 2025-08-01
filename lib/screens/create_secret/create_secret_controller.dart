import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';
import 'package:nip01/nip01.dart';
import 'package:nip19/nip19.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:submarine/models/decrypted_event.dart';
import 'package:submarine/models/secret.dart';
import 'package:submarine/models/text_field.dart' as model;
import 'package:submarine/models/secret_text_field.dart';
import 'package:submarine/models/otp_field.dart';
import 'package:submarine/models/otp_value.dart';
import 'package:submarine/repository.dart';
import 'package:submarine/screens/create_secret/new_field_dialog.dart';
import 'package:submarine/services/database_service.dart';
import 'package:submarine/services/stores.dart';

class CreateSecretController extends GetxController {
  static CreateSecretController get to => Get.find();

  bool isCreatingPassword = false;
  bool isEditMode = false;
  Secret? originalSecret;
  String? eventId;

  final titleController = TextEditingController();
  List<CustomField> fields = [];
  bool isReorderMode = false;
  List<TextEditingController> websites = [];
  final newWebsiteController = TextEditingController(text: "https://");
  final noteController = TextEditingController();
  
  // Original data for change detection
  String? _originalTitle;
  String? _originalNote;
  List<String> _originalUrls = [];
  Map<String, Map<String, dynamic>> _originalFields = {};
  final List<String> _originalFieldOrder = [];

  @override
  void onInit() {
    super.onInit();
    
    // Check if we're in edit mode via arguments
    final args = Get.arguments;
    if (args != null && args is Secret) {
      isEditMode = true;
      originalSecret = args;
      _loadSecretEventId();
      _loadSecretData();
    }
    
    // Add listeners for change detection
    if (isEditMode) {
      titleController.addListener(_checkForChanges);
      noteController.addListener(_checkForChanges);
    }
  }
  
  @override
  void onClose() {
    titleController.removeListener(_checkForChanges);
    noteController.removeListener(_checkForChanges);
    super.onClose();
  }
  
  void _checkForChanges() {
    update();
  }
  
  bool get hasChanges {
    if (!isEditMode) return true; // Always allow save in create mode
    
    // Check title
    if (titleController.text != _originalTitle) return true;
    
    // Check note
    if (noteController.text != _originalNote) return true;
    
    // Check websites
    final currentUrls = websites
        .map((w) => w.text.trim())
        .where((url) => url.isNotEmpty && url != "https://")
        .toList();
    if (currentUrls.length != _originalUrls.length) return true;
    for (int i = 0; i < currentUrls.length; i++) {
      if (i >= _originalUrls.length || currentUrls[i] != _originalUrls[i]) return true;
    }
    
    // Check fields count
    if (fields.length != _originalFields.length) return true;
    
    // Check field order
    for (int i = 0; i < fields.length; i++) {
      if (i >= _originalFieldOrder.length || fields[i].name != _originalFieldOrder[i]) {
        return true;
      }
    }
    
    // Check field values and visibility
    for (final field in fields) {
      final original = _originalFields[field.name];
      if (original == null) return true;
      if (field.value.text != original['value']) return true;
      if (field.visible != (original['kind'] == 'text')) return true;
    }
    
    return false;
  }

  void _loadSecretEventId() async {
    if (originalSecret?.id == null) return;
    
    try {
      final db = await DatabaseService().database;
      // Find the eventId by searching for the secret with matching id
      final finder = sembast.Finder(
        filter: sembast.Filter.custom((record) {
          if (record.value is Map) {
            final decryptedEvent = DecryptedSecretEvent.fromJson(record.value as Map<String, dynamic>);
            return decryptedEvent.secret['id'] == originalSecret!.id;
          }
          return false;
        }),
      );
      
      final snapshot = await secretsStore.findFirst(db, finder: finder);
      if (snapshot != null) {
        eventId = snapshot.key;
      }
    } catch (e) {
      // Error loading eventId: $e
    }
  }
  
  void _loadSecretData() {
    if (originalSecret == null) return;
    
    titleController.text = originalSecret!.title ?? '';
    noteController.text = originalSecret!.note ?? '';
    
    // Store original values for change detection
    _originalTitle = originalSecret!.title ?? '';
    _originalNote = originalSecret!.note ?? '';
    
    // Load existing websites
    if (originalSecret!.urls != null) {
      _originalUrls = List<String>.from(originalSecret!.urls!);
      for (var url in originalSecret!.urls!) {
        final controller = TextEditingController(text: url);
        controller.addListener(_checkForChanges);
        websites.add(controller);
      }
    }
    
    // Load existing fields
    if (originalSecret!.fields != null) {
      for (var field in originalSecret!.fields!) {
        CustomField customField;
        String value;
        String kind;
        
        if (field is model.TextField) {
          customField = CustomField(name: field.name, visible: true);
          value = field.value;
          kind = 'text';
          customField.value.text = value;
        } else if (field is SecretTextField) {
          customField = CustomField(name: field.name, visible: false);
          value = field.value;
          kind = 'secret';
          customField.value.text = value;
        } else if (field is OTPField) {
          customField = CustomField(name: field.name, visible: true);
          value = jsonEncode(field.value.toJson());
          kind = 'otp';
          customField.value.text = value;
        } else {
          continue;
        }
        
        // Store original field data
        _originalFields[field.name] = {
          'value': value,
          'kind': kind,
        };
        _originalFieldOrder.add(field.name);
        
        customField.value.addListener(_checkForChanges);
        fields.add(customField);
      }
    }
  }

  void newField(String name, {bool visible = true}) {
    final field = CustomField(name: name, visible: visible);
    if (isEditMode) {
      field.value.addListener(_checkForChanges);
    }
    fields.add(field);
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
    if (isEditMode) {
      surnameField.value.addListener(_checkForChanges);
    }
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
    if (isEditMode) {
      firstNameField.value.addListener(_checkForChanges);
    }
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
    if (isEditMode) {
      birthDateField.value.addListener(_checkForChanges);
    }
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
    if (isEditMode) {
      passwordField.value.addListener(_checkForChanges);
    }
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
    if (isEditMode) {
      emailField.value.addListener(_checkForChanges);
    }
    fields.add(emailField);
    
    // Add nsec field (hidden by default)
    final nsecField = CustomField(name: "Nsec", visible: false);
    nsecField.value.text = keyPair.nsec;
    if (isEditMode) {
      nsecField.value.addListener(_checkForChanges);
    }
    fields.add(nsecField);
    
    update();
  }

  void add2FA() {}

  void toggleReorderMode() {
    isReorderMode = !isReorderMode;
    update();
  }

  void deleteField(CustomField field) {
    if (isEditMode) {
      field.value.removeListener(_checkForChanges);
    }
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
        final controller = TextEditingController(text: newWebsite);
        if (isEditMode) {
          controller.addListener(_checkForChanges);
        }
        websites.add(controller);
        newWebsiteController.text = "https://";
        update();
      }
    }
  }

  void removeWebsite(TextEditingController website) {
    if (isEditMode) {
      website.removeListener(_checkForChanges);
    }
    websites.remove(website);
    website.dispose();
    update();
  }

  void createPassword() async {
    isCreatingPassword = true;
    update();

    Map<String, dynamic> passwordJson = {};

    // Use existing ID for edit mode, generate new one for create
    if (isEditMode && originalSecret?.id != null) {
      passwordJson["id"] = originalSecret!.id;
    } else {
      passwordJson["id"] = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
          .toString();
    }

    final title = titleController.text.trim();
    if (title.isNotEmpty) passwordJson["title"] = title;

    final fieldsWithValue = fields.where(
      (field) => field.value.text.trim().isNotEmpty,
    );
    if (fieldsWithValue.isNotEmpty) {
      passwordJson["fields"] = fieldsWithValue.map((field) {
        // Check if it's an OTP field (value is JSON)
        final value = field.value.text.trim();
        if (value.startsWith('{') && value.contains('"secret"')) {
          try {
            final otpValue = OTPValue.fromJson(jsonDecode(value));
            return {
              "name": field.name.trim(),
              "kind": "otp",
              "value": otpValue.toJson(),
            };
          } catch (e) {
            // If JSON parsing fails, treat as regular field
            return {
              "name": field.name.trim(),
              "kind": field.visible ? "text" : "secret",
              "value": value,
            };
          }
        } else {
          return {
            "name": field.name.trim(),
            "kind": field.visible ? "text" : "secret",
            "value": value,
          };
        }
      }).toList();
    }

    if (websites.isNotEmpty) {
      passwordJson["urls"] = websites
          .map((website) => website.text.trim())
          .where((url) => url.isNotEmpty)
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

    final tags = <List<String>>[];

    final nostrEvent = Nip01Event(
      pubKey: pubkey,
      kind: 4111,
      tags: tags,
      content: encryptedPassword,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
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

    // If in edit mode, delete the old event
    if (isEditMode && eventId != null) {
      final deleteEvent = Nip01Event(
        pubKey: pubkey,
        kind: 5, // NIP-09 deletion event
        tags: [
          ["e", eventId!], // Reference to the event being deleted
        ],
        content: "Deleted",
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
      
      await loggedAccount.signer.sign(deleteEvent);
      Repository.to.ndk.broadcast.broadcast(nostrEvent: deleteEvent);
      
      // Also delete from local database
      await secretsStore
          .record(eventId!)
          .delete(await DatabaseService().database);
    }

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
