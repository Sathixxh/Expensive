import 'package:animations/animations.dart';
import 'package:expensiveapp/Domine/provider/mainprovider.dart';
import 'package:expensiveapp/data/model/expensemodel.dart';
import 'package:expensiveapp/presentation/listscrenn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _initialAmountController = TextEditingController();
  double _availableBalance = 0.0;
  final List<Map<String, TextEditingController>> _expenseControllers = [
    {'type': TextEditingController(), 'amount': TextEditingController()},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialAmount();
  }

  void _loadInitialAmount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _availableBalance = prefs.getDouble('initialAmount') ?? 0.0;
    });
  }

  void _saveInitialAmount() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('initialAmount', _availableBalance);
  }

  void _submitData() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    for (var controllers in _expenseControllers) {
      final enteredType = controllers['type']!.text;
      final enteredAmount = double.tryParse(controllers['amount']!.text);

      if (enteredType.isEmpty || enteredAmount == null || enteredAmount <= 0) {
        return;
      }

      provider.addExpense(
        Expense(
          date: _selectedDate,
          type: enteredType,
          amount: enteredAmount,
        ),
      );

      setState(() {
        _availableBalance -= enteredAmount;
        _saveInitialAmount();
      });

      controllers['type']!.clear();
      controllers['amount']!.clear();
    }

    setState(() {
      _expenseControllers.clear();
      _expenseControllers.add({'type': TextEditingController(), 'amount': TextEditingController()});
    });
  }

  void _addNewRow() {
    setState(() {
      _expenseControllers.add({'type': TextEditingController(), 'amount': TextEditingController()});
    });
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
        backgroundColor: Colors.white,
        title: Text('Expense Tracker'),
        actions: [
          OpenContainer(
            closedElevation: 0,
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(0),
              ),
            ),
            transitionType: ContainerTransitionType.fadeThrough,
            closedBuilder: (BuildContext _, VoidCallback openContainer) {
              return IconButton(
                icon: Icon(Icons.calendar_today,color: Colors.black,),
                onPressed: openContainer,
              );
            },
            openBuilder: (BuildContext _, VoidCallback __) {
              return MonthlySummaryScreen();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Initial Amount'),
              controller: _initialAmountController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) {
                setState(() {
                  _availableBalance = double.tryParse(_initialAmountController.text) ?? 0.0;
                  _saveInitialAmount();
                });
              },
            ),
            SizedBox(height: 10),
            Text("Available Balance: \$${_availableBalance.toStringAsFixed(2)}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: _presentDatePicker,
                  child: Text('Choose Date'),
                ),
                ElevatedButton(
                  onPressed: _addNewRow,
                  child: Text("Add New Row"),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _expenseControllers.length,
                itemBuilder: (ctx, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.60,
                          child: TextField(
                            decoration: InputDecoration(labelText: 'Type'),
                            controller: _expenseControllers[index]['type'],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.20,
                          child: TextField(
                            decoration: InputDecoration(labelText: 'Amount'),
                            controller: _expenseControllers[index]['amount'],
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitData,
              child: Text('Submit All Expenses'),
            ),
          ],
        ),
      ),
    );
  }
}
