import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/datasources/auto_categorizer.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/payment_method.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? existingExpense;

  const AddExpenseScreen({super.key, this.existingExpense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late Category _selectedCategory;
  late PaymentMethod _selectedPaymentMethod;
  late DateTime _selectedDate;
  late bool _isRecurring;

  bool get _isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.existingExpense;
    _amountController = TextEditingController(
      text: expense?.amount.toStringAsFixed(2) ?? '',
    );
    _descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );
    _selectedCategory = expense?.category ?? Category.defaults.first;
    _selectedPaymentMethod = expense?.paymentMethod ?? PaymentMethod.cash;
    _selectedDate = expense?.date ?? DateTime.now();
    _isRecurring = expense?.isRecurring ?? false;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAmountField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildCategorySelector(),
              const SizedBox(height: 16),
              _buildPaymentMethodSelector(),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildRecurringSwitch(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixText: '\u20B9 ',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Enter an amount';
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) return 'Enter a valid amount';
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'e.g. Lunch at cafe',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        if (!_isEditing && value.length > 2) {
          final suggested = AutoCategorizer.suggestCategory(value);
          if (suggested != null && suggested.id != _selectedCategory.id) {
            setState(() => _selectedCategory = suggested);
          }
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Enter a description';
        return null;
      },
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Category.defaults.map((category) {
            final isSelected = category.id == _selectedCategory.id;
            return ChoiceChip(
              avatar: Icon(category.icon, size: 18, color: isSelected ? Colors.white : category.color),
              label: Text(category.name),
              selected: isSelected,
              selectedColor: category.color,
              labelStyle: TextStyle(color: isSelected ? Colors.white : null),
              onSelected: (_) => setState(() => _selectedCategory = category),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return DropdownButtonFormField<PaymentMethod>(
      value: _selectedPaymentMethod,
      decoration: const InputDecoration(
        labelText: 'Payment Method',
        border: OutlineInputBorder(),
      ),
      items: PaymentMethod.values.map((method) {
        return DropdownMenuItem(value: method, child: Text(method.displayName));
      }).toList(),
      onChanged: (value) {
        if (value != null) setState(() => _selectedPaymentMethod = value);
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)),
      ),
    );
  }

  Widget _buildRecurringSwitch() {
    return SwitchListTile(
      title: const Text('Recurring Expense'),
      subtitle: const Text('Mark as a recurring/subscription expense'),
      value: _isRecurring,
      onChanged: (value) => setState(() => _isRecurring = value),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton.icon(
      onPressed: _submit,
      icon: Icon(_isEditing ? Icons.save : Icons.add),
      label: Text(_isEditing ? 'Update Expense' : 'Add Expense'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final expense = Expense(
      id: widget.existingExpense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      paymentMethod: _selectedPaymentMethod,
      isRecurring: _isRecurring,
    );

    final bloc = context.read<ExpenseBloc>();
    if (_isEditing) {
      bloc.add(UpdateExpenseEvent(expense));
    } else {
      bloc.add(AddExpenseEvent(expense));
    }

    Navigator.pop(context);
  }
}
