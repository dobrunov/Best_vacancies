import 'dart:developer';

import 'package:flutter/material.dart';

class AllVacanciesPage extends StatelessWidget {
  final List<Map<String, dynamic>> vacancies;

  const AllVacanciesPage({super.key, required this.vacancies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All vacancies')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All vacancies:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...vacancies.map((vacancies) => Text('- ${vacancies['position']}')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          log("most save");
        },
      ),
    );
  }
}
