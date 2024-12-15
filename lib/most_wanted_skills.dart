import 'package:flutter/material.dart';

class MostWantedPage extends StatelessWidget {
  final List<String> skills;

  const MostWantedPage({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Most Wanted Skills')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            ...skills.map((skill) => Text('- $skill')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          _saveSkills();
        },
      ),
    );
  }

  Future<void> _saveSkills() async {
    // await DatabaseHelper.instance.saveSkillsWithTimestamp(skills);
  }
}
