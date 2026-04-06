import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SavingsGoal extends Equatable {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;
  final IconData icon;
  final Color color;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
    required this.icon,
    required this.color,
  });

  double get progress => (savedAmount / targetAmount).clamp(0.0, 1.0);
  double get remaining => (targetAmount - savedAmount).clamp(0, targetAmount);
  bool get isCompleted => savedAmount >= targetAmount;

  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  double get dailySavingsNeeded {
    final days = daysRemaining;
    if (days <= 0 || isCompleted) return 0;
    return remaining / days;
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    IconData? icon,
    Color? color,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: deadline ?? this.deadline,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [id, name, targetAmount, savedAmount, deadline, icon, color];
}
