import 'package:expance_manager/main.dart';
import 'package:expance_manager/screen/add_entry.dart';
import 'package:expance_manager/screen/expense_tracker_screen.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
// ignore: must_be_immutable
class MainTabScreen extends StatelessWidget {
  void calculateTotalExpense(BuildContext context) {
    double totalExpense = 0;
    double totalIncome = 0;
    Map<String, double> categoryTotals = {
      'Petrol': 0,
      'Food': 0,
      'Transport': 0,
      'Other': 0,
    };

    // for (var tx in transactions) {
    for (var tx in filteredTransactions) {
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
   
    DateTime selectedMonth = DateTime.now();

  MainTabScreen({super.key});
  
  List<Map<String, dynamic>> get filteredTransactions {
  return transactions.where((tx) {
    DateTime txDate = DateTime.parse(tx['timestamp']);
    return txDate.year == selectedMonth.year &&
           txDate.month == selectedMonth.month;
  }).toList();
}


 Future<void> generatePrintableReport() async {
    final pdf = pw.Document();

    // Calculate totals
    double totalExpense = 0;
    double totalIncome = 0;
    Map<String, double> categoryTotals = {};

    // for (var tx in transactions) {
    for (var tx in filteredTransactions) {
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

          // ...transactions.map((tx) {
          ...filteredTransactions.map((tx) {
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



  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LedgerMate'),
        actions: [
           Align(
  alignment: Alignment.centerRight,
  child: Wrap(
    spacing: 12,
    runSpacing: 8,
    children: [
      ElevatedButton.icon(
        onPressed: () => calculateTotalExpense(context),
        icon: Icon(Icons.calculate),
        label: Text('Calculate'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      ElevatedButton.icon(
        onPressed: generatePrintableReport,
        icon: Icon(Icons.picture_as_pdf),
        label: Text('Report'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ],
  ),
),
        ],
        bottom: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.list,), text: 'Overview',
            
            ),
            Tab(icon: Icon(Icons.add), text: 'Add Entry'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          ExpenseTrackerScreen(), // Your main screen
          AddEntryTab(), // New tab for Add Entry
        ],
      ),
    );
  }
}