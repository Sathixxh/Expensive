
import 'dart:convert';
import 'package:expensiveapp/data/model/expensemodel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  ExpenseProvider() {
    _loadExpenses();
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> removeExpense(Expense expense) async {
    _expenses.remove(expense);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> _saveExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expenseList = _expenses.map((e) => e.toJson()).toList();
      prefs.setString('expenses', json.encode(expenseList));
    } catch (e) {
      // Handle or log error
      print('Error saving expenses: $e');
    }
  }

  Future<void> _loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expensesString = prefs.getString('expenses');
      if (expensesString != null) {
        final List decodedList = json.decode(expensesString);
        _expenses = decodedList.map((e) => Expense.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Handle or log error
      print('Error loading expenses: $e');
    }
  }
}

