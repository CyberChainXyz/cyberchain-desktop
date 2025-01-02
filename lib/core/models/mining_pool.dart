class MiningPool {
  final String name;
  final String url;

  const MiningPool({
    required this.name,
    required this.url,
  });

  factory MiningPool.fromJson(Map<String, dynamic> json) {
    return MiningPool(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiningPool &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}
