import 'package:animations/animations.dart';
import 'package:expensiveapp/Domine/provider/mainprovider.dart';
import 'package:expensiveapp/data/model/expensemodel.dart';
import 'package:expensiveapp/presentation/listscrenn.dart';
import 'package:expensiveapp/utils/utils.dart';
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
      });
    });
  }

  void _showInitialAmountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Initial Amount'),
          content: Container(
             height: MediaQuery.of(context).size.height *0.05,
            child: TextField(
             decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 232, 231, 231)),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 241, 208, 99)),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                filled: true,
                                fillColor: Color.fromARGB(255, 232, 231, 231),
                                focusColor: Colors.amber,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.0)),
                                labelText: "Initial Amount",
                                labelStyle: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 83, 82, 82))),
              controller: _initialAmountController,
              keyboardType: TextInputType.number,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                setState(() {
                  _availableBalance = double.tryParse(_initialAmountController.text) ?? 0.0;
                  _saveInitialAmount();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                icon: Icon(Icons.calendar_today, color: Colors.black),
                onPressed: openContainer,
              );
            },
            openBuilder: (BuildContext _, VoidCallback __) {
              final double initialAmount = double.tryParse(_initialAmountController.text) ?? 0.0;
              return MonthlySummaryScreen(initialAmount: initialAmount);
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
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(primaryColor)
              ),
              onPressed: _showInitialAmountDialog,
              child: Text('Set Initial Amount'),
            ),
            SizedBox(height: 10),
            Text("Available Balance: \$${_availableBalance.toStringAsFixed(2)}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
               
                ElevatedButton(
                       style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(primaryColor)
              ),
                  onPressed: (){
                  _presentDatePicker();
                }, child: Row(children: [Text("Choose Date"),Icon(Icons.calendar_month_rounded)],)),
                ElevatedButton(
                       style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(primaryColor)
              ),
                  onPressed: _addNewRow,
                  child: Text("Add New Row"),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ListView.builder(
                  itemCount: _expenseControllers.length,
                  itemBuilder: (ctx, index) {
                    return Padding(
                      padding:  EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                         
                            height: MediaQuery.of(context).size.height *0.05,
                            width: MediaQuery.of(context).size.width * 0.60,
                            child: 
                            
                            TextFormField(
                                 controller: _expenseControllers[index]['type'],
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 232, 231, 231)),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                         color: primaryColor
                                      // color: Color.fromARGB(255, 241, 208, 99)
                                      ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                filled: true,
                                fillColor: Color.fromARGB(255, 232, 231, 231),
                                focusColor: Colors.amber,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.0)),
                                labelText: "Type",
                                labelStyle: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 83, 82, 82))),
                          ),
                            
                            
                            
                           
                          ),
                          Container(
                
                            height: MediaQuery.of(context).size.height *0.05,
                            width: MediaQuery.of(context).size.width * 0.30,
                            child: TextField(
                             decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 232, 231, 231)),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: primaryColor
                                      // Color.fromARGB(255, 241, 208, 99)
                                      ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                filled: true,
                                fillColor: Color.fromARGB(255, 232, 231, 231),
                                focusColor: Colors.amber,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.0)),
                                labelText: "Amount",
                                labelStyle: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 83, 82, 82))),
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
            ),
            // SizedBox(height: 10),
            ElevatedButton(
                   style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(primaryColor)
              ),
              onPressed: _submitData,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
