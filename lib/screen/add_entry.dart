// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEntryTab extends StatefulWidget {
  const AddEntryTab({super.key});

  @override
  _AddEntryTabState createState() => _AddEntryTabState();
}

class _AddEntryTabState extends State<AddEntryTab> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isExpense = true;
  Map<String, bool> categories = {
    'Petrol': false,
    'Food': false,
    'Transport': false,
    'Home Expense': false,
    'gadges': false,
    'Health': false,
    'Shopping': false,
    'Utilities': false,
    'Education': false,
    'Travel': false,
    'Investments': false,
    'Miscellaneous': false,
    'Bills': false,
    'Groceries': false,
    'Clothing': false,
    'Personal Care': false,
    'Dining Out': false,
    'Vehicle Maintenance': false,
  };

  void addTransaction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? existing = prefs.getString('transactions');
    List<Map<String, dynamic>> txs = existing != null
        ? List<Map<String, dynamic>>.from(json.decode(existing))
        : [];

    double amount = double.tryParse(amountController.text) ?? 0;
    String description = descriptionController.text;
    DateTime now = DateTime.now();

    List<String> selectedCategories = categories.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    Map<String, dynamic> newTx = {
      'amount': amount,
      'description': description,
      'categories': selectedCategories,
      'isExpense': isExpense,
      'timestamp': now.toIso8601String(),
    };

    txs.add(newTx);
    await prefs.setString('transactions', json.encode(txs));

    amountController.clear();
    descriptionController.clear();
    categories.updateAll((key, _) => false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Transaction Added')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Amount'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          Row(
            children: [
              Checkbox(
                value: isExpense,
                onChanged: (val) => setState(() => isExpense = val!),
              ),
              Text(isExpense ? 'Expense' : 'Income'),
            ],
          ),
          Wrap(
            spacing: 8,
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
          SizedBox(height: 20),
          ElevatedButton(onPressed: addTransaction, child: Text("Save Entry")),
        ],
      ),
    );
  }
}
