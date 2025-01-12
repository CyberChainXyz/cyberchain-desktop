import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/version_provider.dart';
import '../../core/services/version_service.dart';
import '../../core/services/update_checker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cyberchain_info_screen.dart';
import '../views/go_cyberchain_view.dart';
import '../views/xminer_view.dart';
import '../../features/chat/views/chat_view.dart';
import 'download_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  int? _hoveredIndex;

  final _navigationItems = [
    (
      icon: Icons.lan,
      label: 'Node',
      tooltip: 'Run CyberChain Node',
      view: GoCyberchainView(),
    ),
    (
      icon: Icons.memory,
      label: 'xMiner',
      tooltip: 'Start One-Click Mining',
      view: XMinerView(),
    ),
    (
      icon: Icons.chat_bubble_outline,
      label: 'Chat',
      tooltip: 'Community Chat',
      view: ChatView(),
    ),
    (
      icon: Icons.info_outline,
      label: 'About',
      tooltip: 'About CyberChain',
      view: CyberchainInfoScreen(),
    ),
  ];

  void _launchGitHub() async {
    final uri = Uri.parse(VersionService.githubUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchReleasePage() async {
    try {
      final versionService = ref.read(versionServiceProvider);
      final releaseUrl = versionService.getLatestReleaseUrl();

      if (releaseUrl == null) {
        return;
      }

      final uri = Uri.parse(releaseUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // print('Error launching release page: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentVersion = ref.watch(currentVersionProvider);
    final hasUpdate = ref.watch(hasUpdateProvider);
    final hasProgramUpdates = ref.watch(programsUpdateProvider);

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 200,
            child: Column(
              children: [
                // Logo section
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    children: [
                      const Image(
                        image: AssetImage('assets/images/logo.png'),
                        width: 56,
                        height: 56,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "2025-CCX",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                // Navigation section
                Expanded(
                  child: Container(
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.95),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        for (final item in _navigationItems)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            child: _selectedIndex ==
                                    _navigationItems.indexOf(item)
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      child: Row(
                                        children: [
                                          Icon(
                                            item.icon,
                                            size: 24,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          const SizedBox(width: 14),
                                          Text(
                                            item.label,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Tooltip(
                                    message: item.tooltip,
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      onEnter: (_) => setState(() =>
                                          _hoveredIndex =
                                              _navigationItems.indexOf(item)),
                                      onExit: (_) =>
                                          setState(() => _hoveredIndex = null),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedIndex =
                                                _navigationItems.indexOf(item);
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _hoveredIndex ==
                                                    _navigationItems
                                                        .indexOf(item)
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .surfaceVariant
                                                    .withOpacity(0.6)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 16),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  item.icon,
                                                  size: 24,
                                                  color: _hoveredIndex ==
                                                          _navigationItems
                                                              .indexOf(item)
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                                const SizedBox(width: 14),
                                                Text(
                                                  item.label,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: _hoveredIndex ==
                                                            _navigationItems
                                                                .indexOf(item)
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Version info section
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasProgramUpdates)
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DownloadScreen(fromHome: true),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[600],
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.update,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Programs Update',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (hasUpdate)
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: InkWell(
                              onTap: _launchReleasePage,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[600],
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.system_update,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Update Available',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: InkWell(
                            onTap: _launchGitHub,
                            child: Text(
                              'v${currentVersion.value ?? ""}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                for (final item in _navigationItems) item.view,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
