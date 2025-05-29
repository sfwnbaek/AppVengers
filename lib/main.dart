import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MyApp());

Map<String, String> registeredUser = {
  'email': 'user@example.com',
  'password': '123456',
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Expense Tracker', home: LoginScreen());
  }
}

// ------------------ LOGIN SCREEN ------------------
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email == registeredUser['email'] &&
        password == registeredUser['password']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid credentials')));
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Password reset link sent!')));
  }

  void _goToSignUp() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 300),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Login')),
            TextButton(
              onPressed: _forgotPassword,
              child: Text('Forgot Password?'),
            ),
            TextButton(onPressed: _goToSignUp, child: Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}

// ------------------ SIGN UP SCREEN ------------------
class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _signUp() {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      registeredUser = {'email': email, 'password': password};
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up successful! Please log in.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid email and password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _signUp, child: Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}

// ------------------ HOME SCREEN ------------------
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _incomes = [];

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _navigateToAddExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddExpenseScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() => _expenses.add(result));
    }
  }

  void _navigateToBudget() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BudgetScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() => _incomes.add(result));
    }
  }

  void _navigateToReports() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReportScreen(expenses: _expenses)),
    );
  }

  double get totalExpenses =>
      _expenses.fold(0.0, (sum, item) => sum + item['amount']);
  double get totalIncome =>
      _incomes.fold(0.0, (sum, item) => sum + item['amount']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(Icons.arrow_downward, color: Colors.green),
                title: Text('Income'),
                trailing: Text('RM ${totalIncome.toStringAsFixed(2)}'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.arrow_upward, color: Colors.red),
                title: Text('Expenses'),
                trailing: Text('RM ${totalExpenses.toStringAsFixed(2)}'),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Add Expense'),
              onPressed: _navigateToAddExpense,
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.account_balance_wallet),
              label: Text('Log Income'),
              onPressed: _navigateToBudget,
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.bar_chart),
              label: Text('View Reports'),
              onPressed: _navigateToReports,
            ),
            SizedBox(height: 20),
            Text('Expense List:', style: TextStyle(fontSize: 18)),
            Expanded(
              child:
                  _expenses.isEmpty
                      ? Text('No expenses yet.')
                      : ListView.builder(
                        itemCount: _expenses.length,
                        itemBuilder: (context, index) {
                          final expense = _expenses[index];
                          return ListTile(
                            leading: Icon(Icons.attach_money),
                            title: Text(
                              'RM ${expense['amount'].toStringAsFixed(2)}',
                            ),
                            subtitle: Text(expense['category']),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ ADD EXPENSE SCREEN ------------------
class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  final List<String> _categories = ['Food', 'Transport', 'Shopping', 'Other'];

  void _saveExpense() {
    final amountText = _amountController.text;
    final amount = double.tryParse(amountText);
    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid amount')));
      return;
    }
    Navigator.pop(context, {'amount': amount, 'category': _selectedCategory});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Expense')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount (RM)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items:
                  _categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveExpense,
              child: Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ BUDGET SCREEN ------------------
class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _amountController = TextEditingController();
  String _selectedSource = 'Salary';
  final List<String> _sources = ['Salary', 'Business', 'Gift', 'Other'];

  void _saveIncome() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid amount')));
      return;
    }
    Navigator.pop(context, {'amount': amount, 'source': _selectedSource});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log Income')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount (RM)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedSource,
              items:
                  _sources
                      .map(
                        (src) => DropdownMenuItem(value: src, child: Text(src)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedSource = value!),
              decoration: InputDecoration(labelText: 'Source'),
            ),
            SizedBox(height: 30),
            ElevatedButton(onPressed: _saveIncome, child: Text('Save Income')),
          ],
        ),
      ),
    );
  }
}

// ------------------ REPORT SCREEN ------------------
class ReportScreen extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;

  ReportScreen({required this.expenses});

  Map<String, double> _calculateTotals() {
    Map<String, double> totals = {};
    for (var exp in expenses) {
      totals[exp['category']] = (totals[exp['category']] ?? 0) + exp['amount'];
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final data = _calculateTotals();
    final categories = data.keys.toList();

    return Scaffold(
      appBar: AppBar(title: Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Expense Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: List.generate(categories.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[categories[i]]!,
                          width: 20,
                          color: Colors.blue,
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget:
                            (value, meta) => Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                categories[value.toInt()],
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
