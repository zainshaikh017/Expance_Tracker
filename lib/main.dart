import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system, // Light ya dark mode system se
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStatePropertyAll(Colors.white),
          fillColor: WidgetStatePropertyAll(Colors.teal),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStatePropertyAll(Colors.white),
          fillColor: WidgetStatePropertyAll(Colors.orange),
        ),
      ),

      title: 'Expense Tracker',
      home: ExpenseTrackerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExpenseTrackerScreen extends StatefulWidget {
  @override
  _ExpenseTrackerScreenState createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isExpense = true;
  Map<String, bool> categories = {
    'Petrol': false,
    'Food': false,
    'Transport': false,
    'Other': false,
  };

  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('transactions');
    if (data != null) {
      setState(() {
        transactions = List<Map<String, dynamic>>.from(json.decode(data));
      });
    }
  }

  Future<void> saveTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('transactions', json.encode(transactions));
  }

  void addTransaction() {
    if (amountController.text.isEmpty) return;

    double amount = double.tryParse(amountController.text) ?? 0;
    String description = descriptionController.text;
    DateTime now = DateTime.now();

    List<String> selectedCategories = categories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    Map<String, dynamic> newTransaction = {
      'amount': amount,
      'description': description,
      'categories': selectedCategories,
      'isExpense': isExpense,
      'timestamp': now.toIso8601String(),
    };

    setState(() {
      transactions.add(newTransaction);
    });

    amountController.clear();
    descriptionController.clear();
    categories.updateAll((key, value) => false);
    saveTransactions();
  }

  void calculateTotalExpense() {
    double totalExpense = 0;
    double totalIncome = 0;
    Map<String, double> categoryTotals = {
      'Petrol': 0,
      'Food': 0,
      'Transport': 0,
      'Other': 0,
    };

    for (var tx in transactions) {
      double amount = tx['amount'];
      bool isExp = tx['isExpense'];

      if (isExp) {
        totalExpense += amount;
        List<dynamic> txCategories = tx['categories'];
        for (String cat in txCategories) {
          if (categoryTotals.containsKey(cat)) {
            categoryTotals[cat] = categoryTotals[cat]! + amount;
          }
        }
      } else {
        totalIncome += amount;
      }
    }

    double remaining = totalIncome - totalExpense;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Summary'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('💰 Total Income: PKR${totalIncome.toStringAsFixed(2)}'),
              Text('💸 Total Expense: PKR${totalExpense.toStringAsFixed(2)}'),
              SizedBox(height: 10),
              Text('📊 Category-wise Expense:'),
              for (var entry in categoryTotals.entries)
                Text('${entry.key}: PKR${entry.value.toStringAsFixed(2)}'),
              SizedBox(height: 10),
              Text(
                '🧾 Remaining Balance: PKR${remaining.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: remaining >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void editTransaction(int index) {
    final tx = transactions[index];
    amountController.text = tx['amount'].toString();
    descriptionController.text = tx['description'];
    isExpense = tx['isExpense'];

    categories.updateAll((key, value) => false); // Reset all categories
    for (var category in tx['categories']) {
      if (categories.containsKey(category)) {
        categories[category] = true;
      }
    }

    setState(() {
      transactions.removeAt(index); // Remove transaction for edit
    });
  }

  void deleteTransaction(int index) {
    setState(() {
      transactions.removeAt(index);
    });
    saveTransactions();
  }

  // Generate report
  // Generate detailed printable report

  Future<void> generatePrintableReport() async {
    final pdf = pw.Document();

    // Calculate totals
    double totalExpense = 0;
    double totalIncome = 0;
    Map<String, double> categoryTotals = {};

    for (var tx in transactions) {
      double amt = tx['amount'];
      bool isExp = tx['isExpense'];
      List<String> cats = List<String>.from(tx['categories']);

      if (isExp) {
        totalExpense += amt;
      } else {
        totalIncome += amt;
      }

      for (String cat in cats) {
        categoryTotals[cat] = (categoryTotals[cat] ?? 0) + (isExp ? amt : 0);
      }
    }

    double remaining = totalIncome - totalExpense;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text(
              'Expense Tracker Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.SizedBox(height: 20),
          pw.Text(
            'Detailed Transactions:',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),

          ...transactions.map((tx) {
            return pw.Container(
              margin: pw.EdgeInsets.only(bottom: 12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Text('Amount:', style: pw.TextStyle(fontSize: 14)),
                      pw.Spacer(),
                      pw.Text(
                        'PKR${tx['amount'].toStringAsFixed(2)}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Description: ${tx['description']}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    'Categories: ${tx['categories'].join(', ')}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    'Date: ${DateTime.parse(tx['timestamp']).toLocal()}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    'Type: ${tx['isExpense'] ? 'Expense' : 'Income'}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }),

          pw.Divider(),
          pw.SizedBox(height: 10),

          pw.Text(
            'Summary:',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),

          pw.Row(
            children: [
              pw.Text('Total Income:', style: pw.TextStyle(fontSize: 14)),
              pw.Spacer(),
              pw.Text(
                'PKR${totalIncome.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 14),
              ),
            ],
          ),

          pw.Row(
            children: [
              pw.Text('Total Expense:', style: pw.TextStyle(fontSize: 14)),

              pw.Spacer(),
              pw.Text(
                'PKR${totalExpense.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Text('Remaining Balance:', style: pw.TextStyle(fontSize: 14)),
              pw.Spacer(),
              pw.Text(
                'PKR${remaining.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 14),
              ),
            ],
          ),

          pw.SizedBox(height: 10),
          pw.Text(
            'Category-wise Expenses:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),

          ...categoryTotals.entries.map((entry) {
            return pw.Row(
              children: [
                pw.Text("${entry.key}:", style: pw.TextStyle(fontSize: 14)),
                pw.Spacer(),
                pw.Text(
                  'PKR${entry.value.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 14),
                ),
              ],
            );
          }),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Expense Tracker'),

        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: ElevatedButton(
              onPressed:
                  generatePrintableReport, // Call report generation function
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
                foregroundColor: Theme.of(
                  context,
                ).elevatedButtonTheme.style?.foregroundColor?.resolve({}),
              ),
              child: Text('Generate Report'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: ElevatedButton(
              onPressed: calculateTotalExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
                foregroundColor: Theme.of(
                  context,
                ).elevatedButtonTheme.style?.foregroundColor?.resolve({}),
              ),

              child: Text('Calculate'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description (optional)'),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: isExpense,
                  onChanged: (value) => setState(() => isExpense = value!),
                ),
                Text(isExpense ? 'Expense' : 'Income'),
              ],
            ),
            Wrap(
              spacing: 10,
              children: categories.keys.map((cat) {
                return FilterChip(
                  label: Text(cat),
                  selected: categories[cat]!,
                  onSelected: (val) {
                    setState(() {
                      categories[cat] = val;
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: addTransaction, child: Text('Add Entry')),

            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        tx['isExpense']
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: tx['isExpense'] ? Colors.red : Colors.green,
                      ),
                      title: Text('PKR${tx['amount']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tx['description'] != '') Text(tx['description']),
                          Text("Categories: ${tx['categories'].join(', ')}"),
                          Text(
                            "Date: ${DateTime.parse(tx['timestamp']).toLocal()}",
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => editTransaction(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => deleteTransaction(index),
                          ),
                        ],
                      ),
                    ),
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
