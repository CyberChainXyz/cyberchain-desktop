import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CyberchainInfoScreen extends StatelessWidget {
  const CyberchainInfoScreen({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildLink(BuildContext context, String name, String url) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.open_in_new, size: 18, color: Colors.blue[700]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[50]!,
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 600,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to CyberChain',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'A Layer 1 blockchain with GPU-friendly PoW, built for the next generation of decentralized applications.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                  ),
                ),
                const SizedBox(height: 48),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildLink(context, 'Website', 'https://cyberchain.xyz'),
                    _buildLink(
                        context, 'Explorer', 'https://scan.cyberchain.xyz'),
                    _buildLink(
                        context, 'Twitter', 'https://x.com/cyberchainxyz'),
                    _buildLink(
                        context, 'GitHub', 'https://github.com/CyberChainXyz'),
                    _buildLink(context, 'Discussions',
                        'https://github.com/orgs/CyberChainXyz/discussions'),
                  ],
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '© 2025 CyberChain',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
