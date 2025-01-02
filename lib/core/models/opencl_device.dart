class OpenCLDevice {
  final int id;
  final String name;
  final String vendor;

  const OpenCLDevice({
    required this.id,
    required this.name,
    required this.vendor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenCLDevice &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  static List<OpenCLDevice> parseDevices(String output) {
    if (output.trim().isEmpty) {
      return [];
    }

    final devices = <OpenCLDevice>[];
    final lines = output.split('\n');

    // Skip the "Available OpenCL devices:" line if present
    int startIndex = lines[0].contains('Available OpenCL devices:') ? 1 : 0;

    for (var i = startIndex; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Parse line like: [1] Intel(R) Iris(R) Xe Graphics [0x9a49] (Vendor: Intel(R) Corporation)
      final match = RegExp(r'\[(\d+)\] (.*?) \[(.*?)\] \(Vendor: (.*?)\)')
          .firstMatch(line);

      if (match != null) {
        devices.add(OpenCLDevice(
          id: int.parse(match.group(1)!),
          name: match.group(2)!,
          vendor: match.group(4)!,
        ));
      }
    }

    return devices;
  }
}
