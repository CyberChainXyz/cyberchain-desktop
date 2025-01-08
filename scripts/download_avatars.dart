import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

// Avatar styles from the AvatarGenerator class
const styles = {
  'adventurer': 'adventurer',
  'avataaars': 'avataaars',
  'big-ears': 'big-ears',
  'bottts': 'bottts',
  'fun-emoji': 'fun-emoji',
  'lorelei': 'lorelei',
  'notionists': 'notionists',
  'open-peeps': 'open-peeps',
  'personas': 'personas',
  'pixel-art': 'pixel-art',
  'thumbs': 'thumbs',
};

// Fixed seeds from the AvatarGenerator class
const seeds = [
  'felix',
  'luna',
  'nova',
  'atlas',
  'orion',
  'stella',
  'leo',
  'aurora',
  'phoenix',
  'zeus',
  'iris',
  'titan',
  'lyra',
  'ares',
  'cora',
  'thor',
  'vega',
  'mars',
  'juno',
  'apollo',
];

Future<void> main() async {
  final baseUrl = 'https://api.dicebear.com/9.x';
  final baseDir = 'assets/avatars';

  for (final style in styles.entries) {
    final styleDir = path.join(baseDir, style.key);
    await Directory(styleDir).create(recursive: true);

    for (final seed in seeds) {
      final url = '$baseUrl/${style.value}/svg?seed=$seed';
      final fileName = '$seed.svg';
      final filePath = path.join(styleDir, fileName);

      try {
        print('Downloading $url');
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await File(filePath).writeAsBytes(response.bodyBytes);
          print('Successfully downloaded $fileName');
        } else {
          print('Failed to download $fileName: ${response.statusCode}');
        }
      } catch (e) {
        print('Error downloading $fileName: $e');
      }

      // Add a small delay to avoid rate limiting
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  print('Download completed!');
}
