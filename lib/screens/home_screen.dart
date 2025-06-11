import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'budget_screen.dart';
import 'income_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _expenses = [];
  final List<Map<String, dynamic>> _income = [];
  String _selectedCategory = 'All';
  double? _monthlyBudget;
  bool _isExpanded = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fetchExpenses();
    _fetchIncome();
  }

  void logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  List<Map<String, dynamic>> get filteredExpenses {
    if (_selectedCategory == 'All') return _expenses;
    return _expenses.where((e) => e['category'] == _selectedCategory).toList();
  }

  void addExpense() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _AddExpenseDialog(),
    );
    if (result != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('expenses').add({
        'amount': result['amount'],
        'category': result['category'],
        'timestamp': Timestamp.now(),
        'uid': user.uid,
      });

      _fetchExpenses();

      final total = _expenses.fold(0.0, (sum, e) => sum + e['amount']);
      if (_monthlyBudget != null) {
        if (total >= _monthlyBudget!) {
          _showSnackBar('⚠ You have exceeded your budget!');
        } else if (total >= _monthlyBudget! * 0.8) {
          _showSnackBar('⚠ You are nearing your budget limit.');
        }
      }
    }
  }

  void _fetchExpenses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('expenses')
            .where('uid', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      _expenses.clear();
      _expenses.addAll(snapshot.docs.map((doc) => doc.data()));
    });
  }

  void _fetchIncome() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('income')
            .where('uid', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      _income.clear();
      _income.addAll(snapshot.docs.map((doc) => doc.data()));
    });
  }

  void _openBudgetScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BudgetScreen(
              currentBudget: _monthlyBudget,
              onBudgetSet: (value) {
                setState(() => _monthlyBudget = value);
              },
            ),
      ),
    );
  }

  void _openIncomeScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IncomeScreen()),
    );
    _fetchIncome();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _toggleFab() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalExpense = _expenses.fold(0.0, (sum, e) => sum + e['amount']);
    final totalIncome = _income.fold(0.0, (sum, e) => sum + e['amount']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _selectedCategory,
              items:
                  ['All', 'Food', 'Transport', 'Shopping', 'Other']
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 10),
            Text(
              'Total: RM ${totalExpense.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Income: RM ${totalIncome.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            if (_monthlyBudget != null)
              Text(
                'Budget: RM ${_monthlyBudget!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.teal),
              ),
            if (_monthlyBudget != null && totalExpense > _monthlyBudget!)
              const Text(
                '⚠ You are over budget!',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredExpenses.length,
                itemBuilder: (ctx, i) {
                  final e = filteredExpenses[i];
                  return ListTile(
                    title: Text('RM ${e['amount'].toStringAsFixed(2)}'),
                    subtitle: Text(e['category']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 210,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.only(bottom: 70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: 'Add Expense',
                      child: FloatingActionButton(
                        heroTag: 'addExpense',
                        mini: true,
                        onPressed: () {
                          _toggleFab();
                          addExpense();
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Tooltip(
                      message: 'Set Budget',
                      child: FloatingActionButton(
                        heroTag: 'setBudget',
                        mini: true,
                        onPressed: () {
                          _toggleFab();
                          _openBudgetScreen();
                        },
                        child: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Tooltip(
                      message: 'Log Income',
                      child: FloatingActionButton(
                        heroTag: 'logIncome',
                        mini: true,
                        onPressed: () {
                          _toggleFab();
                          _openIncomeScreen();
                        },
                        child: const Icon(Icons.savings),
                      ),
                    ),
                  ],
                ),
              ),
            FloatingActionButton(
              heroTag: 'mainFab',
              onPressed: _toggleFab,
              child: Icon(_isExpanded ? Icons.close : Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddExpenseDialog extends StatefulWidget {
  const _AddExpenseDialog();

  @override
  State<_AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<_AddExpenseDialog> {
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (RM)'),
          ),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            items:
                ['Food', 'Transport', 'Shopping', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
            onChanged: (val) => setState(() => _selectedCategory = val!),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            if (amount != null) {
              Navigator.pop(context, {
                'amount': amount,
                'category': _selectedCategory,
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
