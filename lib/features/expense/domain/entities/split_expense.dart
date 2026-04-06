import 'package:equatable/equatable.dart';

class Participant extends Equatable {
  final String name;
  final double share;
  final bool isPaid;

  const Participant({
    required this.name,
    required this.share,
    this.isPaid = false,
  });

  Participant copyWith({String? name, double? share, bool? isPaid}) {
    return Participant(
      name: name ?? this.name,
      share: share ?? this.share,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  @override
  List<Object?> get props => [name, share, isPaid];
}

class SplitExpense extends Equatable {
  final String id;
  final String description;
  final double totalAmount;
  final String paidBy;
  final DateTime date;
  final List<Participant> participants;

  const SplitExpense({
    required this.id,
    required this.description,
    required this.totalAmount,
    required this.paidBy,
    required this.date,
    required this.participants,
  });

  double get settledAmount =>
      participants.where((p) => p.isPaid).fold(0.0, (s, p) => s + p.share);

  double get unsettledAmount => totalAmount - settledAmount;

  bool get isFullySettled => participants.every((p) => p.isPaid);

  @override
  List<Object?> get props => [id, description, totalAmount, paidBy, date, participants];
}
