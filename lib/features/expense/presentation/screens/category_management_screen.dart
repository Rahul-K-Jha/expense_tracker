import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: Category.defaults.length,
        itemBuilder: (context, index) {
          final category = Category.defaults[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: category.color.withValues(alpha: 0.2),
                child: Icon(category.icon, color: category.color),
              ),
              title: Text(category.name),
              subtitle: category.budgetLimit != null
                  ? Text('Budget: \u20B9${category.budgetLimit!.toStringAsFixed(2)}')
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context, category),
            ),
          );
        },
      ),
    );
  }
}
