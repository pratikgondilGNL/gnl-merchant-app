enum EventStatus { live, draft, ended, upcoming }

class Event {
  final String? id;
  final String name;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String description;
  final String? djArtist;
  final double? entryFee;
  final double? minSpend;
  final double? coupleEntryFee;
  final double? maleEntryFee;
  final double? femaleEntryFee;
  final String? musicGenre;
  final EventStatus status;
  final String? specialInstructions;
  final String? bannerUrl;
  final String? latitude;
  final String? longitude;
  final int? discountPercentage;
  final String? discountType;
  final bool isActive;
  final bool isTop;
  final int? totalCapacity;
  final int? bookedCapacity;
  final int? category;
  final int? area;

  const Event({
    this.id,
    required this.name,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.description,
    this.djArtist,
    this.entryFee,
    this.minSpend,
    this.coupleEntryFee,
    this.maleEntryFee,
    this.femaleEntryFee,
    this.musicGenre,
    this.status = EventStatus.draft,
    this.specialInstructions,
    this.bannerUrl,
    this.latitude,
    this.longitude,
    this.discountPercentage,
    this.discountType = "percentage",
    this.isActive = true,
    this.isTop = false,
    this.totalCapacity,
    this.bookedCapacity,
    this.category,
    this.area,
  });

  Event copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? description,
    String? djArtist,
    double? entryFee,
    double? minSpend,
    double? coupleEntryFee,
    double? maleEntryFee,
    double? femaleEntryFee,
    String? musicGenre,
    EventStatus? status,
    String? specialInstructions,
    String? bannerUrl,
    String? latitude,
    String? longitude,
    int? discountPercentage,
    String? discountType,
    bool? isActive,
    bool? isTop,
    int? totalCapacity,
    int? bookedCapacity,
    int? category,
    int? area,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      djArtist: djArtist ?? this.djArtist,
      entryFee: entryFee ?? this.entryFee,
      minSpend: minSpend ?? this.minSpend,
      coupleEntryFee: coupleEntryFee ?? this.coupleEntryFee,
      maleEntryFee: maleEntryFee ?? this.maleEntryFee,
      femaleEntryFee: femaleEntryFee ?? this.femaleEntryFee,
      musicGenre: musicGenre ?? this.musicGenre,
      status: status ?? this.status,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountType: discountType ?? this.discountType,
      isActive: isActive ?? this.isActive,
      isTop: isTop ?? this.isTop,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      bookedCapacity: bookedCapacity ?? this.bookedCapacity,
      category: category ?? this.category,
      area: area ?? this.area,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': name,
    'date':
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    'start_time': startTime,
    'end_time': endTime,
    'description': description,
    if (djArtist != null) 'dj_name': djArtist,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (entryFee != null) 'entry_fee': entryFee?.toInt().toString(),
    if (minSpend != null) 'min_spend': minSpend?.toInt().toString(),
    if (coupleEntryFee != null)
      'couple_entry_fee': coupleEntryFee?.toInt().toString(),
    if (maleEntryFee != null)
      'male_entry_fee': maleEntryFee?.toInt().toString(),
    if (femaleEntryFee != null)
      'female_entry_fee': femaleEntryFee?.toInt().toString(),
    if (musicGenre != null) 'music_genre': musicGenre,
    'event_status': status.name,
    if (specialInstructions != null)
      'special_instructions': specialInstructions,
    if (bannerUrl != null) 'banner': bannerUrl,
    'discount_percentage': discountPercentage ?? 0,
    'discount_type': discountType ?? 'percentage',
    'is_active': isActive,
    'is_top': isTop,
    'total_capacity': totalCapacity ?? 0,
    'booked_capacity': bookedCapacity ?? 0,
    'category': category ?? 0,
    'area': area ?? 0,
  };

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: _nullableString(json['id']),
      name: json['title']?.toString() ?? json['name']?.toString() ?? '',
      date: _parseDate(json['date']),
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      djArtist: _nullableString(json['dj_name']),
      entryFee: _doubleOrNull(json['entry_fee']),
      minSpend: _doubleOrNull(json['min_spend']),
      coupleEntryFee: _doubleOrNull(json['couple_entry_fee']),
      maleEntryFee: _doubleOrNull(json['male_entry_fee']),
      femaleEntryFee: _doubleOrNull(json['female_entry_fee']),
      musicGenre: _nullableString(json['music_genre']),
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['event_status'],
        orElse: () => EventStatus.draft,
      ),
      specialInstructions: _nullableString(json['special_instructions']),
      bannerUrl: _nullableString(json['banner']),
      latitude: _nullableString(json['latitude']),
      longitude: _nullableString(json['longitude']),
      discountPercentage: _intOrNull(json['discount_percentage']),
      discountType: _nullableString(json['discount_type']),
      isActive: _boolOr(json['is_active'], fallback: true),
      isTop: _boolOr(json['is_top'], fallback: false),
      totalCapacity: _intOrNull(json['total_capacity']),
      bookedCapacity: _intOrNull(json['booked_capacity']),
      category: _intOrNull(json['category']),
      area: _intOrNull(json['area']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.trim().isEmpty) {
      throw FormatException('Event date is missing');
    }
    return DateTime.parse(text);
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static double? _doubleOrNull(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _intOrNull(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool _boolOr(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == 'true' || value == '1';
    return fallback;
  }
}
