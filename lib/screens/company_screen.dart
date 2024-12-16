import 'package:flutter/material.dart';

import '../database_helper.dart';

class CompanyScreen extends StatefulWidget {
  final Map<String, dynamic> company;

  const CompanyScreen({super.key, required this.company});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late final Map<String, dynamic> company;

  @override
  void initState() {
    company = widget.company;
    super.initState();
  }

  void _showVacancyForm(BuildContext context, int companyId) {
    final positionController = TextEditingController();
    final skillsControllers = List.generate(10, (_) => TextEditingController());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Vacancy'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: positionController,
                  decoration: const InputDecoration(labelText: 'Position'),
                ),
                ...List.generate(10, (index) {
                  return TextField(
                    controller: skillsControllers[index],
                    decoration: InputDecoration(labelText: 'Skill ${index + 1}'),
                  );
                }),
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
                final currentContext = context;
                final newVacancy = {
                  'companyId': companyId,
                  'position': positionController.text,
                  'skills': skillsControllers.map((e) => e.text).toList().join(", "),
                };
                await _dbHelper.addVacancy(newVacancy);
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

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: widget.company['name']);
    final websiteController = TextEditingController(text: widget.company['website']);
    final addressController = TextEditingController(text: widget.company['address']);
    final emailController = TextEditingController(text: widget.company['email']);
    final linkedInController = TextEditingController(text: widget.company['linkedIn']);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.company['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit company form
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Edit Company'),
                    content: SingleChildScrollView(
                      child: Column(
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
                          final currentContext = context;

                          final updatedCompany = {
                            'name': nameController.text,
                            'website': websiteController.text,
                            'address': addressController.text,
                            'email': emailController.text,
                            'linkedIn': linkedInController.text,
                          };

                          await DatabaseHelper.instance.updateCompany(widget.company['id'], updatedCompany);
                          final newCompanyData = await DatabaseHelper.instance.getCompanyById(widget.company['id']);

                          if (newCompanyData != null) {
                            if (currentContext.mounted) {
                              setState(() {
                                company = newCompanyData;
                              });
                            }
                          }

                          if (currentContext.mounted) {
                            Navigator.pop(currentContext);
                          }
                        },
                        child: const Text('Save'),
                      )
                    ],
                  );
                },
              );
            },
          ),
          ElevatedButton(
            onPressed: () async {
              _showVacancyForm(context, widget.company['id']);
            },
            child: const Text('Add vacancy'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final currentContext = context;
              await DatabaseHelper.instance.deleteCompany(widget.company['id']);
              if (currentContext.mounted) {
                Navigator.pop(currentContext);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Name: ${widget.company['name']}'),
            ),
            ListTile(
              title: Text('Website: ${widget.company['website']}'),
            ),
            ListTile(
              title: Text('Address: ${widget.company['address']}'),
            ),
            ListTile(
              title: Text('Email: ${widget.company['email']}'),
            ),
            ListTile(
              title: Text('LinkedIn: ${widget.company['linkedIn']}'),
            ),
          ],
        ),
      ),
    );
  }
}
