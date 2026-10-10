import 'dart:convert';

class Club {
  final String? id;
  final String name;
  final String address;
  final String city;
  final String zipCode;
  final String contactNumber;
  final String email;
  final String? area;
  final double? latitude;
  final double? longitude;
  final String? website;
  final String? instagram;
  final String? facebook;
  final String? logoUrl;
  final String? coverUrl;
  final List<String>? imageUrls;
  final Map<String, OpeningHours>? openingHours;
  final String? dressCode;
  final String? description;
  final String? shortDescription;
  final String? aboutUsDesc;
  final List<String>? aboutUsHighlights;
  final bool is18Plus;
  final bool hasDanceFloor;
  final bool servesAlcohol;

  const Club({
    this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.zipCode,
    required this.contactNumber,
    required this.email,
    this.area,
    this.latitude,
    this.longitude,
    this.website,
    this.instagram,
    this.facebook,
    this.logoUrl,
    this.coverUrl,
    this.imageUrls,
    this.openingHours,
    this.dressCode,
    this.description,
    this.shortDescription,
    this.aboutUsDesc,
    this.aboutUsHighlights,
    this.is18Plus = false,
    this.hasDanceFloor = false,
    this.servesAlcohol = false,
  });

  Club copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? zipCode,
    String? contactNumber,
    String? email,
    String? area,
    double? latitude,
    double? longitude,
    String? website,
    String? instagram,
    String? facebook,
    String? logoUrl,
    String? coverUrl,
    List<String>? imageUrls,
    Map<String, OpeningHours>? openingHours,
    String? dressCode,
    String? description,
    String? shortDescription,
    String? aboutUsDesc,
    List<String>? aboutUsHighlights,
    bool? is18Plus,
    bool? hasDanceFloor,
    bool? servesAlcohol,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      website: website ?? this.website,
      instagram: instagram ?? this.instagram,
      facebook: facebook ?? this.facebook,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      openingHours: openingHours ?? this.openingHours,
      dressCode: dressCode ?? this.dressCode,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      aboutUsDesc: aboutUsDesc ?? this.aboutUsDesc,
      aboutUsHighlights: aboutUsHighlights ?? this.aboutUsHighlights,
      is18Plus: is18Plus ?? this.is18Plus,
      hasDanceFloor: hasDanceFloor ?? this.hasDanceFloor,
      servesAlcohol: servesAlcohol ?? this.servesAlcohol,
    );
  }

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: _nullableStringValue(json['id']),
      name: _stringValue(json['name']),
      address: _stringValue(json['address']),
      city: _stringValue(json['city'] ?? json['city_id']),
      zipCode: _stringValue(json['zipCode'] ?? json['zip_code']),
      contactNumber:
          _stringValue(json['contactNumber'] ?? json['contact_phone']),
      email: _stringValue(json['email'] ?? json['contact_email']),
      area: _nullableStringValue(json['area']),
      latitude: _doubleValue(json['latitude']),
      longitude: _doubleValue(json['longitude']),
      website: _nullableStringValue(json['website']),
      instagram:
          _nullableStringValue(json['instagram'] ?? json['instagram_url']),
      facebook: _nullableStringValue(json['facebook'] ?? json['facebook_url']),
      logoUrl: _nullableStringValue(json['logoUrl'] ?? json['logo']),
      coverUrl: _nullableStringValue(json['coverUrl'] ?? json['cover_image']),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map(_stringValue)
          .where((e) => e.isNotEmpty)
          .toList(),
      openingHours: _parseOperatingHours(json['operating_hours']),
      dressCode: _nullableStringValue(json['dressCode'] ?? json['dress_code']),
      description: _nullableStringValue(json['description']),
      shortDescription: _nullableStringValue(
          json['shortDescription'] ?? json['short_description']),
      aboutUsDesc:
          _nullableStringValue(json['aboutUsDesc'] ?? json['about_us_desc']),
      aboutUsHighlights: _stringListValue(
          json['aboutUsHighlights'] ?? json['about_us_points']),
      is18Plus:
          json['is18Plus'] as bool? ?? json['is_18_plus'] as bool? ?? false,
      hasDanceFloor: json['hasDanceFloor'] as bool? ??
          json['has_dance_floor'] as bool? ??
          false,
      servesAlcohol: json['servesAlcohol'] as bool? ??
          json['serves_alcohol'] as bool? ??
          false,
    );
  }

  static String _stringValue(dynamic value) => value?.toString() ?? '';

  static Map<String, OpeningHours>? _parseOperatingHours(dynamic value) {
    if (value is! List) return null;
    final map = <String, OpeningHours>{};
    for (final item in value) {
      if (item is! Map<String, dynamic>) continue;
      final dayName = item['day_name']?.toString();
      if (dayName == null || dayName.isEmpty) continue;
      map[_canonicalDayName(dayName)] = OpeningHours.fromJson(item);
    }
    return map.isEmpty ? null : map;
  }

  static String _canonicalDayName(String dayName) {
    final lower = dayName.toLowerCase();
    final index = _dayOrder.indexOf(lower);
    if (index == -1) return dayName;
    final canonical = _dayOrder[index];
    return canonical[0].toUpperCase() + canonical.substring(1);
  }

  static List<String>? _stringListValue(dynamic value) {
    if (value == null) return null;
    final Iterable<String> parts;
    if (value is List) {
      parts = value.map((e) {
        if (e is String) return e;
        if (e is Map && e.isNotEmpty) return e.keys.first.toString();
        return '';
      });
    } else if (value is String) {
      parts = value.split(RegExp(r'[,\n]'));
    } else {
      return null;
    }
    final items = parts
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return items.isEmpty ? null : items;
  }

  static String? _nullableStringValue(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  static double? _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'address': address,
    'city': city,
    'description': description ?? '',
    'short_description': shortDescription ?? '',
    'contact_email': email,
    'contact_phone': contactNumber,
    'website': website ?? '',
    'instagram_url': instagram ?? '',
    'facebook_url': facebook ?? '',
    'dress_code': dressCode ?? '',
    'logo': logoUrl ?? '',
    'cover_image': coverUrl ?? '',
    'about_us_desc': aboutUsDesc ?? '',
    'about_us_points': aboutUsHighlights ?? [],
    'latitude': latitude?.toString() ?? '',
    'longitude': longitude?.toString() ?? '',
    'area': int.tryParse(area ?? '') ?? 0,
    'subscription_plan': 0,
    'is_top': false,
    'is_18_plus': is18Plus,
    'has_dance_floor': hasDanceFloor,
    'serves_alcohol': servesAlcohol,
    'operating_hours': operatingHoursToJson(),
  };

  List<Map<String, dynamic>> operatingHoursToJson() {
    if (openingHours == null || openingHours!.isEmpty) return [];

    final entries = openingHours!.entries.toList()
      ..sort((a, b) {
        final ai = _dayOrder.indexOf(a.key.toLowerCase());
        final bi = _dayOrder.indexOf(b.key.toLowerCase());
        if (ai == -1 && bi == -1) return 0;
        if (ai == -1) return 1;
        if (bi == -1) return -1;
        return ai.compareTo(bi);
      });

    return entries.map(_operatingHourToJson).toList();
  }

  static const List<String> _dayOrder = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  Map<String, dynamic> _operatingHourToJson(MapEntry<String, OpeningHours> e) => {
        'day': e.key.toLowerCase(),
        'open': e.value.isClosed ? null : e.value.open,
        'close': e.value.isClosed ? null : e.value.close,
        'closed': e.value.isClosed,
      };

  Map<String, dynamic> diffJson(Club original) {
    final current = toJson();
    final originalJson = original.toJson();
    final diff = <String, dynamic>{};

    for (final entry in current.entries) {
      final currentEncoded = jsonEncode(entry.value);
      final originalEncoded = jsonEncode(originalJson[entry.key]);
      if (currentEncoded != originalEncoded) {
        diff[entry.key] = entry.value;
      }
    }
    return diff;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Club &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          address == other.address &&
          city == other.city &&
          zipCode == other.zipCode &&
          contactNumber == other.contactNumber &&
          email == other.email;

  @override
  int get hashCode => Object.hash(
        id, name, address, city, zipCode, contactNumber, email);

  @override
  String toString() => 'Club(name: $name, city: $city)';
}

class OpeningHours {
  final String open;
  final String close;
  final bool isClosed;

  const OpeningHours({
    required this.open,
    required this.close,
    this.isClosed = false,
  });

  OpeningHours copyWith({
    String? open,
    String? close,
    bool? isClosed,
  }) {
    return OpeningHours(
      open: open ?? this.open,
      close: close ?? this.close,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    final closed = json['closed'] as bool? ??
        json['is_closed'] as bool? ??
        json['isClosed'] as bool? ??
        false;
    return OpeningHours(
      open: _trimSeconds(json['open'] ?? json['opening_time']),
      close: _trimSeconds(json['close'] ?? json['closing_time']),
      isClosed: closed,
    );
  }

  static String _trimSeconds(dynamic value) {
    final text = value?.toString() ?? '';
    final parts = text.split(':');
    if (parts.length == 3) return '${parts[0]}:${parts[1]}';
    return text;
  }

  Map<String, dynamic> toJson() => {
        'open': isClosed ? null : open,
        'close': isClosed ? null : close,
        'closed': isClosed,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpeningHours &&
          runtimeType == other.runtimeType &&
          open == other.open &&
          close == other.close &&
          isClosed == other.isClosed;

  @override
  int get hashCode => Object.hash(open, close, isClosed);

  @override
  String toString() =>
      'OpeningHours(open: $open, close: $close, isClosed: $isClosed)';
}
