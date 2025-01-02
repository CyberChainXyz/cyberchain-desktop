class ProgramInfo {
  final String name;
  final String version;
  final String downloadUrl;
  final String localPath;
  final bool isRunning;
  final String output;

  const ProgramInfo({
    required this.name,
    required this.version,
    required this.downloadUrl,
    required this.localPath,
    this.isRunning = false,
    this.output = '',
  });

  ProgramInfo copyWith({
    String? name,
    String? version,
    String? downloadUrl,
    String? localPath,
    bool? isRunning,
    String? output,
  }) {
    return ProgramInfo(
      name: name ?? this.name,
      version: version ?? this.version,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      localPath: localPath ?? this.localPath,
      isRunning: isRunning ?? this.isRunning,
      output: output ?? this.output,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'downloadUrl': downloadUrl,
      'localPath': localPath,
    };
  }

  factory ProgramInfo.fromJson(Map<String, dynamic> json) {
    return ProgramInfo(
      name: json['name'] as String,
      version: json['version'] as String,
      downloadUrl: json['downloadUrl'] as String,
      localPath: json['localPath'] as String,
    );
  }

  @override
  String toString() {
    return 'ProgramInfo(name: $name, version: $version, localPath: $localPath)';
  }
}
