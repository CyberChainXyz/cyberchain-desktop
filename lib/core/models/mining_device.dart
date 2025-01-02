class MiningDevice {
  final String id;
  final String name;
  final String type;
  final bool isAvailable;

  const MiningDevice({
    required this.id,
    required this.name,
    required this.type,
    this.isAvailable = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiningDevice &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
