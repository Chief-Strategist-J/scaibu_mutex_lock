import 'package:scaibu_mutex_lock/service/storage/storage_engine.dart';
import 'package:uuid/uuid.dart';

class UserProfile implements StorableModel {
  UserProfile({
    required this.username,
    required this.email,
    final String? id,
    final Map<String, dynamic>? preferences,
    this.address,
    final List<String>? roles,
    final List<Contact>? contacts,
    final Map<String, List<Activity>>? activityHistory,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       preferences = preferences ?? <String, dynamic>{},

       roles = roles ?? <String>[],

       contacts = contacts ?? <Contact>[],

       activityHistory = activityHistory ?? <String, List<Activity>>{},

       createdAt = createdAt ?? DateTime.now(),

       updatedAt = updatedAt ?? DateTime.now();

  factory UserProfile.fromJson(final Map<String, dynamic> json) {
    // Parse address if exists
    Address? addressObj;
    if (json['address'] != null) {
      addressObj = Address.fromJson(json['address'] as Map<String, dynamic>);
    }

    // Parse contacts
    final List<Contact> contactsList = <Contact>[];
    if (json['contacts'] != null) {
      contactsList.addAll(
        (json['contacts'] as List<dynamic>)
            .map(
              (final dynamic c) => Contact.fromJson(c as Map<String, dynamic>),
            )
            .toList(),
      );
    }

    // Parse activity history
    final Map<String, List<Activity>> activityMap = <String, List<Activity>>{};
    if (json['activityHistory'] != null) {
      (json['activityHistory'] as Map<String, dynamic>).forEach((
        final String key,
        final dynamic value,
      ) {
        activityMap[key] =
            (value as List<dynamic>)
                .map(
                  (final dynamic a) =>
                      Activity.fromJson(a as Map<String, dynamic>),
                )
                .toList();
      });
    }

    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      preferences:
          json['preferences'] as Map<String, dynamic>? ?? <String, dynamic>{},
      address: addressObj,
      roles: List<String>.from(json['roles'] as List<dynamic>? ?? <dynamic>[]),
      contacts: contactsList,
      activityHistory: activityMap,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  final String id;
  final String username;
  final String email;
  final Map<String, dynamic> preferences;
  final Address? address;
  final List<String> roles;
  final List<Contact> contacts;
  final Map<String, List<Activity>> activityHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'username': username,
    'email': email,
    'preferences': preferences,
    'address': address?.toJson(),
    'roles': roles,
    'contacts': contacts.map((final Contact c) => c.toJson()).toList(),
    'activityHistory': activityHistory.map(
      (final String key, final List<Activity> value) =>
          MapEntry<String, dynamic>(
            key,
            value.map((final Activity a) => a.toJson()).toList(),
          ),
    ),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  UserProfile copyWith({
    final String? id,
    final String? username,
    final String? email,
    final Map<String, dynamic>? preferences,
    final Address? address,
    final bool clearAddress = false,
    final List<String>? roles,
    final List<Contact>? contacts,
    final Map<String, List<Activity>>? activityHistory,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    username: username ?? this.username,
    email: email ?? this.email,
    preferences:
        preferences != null
            ? Map<String, dynamic>.from(preferences)
            : Map<String, dynamic>.from(this.preferences),
    address: clearAddress ? null : (address ?? this.address),
    roles: roles ?? List<String>.from(this.roles),
    contacts: contacts ?? List<Contact>.from(this.contacts),
    activityHistory:
        activityHistory ??
        Map<String, List<Activity>>.fromEntries(
          this.activityHistory.entries.map(
            (final MapEntry<String, List<Activity>> e) =>
                MapEntry<String, List<Activity>>(
                  e.key,
                  List<Activity>.from(e.value),
                ),
          ),
        ),
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  // Helper methods
  UserProfile updatePreference(final String key, final dynamic value) {
    final Map<String, dynamic> newPrefs = Map<String, dynamic>.from(
      preferences,
    );
    newPrefs[key] = value;
    return copyWith(preferences: newPrefs);
  }

  UserProfile addActivity(final String category, final Activity activity) {
    final Map<String, List<Activity>> history =
        Map<String, List<Activity>>.fromEntries(
          activityHistory.entries.map(
            (final MapEntry<String, List<Activity>> e) =>
                MapEntry<String, List<Activity>>(
                  e.key,
                  List<Activity>.from(e.value),
                ),
          ),
        );

    if (!history.containsKey(category)) {
      history[category] = <Activity>[];
    }

    history[category]!.add(activity);
    return copyWith(activityHistory: history);
  }

  UserProfile addContact(final Contact contact) {
    if (contacts.any((final Contact c) => c.id == contact.id)) {
      return updateContact(contact);
    }

    final List<Contact> newContacts = List<Contact>.from(contacts)
      ..add(contact);
    return copyWith(contacts: newContacts);
  }

  UserProfile updateContact(final Contact contact) {
    final List<Contact> newContacts =
        contacts
            .map((final Contact c) => c.id == contact.id ? contact : c)
            .toList();
    return copyWith(contacts: newContacts);
  }

  UserProfile removeContact(final String contactId) {
    final List<Contact> newContacts =
        contacts.where((final Contact c) => c.id != contactId).toList();
    return copyWith(contacts: newContacts);
  }
}

// Support classes for UserProfile
class Address implements StorableModel {
  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    final String? id,
  }) : id = id ?? const Uuid().v4();

  factory Address.fromJson(final Map<String, dynamic> json) => Address(
    id: json['id'] as String,
    street: json['street'] as String,
    city: json['city'] as String,
    state: json['state'] as String,
    zipCode: json['zipCode'] as String,
    country: json['country'] as String,
  );
  @override
  final String id;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'street': street,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    'country': country,
  };

  @override
  Address copyWith({
    final String? id,
    final String? street,
    final String? city,
    final String? state,
    final String? zipCode,
    final String? country,
  }) => Address(
    id: id ?? this.id,
    street: street ?? this.street,
    city: city ?? this.city,
    state: state ?? this.state,
    zipCode: zipCode ?? this.zipCode,
    country: country ?? this.country,
  );
}

class Contact implements StorableModel {
  Contact({
    required this.name,
    required this.email,
    required this.phone,
    final String? id,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  factory Contact.fromJson(final Map<String, dynamic> json) => Contact(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    notes: json['notes'] as String?,
  );
  @override
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? notes;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'notes': notes,
  };

  @override
  Contact copyWith({
    final String? id,
    final String? name,
    final String? email,
    final String? phone,
    final String? notes,
    final bool clearNotes = false,
  }) => Contact(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    notes: clearNotes ? null : (notes ?? this.notes),
  );
}

class Activity implements StorableModel {
  Activity({
    required this.type,
    final String? id,
    final Map<String, dynamic>? data,
    final DateTime? timestamp,
  }) : id = id ?? const Uuid().v4(),
       data = data ?? <String, dynamic>{},
       timestamp = timestamp ?? DateTime.now();

  factory Activity.fromJson(final Map<String, dynamic> json) => Activity(
    id: json['id'] as String,
    type: json['type'] as String,
    data: json['data'] as Map<String, dynamic>? ?? <String, dynamic>{},
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
  @override
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
  };

  @override
  Activity copyWith({
    final String? id,
    final String? type,
    final Map<String, dynamic>? data,
    final DateTime? timestamp,
  }) => Activity(
    id: id ?? this.id,
    type: type ?? this.type,
    data: data ?? Map<String, dynamic>.from(this.data),
    timestamp: timestamp ?? this.timestamp,
  );
}
