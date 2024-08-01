// lib/screens/main_screen.dart
import 'package:expensiveapp/Domine/provider/mainprovider.dart';
import 'package:expensiveapp/data/model/expensemodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDate = DateTime.now();
  final _typeController = TextEditingController();
  final _amountController = TextEditingController();

  void _submitData() {
    final enteredType = _typeController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredType.isEmpty || enteredAmount <= 0) {
      return;
    }

    Provider.of<ExpenseProvider>(context, listen: false).addExpense(
      Expense(
        date: _selectedDate,
        type: enteredType,
        amount: enteredAmount,
      ),
    );

    Navigator.of(context).pushNamed('/expenses');
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Selected Date: ${_selectedDate.toLocal()}'.split(' ')[0],
                ),
              ),
              TextButton(
                onPressed: _presentDatePicker,
                child: Text('Choose Date'),
              ),
            ],
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Type'),
            controller: _typeController,
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Amount'),
            controller: _amountController,
            keyboardType: TextInputType.number,
          ),
          ElevatedButton(
            onPressed: _submitData,
            child: Text('Add Expense'),
          ),
        ],
      ),
    );
  }
}
