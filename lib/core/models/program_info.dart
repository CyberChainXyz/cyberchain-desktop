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
    String? version,
    String? downloadUrl,
    String? localPath,
    bool? isRunning,
    String? output,
  }) {
    return ProgramInfo(
      name: name,
      version: version ?? this.version,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      localPath: localPath ?? this.localPath,
      isRunning: isRunning ?? this.isRunning,
      output: output ?? this.output,
    );
  }
}
