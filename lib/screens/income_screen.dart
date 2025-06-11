import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _amountController = TextEditingController();
  String _selectedSource = 'Salary';
  final List<String> _sources = ['Salary', 'Business', 'Gift', 'Other'];

  void _saveIncome() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final amount = double.tryParse(_amountController.text);

    if (amount == null || uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid input or user not logged in.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('income').add({
        'uid': uid,
        'amount': amount,
        'source': _selectedSource,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Income added successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Income')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount (RM)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedSource,
              items:
                  _sources
                      .map(
                        (src) => DropdownMenuItem(value: src, child: Text(src)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedSource = value!),
              decoration: const InputDecoration(labelText: 'Source'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveIncome,
              child: const Text('Save Income'),
            ),
          ],
        ),
      ),
    );
  }
}
