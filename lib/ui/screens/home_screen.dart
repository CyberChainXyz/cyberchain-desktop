import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/version_provider.dart';
import '../../core/services/version_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cyberchain_info_screen.dart';
import '../views/go_cyberchain_view.dart';
import '../views/xminer_view.dart';
import '../../features/chat/views/chat_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

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

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            minWidth: 120,
            minExtendedWidth: 150,
            labelType: NavigationRailLabelType.all,
            leading: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 24, 0, 16),
                  child: Image(
                    image: AssetImage('assets/images/logo.png'),
                    width: 48,
                    height: 48,
                  ),
                ),
                Text(
                  "2025-CCX",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(thickness: 1),
                ),
                const SizedBox(height: 8),
              ],
            ),
            destinations: const [
              NavigationRailDestination(
                padding: EdgeInsets.symmetric(vertical: 12),
                icon: Icon(Icons.lan, size: 28),
                label: Text('CyberChain',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              NavigationRailDestination(
                padding: EdgeInsets.symmetric(vertical: 12),
                icon: Icon(Icons.memory, size: 28),
                label: Text('xMiner',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              NavigationRailDestination(
                padding: EdgeInsets.symmetric(vertical: 12),
                icon: Icon(Icons.chat_bubble_outline, size: 28),
                label: Text('Chat',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              NavigationRailDestination(
                padding: EdgeInsets.symmetric(vertical: 12),
                icon: Icon(Icons.info_outline, size: 28),
                label: Text('About',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasUpdate)
                        InkWell(
                          onTap: _launchReleasePage,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
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
                                SizedBox(width: 4),
                                Text(
                                  'Update Available',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      InkWell(
                        onTap: _launchGitHub,
                        child: Text(
                          'v${currentVersion.value ?? ""}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                GoCyberchainView(),
                XMinerView(),
                ChatView(),
                CyberchainInfoScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
