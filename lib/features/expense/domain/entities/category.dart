import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double? budgetLimit;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.budgetLimit,
  });

  @override
  List<Object?> get props => [id, name, icon, color, budgetLimit];

  static const List<Category> defaults = [
    Category(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    Category(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car,
      color: Colors.blue,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.purple,
    ),
    Category(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: Icons.receipt_long,
      color: Colors.red,
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.pink,
    ),
    Category(
      id: 'health',
      name: 'Health',
      icon: Icons.local_hospital,
      color: Colors.green,
    ),
    Category(
      id: 'education',
      name: 'Education',
      icon: Icons.school,
      color: Colors.teal,
    ),
    Category(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.local_grocery_store,
      color: Colors.lime,
    ),
    Category(
      id: 'other',
      name: 'Other',
      icon: Icons.more_horiz,
      color: Colors.grey,
    ),
  ];
}
