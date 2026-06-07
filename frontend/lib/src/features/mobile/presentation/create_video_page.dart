import 'package:flutter/material.dart';

class CreateVideoPage extends StatelessWidget {
  const CreateVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create video')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.video_file_outlined),
            label: const Text('Choose video'),
          ),
          const SizedBox(height: 16),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(labelText: 'Caption'),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: false,
            onChanged: (_) {},
            title: const Text('Subscribers only'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {},
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }
}
