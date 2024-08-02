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
    final enteredAmount = double.tryParse(_amountController.text);

    if (enteredType.isEmpty || enteredAmount == null || enteredAmount <= 0) {
      return;
    }

    Provider.of<ExpenseProvider>(context, listen: false).addExpense(
      Expense(
        date: _selectedDate,
        type: enteredType,
        amount: enteredAmount,
      ),
    );

    _typeController.clear();
    _amountController.clear();
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
        print(_selectedDate);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.of(context).pushNamed('/expenses');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
  
  Container(
    width: MediaQuery.of(context).size.width* 0.60,
    child: TextField(
                decoration: InputDecoration(labelText: 'Type'),
                controller: _typeController,
              ),
  ),
  Container(
    width: MediaQuery.of(context).size.width* 0.20,
    child: 
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
  ),


],),

          
          
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitData,
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
