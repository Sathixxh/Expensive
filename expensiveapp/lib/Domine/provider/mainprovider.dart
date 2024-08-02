// lib/providers/expense_provider.dart
import 'dart:convert';

import 'package:expensiveapp/data/model/expensemodel.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

// class ExpenseProvider with ChangeNotifier {
//   List<Expense> _expenses = [];

//   List<Expense> get expenses => _expenses;

//   void addExpense(Expense expense) {
//     _expenses.add(expense);
//     notifyListeners();
//   }
// }



class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  ExpenseProvider() {
    _loadExpenses();
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    notifyListeners();
    await _saveExpenses();
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expenseData = _expenses.map((e) => json.encode(e.toJson())).toList();
    prefs.setStringList('expenses', expenseData);
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expenseData = prefs.getStringList('expenses') ?? [];
    _expenses = expenseData.map((e) => Expense.fromJson(json.decode(e))).toList();
    notifyListeners();
  }
}
