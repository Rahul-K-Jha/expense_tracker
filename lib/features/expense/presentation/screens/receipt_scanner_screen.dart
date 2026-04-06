import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/datasources/receipt_scanner_service.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/payment_method.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final _scanner = ReceiptScannerService();
  final _picker = ImagePicker();
  bool _isScanning = false;
  ReceiptScanResult? _result;
  File? _imageFile;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _pickAndScan(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _isScanning = true;
      _imageFile = File(picked.path);
    });

    try {
      final result = await _scanner.scanReceipt(_imageFile!);
      setState(() {
        _result = result;
        _isScanning = false;
      });
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageSection(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            if (_isScanning) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Center(child: Text('Scanning receipt...')),
            ],
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_imageFile!, height: 250, fit: BoxFit.cover),
      );
    }
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text('No receipt scanned', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isScanning ? null : () => _pickAndScan(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isScanning ? null : () => _pickAndScan(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final result = _result!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scan Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _resultRow('Amount', result.amount != null
                ? '\u20B9${result.amount!.toStringAsFixed(2)}'
                : 'Not detected'),
            _resultRow('Merchant', result.merchant ?? 'Not detected'),
            _resultRow('Date', result.date?.toString().split(' ').first ?? 'Not detected'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _createExpense(),
                icon: const Icon(Icons.add),
                label: const Text('Create Expense'),
              ),
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: const Text('Raw Text'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    result.rawText,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _createExpense() {
    final result = _result;
    if (result == null) return;

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: result.amount ?? 0,
      category: Category.defaults.first,
      description: result.merchant ?? 'Scanned Receipt',
      date: result.date ?? DateTime.now(),
      paymentMethod: PaymentMethod.cash,
    );

    Navigator.pushNamed(context, '/add-expense', arguments: expense);
  }
}
