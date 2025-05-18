import 'package:equatable/equatable.dart';

abstract class ExpenseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {} 