class LocationCountry {
  final int id;
  final String name;
  final List<LocationCity> cities;

  const LocationCountry({
    required this.id,
    required this.name,
    required this.cities,
  });

  factory LocationCountry.fromJson(Map<String, dynamic> json) {
    return LocationCountry(
      id: _intValue(json['country_id']),
      name: _stringValue(json['country_name']),
      cities: _listValue(json['cities'])
          .map((item) => LocationCity.fromJson(item))
          .toList(),
    );
  }
}

class LocationCity {
  final int id;
  final String name;
  final String? image;
  final bool isPopular;
  final List<LocationArea> areas;

  const LocationCity({
    required this.id,
    required this.name,
    this.image,
    required this.isPopular,
    required this.areas,
  });

  factory LocationCity.fromJson(Map<String, dynamic> json) {
    return LocationCity(
      id: _intValue(json['city_id']),
      name: _stringValue(json['city_name']),
      image: _nullableStringValue(json['image']),
      isPopular: json['is_popular'] as bool? ?? false,
      areas: _listValue(json['areas'])
          .map((item) => LocationArea.fromJson(item))
          .toList(),
    );
  }
}

class LocationArea {
  final int id;
  final String name;

  const LocationArea({
    required this.id,
    required this.name,
  });

  factory LocationArea.fromJson(Map<String, dynamic> json) {
    return LocationArea(
      id: _intValue(json['area_id']),
      name: _stringValue(json['area_name']),
    );
  }
}

List<Map<String, dynamic>> _listValue(dynamic value) {
  if (value is! List) return const [];

  return value.whereType<Map<String, dynamic>>().toList();
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _stringValue(dynamic value) => value?.toString() ?? '';

String? _nullableStringValue(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}
