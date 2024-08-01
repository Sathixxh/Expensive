// lib/providers/expense_provider.dart
import 'package:expensiveapp/data/model/expensemodel.dart';
import 'package:flutter/material.dart';


class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }
}
