typedef Semver3 = ({int major, int minor, int patch});

Semver3? tryParseSemver3(String input) {
  final match = RegExp(r'(\d+)\.(\d+)\.(\d+)').firstMatch(input);
  if (match == null) {
    return null;
  }

  return (
    major: int.parse(match.group(1)!),
    minor: int.parse(match.group(2)!),
    patch: int.parse(match.group(3)!),
  );
}

/// Compares semantic versions (major.minor.patch) contained within strings.
///
/// Supports common tag formats like `v1.2.3`, `1.2.3`, `v1.2.3-beta`.
/// If either input cannot be parsed, it falls back to string comparison.
int compareSemverTags(String a, String b) {
  final pa = tryParseSemver3(a);
  final pb = tryParseSemver3(b);

  if (pa == null || pb == null) {
    return a.compareTo(b);
  }

  if (pa.major != pb.major) {
    return pa.major.compareTo(pb.major);
  }
  if (pa.minor != pb.minor) {
    return pa.minor.compareTo(pb.minor);
  }
  return pa.patch.compareTo(pb.patch);
}

bool isSemverTagOlder(String installed, String required) =>
    compareSemverTags(installed, required) < 0;
