import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Same method style as your example
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.recycling, size: 34, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'SmartRecycle SG',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'SmartRecycle SG helps users recycle correctly using a waste sorting guide, recycling locations, reminders, and community tips.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 18),

              const Text(
                'Key Features',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const _Bullet(text: 'Waste Sorting Guide (search items and learn how to dispose of them).'),
              const _Bullet(text: 'Recycling Locations (view available recycling points).'),
              const _Bullet(text: 'Reminders (set weekly recycling reminders).'),
              const _Bullet(text: 'Tips & Feedback (share helpful tips with others).'),

              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 12),

              // ✅ New Contact section using your example method
              const Text(
                'Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              buildClickableInfoTile(
                title: 'Contact Number',
                info: '+65 6123 4567',
                url: 'tel:+6561234567',
              ),
              buildClickableInfoTile(
                title: 'Email',
                info: 'smartrecyclesg@gmail.com',
                url: 'mailto:smartrecyclesg@gmail.com',
              ),

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 12),

              const Text(
                'Version',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('v1.0.0'),
            ],
          ),
        ),
      ),
    );
  }

  // Same helper structure as your example
  Widget buildInfoTile({required String title, required String info}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            info,
            style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget buildClickableInfoTile({
    required String title,
    required String info,
    required String url,
  }) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              info,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 16, height: 1.3)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}