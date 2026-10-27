class University {
  final String name;
  final String country;
  final String? domain;
  final String? website;

  const University({
    required this.name,
    required this.country,
    this.domain,
    this.website,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: (json['name'] as String? ?? '').trim(),
      country: (json['country'] as String? ?? '').trim(),
      domain: _firstValue(json['domains']),
      website: _firstValue(json['web_pages']),
    );
  }

  static String? _firstValue(dynamic value) {
    if (value is! List) return null;

    for (final item in value) {
      if (item is String && item.trim().isNotEmpty) {
        return item.trim();
      }
    }

    return null;
  }
}
