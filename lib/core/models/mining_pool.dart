class MiningPool {
  final String name;
  final String url;
  final String description;

  const MiningPool({
    required this.name,
    required this.url,
    required this.description,
  });

  factory MiningPool.fromJson(Map<String, dynamic> json) {
    return MiningPool(
      name: json['name'] as String,
      url: json['url'] as String,
      description: json['description'] as String,
    );
  }
}
