class MiningPool {
  final String name;
  final List<MiningPoolServer> servers;

  const MiningPool({
    required this.name,
    required this.servers,
  });

  factory MiningPool.fromJson(List<dynamic> json) {
    return MiningPool(
      name: json[0] as String,
      servers: (json[1] as List<dynamic>)
          .map((server) => MiningPoolServer.fromJson(server as List<dynamic>))
          .toList(),
    );
  }

  List<dynamic> toJson() {
    return [
      name,
      servers.map((server) => server.toJson()).toList(),
    ];
  }
}

class MiningPoolServer {
  final String name;
  final String url;

  const MiningPoolServer({
    required this.name,
    required this.url,
  });

  factory MiningPoolServer.fromJson(List<dynamic> json) {
    return MiningPoolServer(
      name: json[0] as String,
      url: json[1] as String,
    );
  }

  List<dynamic> toJson() {
    return [name, url];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiningPoolServer &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}
