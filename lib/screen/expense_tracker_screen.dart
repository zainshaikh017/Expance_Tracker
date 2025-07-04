import 'dart:convert';
import 'package:expance_manager/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:expance_manager/main.dart';
import 'package:expance_manager/screen/add_entry.dart';
import 'package:expance_manager/screen/expense_tracker_screen.dart';
import 'package:flutter/material.dart';

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
    'Home Expense': false,
    'gadges': false,
    // 'Entertainment': false,
    'Health': false,
    'Shopping': false,
    'Utilities': false,
    'Education': false,
    'Travel': false,
    // 'Gifts': false,
    // 'Subscriptions': false,
    'Investments': false,
    'Miscellaneous': false,
    'Bills': false,
    'Groceries': false,
    'Clothing': false,
    'Personal Care': false,
    'Dining Out': false,
    // 'Hobbies': false,
    // 'Fitness': false,
    // 'Charity': false,
    // 'Emergency Fund': false,
    // 'Savings': false,
    // 'Debt Repayment': false,
    // 'Taxes': false,
    // 'Insurance': false,
    // 'Rent/Mortgage': false,
    'Vehicle Maintenance': false,
    // 'Childcare': false,
    // 'Pet Care': false,
    // 'Home Improvement': false,
    // 'Technology': false,
    // 'Sports': false,
    // 'Events': false,
    // 'Other': false,
    // 'Gadgets': false,
  };
  DateTime selectedMonth = DateTime.now();
  List<Map<String, dynamic>> get filteredTransactions {
    return transactions.where((tx) {
      DateTime txDate = DateTime.parse(tx['timestamp']);
      return txDate.year == selectedMonth.year &&
          txDate.month == selectedMonth.month;
    }).toList();
  }

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

  String monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
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

  double calculateTotal(bool isExpenseType) {
    return filteredTransactions
        .where((tx) => tx['isExpense'] == isExpenseType)
        .fold(0.0, (sum, tx) => sum + (tx['amount'] ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Income container
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Income',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'PKR ${calculateTotal(false).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                // Expense container
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Expense',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'PKR ${calculateTotal(true).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = DateTime(DateTime.now().year, index + 1);
                  final isSelected = selectedMonth.month == month.month;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(
                        "${monthName(month.month)} ${month.year}",
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.indigo, // Highlight color
                      backgroundColor:
                          Colors.grey.shade200, // Unselected background
                      onSelected: (_) {
                        setState(() {
                          selectedMonth = DateTime(month.year, month.month);
                        });
                      },
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: isSelected ? Colors.indigo : Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: filteredTransactions.isEmpty
                  ? Center(
                      child: Text(
                        "No transactions available for this month.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      // itemCount: transactions.length,
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                      
                        final tx = filteredTransactions[index];
                        final realIndex = transactions.indexOf(
                          tx,
                        ); 

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              tx['isExpense']
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: tx['isExpense']
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            title: Text('PKR${tx['amount']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (tx['description'] != '')
                                  Text(tx['description']),
                                Text(
                                  "Categories: ${tx['categories'].join(', ')}",
                                ),
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

                                  // onPressed: () => editTransaction(index),
                                  onPressed: () => editTransaction(realIndex),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  // onPressed: () => deleteTransaction(index),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Delete Entry'),
                                        content: Text(
                                          'Are you sure you want to delete this transaction?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(), // Cancel
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              deleteTransaction(realIndex);
                                              Navigator.of(context).pop();
                                            },

                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
