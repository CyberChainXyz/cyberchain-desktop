import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum DicebearStyle {
  adventurer('Adventurer'),
  avataaars('Avataaars'),
  bigEars('Big Ears'),
  bottts('Bottts'),
  funEmoji('Fun Emoji'),
  lorelei('Lorelei'),
  notionists('Notionists'),
  openPeeps('Open Peeps'),
  personas('Personas'),
  pixelArt('Pixel Art'),
  thumbs('Thumbs');

  final String displayName;
  const DicebearStyle(this.displayName);
}

class AvatarGenerator {
  // Fixed seeds for consistent avatars
  static const List<String> seeds = [
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

  static String _getStylePath(DicebearStyle style) {
    switch (style) {
      case DicebearStyle.adventurer:
        return 'adventurer';
      case DicebearStyle.avataaars:
        return 'avataaars';
      case DicebearStyle.bigEars:
        return 'big-ears';
      case DicebearStyle.bottts:
        return 'bottts';
      case DicebearStyle.funEmoji:
        return 'fun-emoji';
      case DicebearStyle.lorelei:
        return 'lorelei';
      case DicebearStyle.notionists:
        return 'notionists';
      case DicebearStyle.openPeeps:
        return 'open-peeps';
      case DicebearStyle.personas:
        return 'personas';
      case DicebearStyle.pixelArt:
        return 'pixel-art';
      case DicebearStyle.thumbs:
        return 'thumbs';
    }
  }

  static DicebearStyle _getStyleFromPath(String path) {
    return DicebearStyle.values.firstWhere(
      (style) => _getStylePath(style) == path,
      orElse: () => DicebearStyle.avataaars,
    );
  }

  static String generateAvatarId(String seed, DicebearStyle style) {
    return 'dicebear:${_getStylePath(style)}:$seed';
  }

  static (String seed, DicebearStyle style) parseAvatarId(String avatarId) {
    final parts = avatarId.split(':');
    if (parts.length != 3 || parts[0] != 'dicebear') {
      return ('felix', DicebearStyle.avataaars); // Default fallback
    }
    return (parts[2], _getStyleFromPath(parts[1]));
  }

  static String getAvatarAssetPath(
    String seed, {
    DicebearStyle style = DicebearStyle.avataaars,
  }) {
    final stylePath = _getStylePath(style);
    return 'assets/avatars/$stylePath/$seed.svg';
  }

  static Widget buildAvatar(
    String seed, {
    double size = 48,
    DicebearStyle style = DicebearStyle.avataaars,
  }) {
    final assetPath = getAvatarAssetPath(seed, style: style);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        placeholderBuilder: (context) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade100,
          child: Center(
            child: SizedBox(
              width: size * 0.3,
              height: size * 0.3,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildAvatarFromId(
    String avatarId, {
    double size = 48,
  }) {
    final (seed, style) = parseAvatarId(avatarId);
    return buildAvatar(
      seed,
      style: style,
      size: size,
    );
  }

  static Widget buildAvatarGrid(
    String selectedSeed,
    DicebearStyle style,
    void Function(String) onSeedSelected, {
    double avatarSize = 64,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: seeds.length,
      itemBuilder: (context, index) {
        final seed = seeds[index];
        final isSelected = seed == selectedSeed;
        return InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: () => onSeedSelected(seed),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(2),
            child: buildAvatar(seed, style: style, size: avatarSize),
          ),
        );
      },
    );
  }
}
