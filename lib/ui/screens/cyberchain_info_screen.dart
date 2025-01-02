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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Future of Web3 Infrastructure',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'A Layer 1 blockchain with GPU-friendly PoW, built for the next generation of decentralized applications.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _buildLink('Website', 'https://cyberchain.xyz'),
              _buildLink('Explorer', 'https://scan.cyberchain.xyz'),
              _buildLink('Twitter', 'https://x.com/opencyberxyz'),
              _buildLink('GitHub', 'https://github.com/CyberChainXyz'),
              _buildLink('Discussions',
                  'https://github.com/orgs/CyberChainXyz/discussions'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLink(String name, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
          fontSize: 16,
        ),
      ),
    );
  }
}
