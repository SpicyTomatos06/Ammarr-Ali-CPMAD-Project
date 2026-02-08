import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              SizedBox(height: 12),
              Text(
                'SmartRecycle SG helps users recycle correctly using a waste sorting guide, recycling locations, reminders, and community tips.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              SizedBox(height: 18),
              Text('Key Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _Bullet(text: 'Waste Sorting Guide (search items and learn how to dispose of them).'),
              _Bullet(text: 'Recycling Locations (view available recycling points).'),
              _Bullet(text: 'Reminders (set weekly recycling reminders).'),
              _Bullet(text: 'Tips & Feedback (share helpful tips with others).'),
              SizedBox(height: 18),
              Divider(),
              SizedBox(height: 12),
              Text('Version', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('v1.0.0'),
            ],
          ),
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
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.3))),
        ],
      ),
    );
  }
}
