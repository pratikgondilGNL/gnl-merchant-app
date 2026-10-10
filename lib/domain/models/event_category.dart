class EventCategory {
  final int id;
  final String name;
  final String slug;
  final String? tagLine;
  final String? image;
  final bool isActive;

  const EventCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.tagLine,
    this.image,
    this.isActive = true,
  });

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      id: _intValue(json['id']),
      name: _stringValue(json['name']),
      slug: _stringValue(json['slug']),
      tagLine: _nullableStringValue(json['tag_line']),
      image: _nullableStringValue(json['image']),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _stringValue(dynamic value) => value?.toString() ?? '';

  static String? _nullableStringValue(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }
}
