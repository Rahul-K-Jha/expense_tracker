import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../data/datasources/voice_expense_parser.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/payment_method.dart';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _recognizedText = '';
  ParsedVoiceExpense? _parsed;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    setState(() {});
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) return;

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _parsed = null;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
            _parsed = VoiceExpenseParser.parse(_recognizedText);
          }
        });
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      if (_recognizedText.isNotEmpty) {
        _parsed = VoiceExpenseParser.parse(_recognizedText);
      }
    });
  }

  void _createExpense() {
    if (_parsed == null) return;

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: _parsed!.amount ?? 0,
      category: _parsed!.category ?? Category.defaults.first,
      description: _parsed!.description ?? _recognizedText,
      date: DateTime.now(),
      paymentMethod: _parsed!.paymentMethod ?? PaymentMethod.cash,
    );

    Navigator.pushNamed(context, '/add-expense', arguments: expense);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Input')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            if (!_speechAvailable)
              const Center(
                child: Text(
                  'Speech recognition not available',
                  style: TextStyle(color: Colors.red),
                ),
              )
            else ...[
              const Center(
                child: Text(
                  'Try saying:',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  '"50 rupees for lunch at cafe by UPI"',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _isListening ? _stopListening : _startListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isListening ? 100 : 80,
                    height: _isListening ? 100 : 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
                      boxShadow: _isListening
                          ? [BoxShadow(color: Colors.red.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)]
                          : [],
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _isListening ? 'Listening...' : 'Tap to speak',
                  style: TextStyle(
                    color: _isListening ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            if (_recognizedText.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recognized:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(_recognizedText, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
            if (_parsed != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Parsed:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      _parsedRow('Amount', _parsed!.amount != null
                          ? '\u20B9${_parsed!.amount!.toStringAsFixed(2)}'
                          : 'Not detected'),
                      _parsedRow('Description', _parsed!.description ?? 'Not detected'),
                      _parsedRow('Category', _parsed!.category?.name ?? 'Not detected'),
                      _parsedRow('Payment', _parsed!.paymentMethod?.displayName ?? 'Not detected'),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _createExpense,
                          icon: const Icon(Icons.add),
                          label: const Text('Create Expense'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _parsedRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
