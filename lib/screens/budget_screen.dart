import 'package:flutter/material.dart';

class BudgetScreen extends StatefulWidget {
  final double? currentBudget;
  final void Function(double) onBudgetSet;

  const BudgetScreen({
    super.key,
    this.currentBudget,
    required this.onBudgetSet,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentBudget != null) {
      _controller.text = widget.currentBudget!.toString();
    }
  }

  void _saveBudget() {
    final value = double.tryParse(_controller.text);
    if (value != null) {
      widget.onBudgetSet(value);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid budget amount')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Monthly Budget')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Budget (RM)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveBudget,
              child: const Text('Save Budget'),
            ),
          ],
        ),
      ),
    );
  }
}
