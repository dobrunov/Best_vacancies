import 'dart:developer';

import 'package:flutter/material.dart';

import '../database_helper.dart';
import 'all_vacancies_screen.dart';
import 'company_screen.dart';
import 'most_wanted_screen.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  CompanyListScreenState createState() => CompanyListScreenState();
}

class CompanyListScreenState extends State<CompanyListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _companies = [];

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    final data = await _dbHelper.fetchCompanies();
    setState(() {
      _companies = data;
    });
  }

  void _showCompanyForm({Map<String, dynamic>? company}) {
    final nameController = TextEditingController(text: company?['name'] ?? '');
    final websiteController = TextEditingController(text: company?['website'] ?? '');
    final addressController = TextEditingController(text: company?['address'] ?? '');
    final emailController = TextEditingController(text: company?['email'] ?? '');
    final linkedInController = TextEditingController(text: company?['linkedIn'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(company == null ? 'Add Company' : 'Edit Company'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                ),
                TextField(
                  controller: websiteController,
                  decoration: const InputDecoration(labelText: 'Website'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: linkedInController,
                  decoration: const InputDecoration(labelText: 'LinkedIn'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newCompany = {
                  'name': nameController.text,
                  'website': websiteController.text,
                  'address': addressController.text,
                  'email': emailController.text,
                  'linkedIn': linkedInController.text,
                };

                final currentContext = context;

                if (company == null) {
                  await _dbHelper.addCompany(newCompany);
                } else {
                  await _dbHelper.updateCompany(company['id'], newCompany);
                }

                await _loadCompanies();

                if (currentContext.mounted) {
                  Navigator.pop(currentContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToMostWanted() async {
    final mostWantedSkills = await _dbHelper.getMostWantedSkills(30);
    log(mostWantedSkills.toString());

    final currentContext = context;

    if (currentContext.mounted) {
      Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder: (context) => MostWantedScreen(skills: mostWantedSkills),
        ),
      );
    }
  }

  void _navigateToAllVacancies() async {
    final vacancies = await _dbHelper.fetchAllVacancies();
    log(vacancies.toString());

    final currentContext = context;

    if (currentContext.mounted) {
      Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder: (context) => AllVacanciesScreen(vacancies: vacancies),
        ),
      );
    }
  }

  void _navigateToCompanyPage(Map<String, dynamic> company) {
    final currentContext = context;

    if (currentContext.mounted) {
      Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder: (context) => CompanyScreen(company: company),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IT Companies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _navigateToMostWanted,
          ),
          IconButton(
            icon: const Icon(Icons.abc),
            onPressed: _navigateToAllVacancies,
          ),
        ],
      ),
      body: _companies.isEmpty
          ? const Center(child: Text('No companies added yet!'))
          : ListView.builder(
              itemCount: _companies.length,
              itemBuilder: (context, index) {
                final company = _companies[index];
                return ListTile(
                  title: Text(company['name']),
                  subtitle: Text(company['website']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _dbHelper.deleteCompany(company['id']);
                          await _loadCompanies();
                        },
                      ),
                    ],
                  ),
                  onTap: () => _navigateToCompanyPage(company),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showCompanyForm(),
      ),
    );
  }
}
