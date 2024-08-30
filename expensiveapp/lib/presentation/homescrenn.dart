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
  final TextEditingController _initialAmountController =
      TextEditingController();
  double _availableBalance = 0.0;
  final List<Map<String, dynamic>> _expenseControllers = [
    {
      'type': TextEditingController(),
      'amount': TextEditingController(),
      'isOther': false,
      'isPerson': false
    },
  ];
  final List<String> typeList = [
    "FoodBF",
      "FoodLunch",
    "Bus",
    "Metro",
    "Movie",
    "Snacks",
    "Person",
    "HouseRent",
    "Medical",
    "Juice",
    "MobileRecharge",
    "Cosmetics",
    "Haircut",
    "Dress",
    "shoes",
    "Other",
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
      // Determine if the entered type should come from the text field or dropdown
      final enteredType = controllers['isOther'] || controllers['isPerson']
          ? controllers['type']!
              .text // Use text field value if 'Other' or 'Person' is selected
          : controllers[
              'selectedType']; // Otherwise, use dropdown selected value
      print(enteredType);
      final enteredAmount = double.tryParse(controllers['amount']!.text);

      if (enteredType.isEmpty || enteredAmount == null || enteredAmount <= 0) {
        return;
      }

      provider.addExpense(
        Expense(
          date: _selectedDate,
          type: enteredType, // Ensure that only the required type is stored
          amount: enteredAmount,
        ),
      );

      setState(() {
        _availableBalance -= enteredAmount;
        _saveInitialAmount();
      });

      controllers['type']!.clear();
      controllers['amount']!.clear();
      controllers['selectedType'] = null;
      controllers['isOther'] = false;
      controllers['isPerson'] = false;
    }

    // Clear expense controllers and reset for new input
    setState(() {
      _expenseControllers.clear();
      _expenseControllers.add({
        'type': TextEditingController(),
        'amount': TextEditingController(),
        'isOther': false,
        'isPerson': false
      });
    });
  }

  void _addNewRow() {
    setState(() {
      _expenseControllers.add({
        'type': TextEditingController(),
        'amount': TextEditingController(),
        'isOther': false,
        'isPerson': false
      });
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
            height: MediaQuery.of(context).size.height * 0.05,
            child: TextField(
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 232, 231, 231)),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        // color: Color.fromARGB(255, 241, 208, 99)
                        color: primaryColor),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(255, 232, 231, 231),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  labelText: "Initial Amount",
                  labelStyle:
                      TextStyle(color: const Color.fromARGB(255, 83, 82, 82))),
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
                  _availableBalance =
                      double.tryParse(_initialAmountController.text) ?? 0.0;
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
              final double initialAmount =
                  double.tryParse(_initialAmountController.text) ?? 0.0;
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
                  backgroundColor: WidgetStatePropertyAll(primaryColor)),
              onPressed: _showInitialAmountDialog,
              child: Text('Set Initial Amount'),
            ),
            SizedBox(height: 10),
            Text(
                "Available Balance: \$${_availableBalance.toStringAsFixed(2)}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(primaryColor)),
                  onPressed: _presentDatePicker,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Select Date"),
                      SizedBox(width: 5),
                      Icon(Icons.calendar_month_rounded)
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(primaryColor)),
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
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.60,
                            child: _expenseControllers[index]['isOther'] ||
                                    _expenseControllers[index]['isPerson']
                                ? TextFormField(
                                    controller: _expenseControllers[index]
                                        ['type'],
                                    onChanged: (value) {
                                      if (_expenseControllers[index]
                                          ['isPerson']) {
                                        // Check if 'Person ' is already a prefix
                                        if (!value.startsWith('Person ')) {
                                          // If not, prepend 'Person ' to the input text
                                          _expenseControllers[index]['type']
                                              .text = 'Person $value';
                                          // Move the cursor to the end of the text field
                                          _expenseControllers[index]['type']
                                                  .selection =
                                              TextSelection.fromPosition(
                                            TextPosition(
                                                offset:
                                                    _expenseControllers[index]
                                                            ['type']
                                                        .text
                                                        .length),
                                          );
                                        }
                                      }
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 232, 231, 231)),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: primaryColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0)),
                                      ),
                                      filled: true,
                                      fillColor:
                                          Color.fromARGB(255, 232, 231, 231),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                      labelText: "Type",
                                      labelStyle: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 83, 82, 82)),
                                    ),
                                  )
                                : DropdownButtonFormField<String>(
                                    value: _expenseControllers[index]
                                        ['selectedType'],
                                    items: typeList.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _expenseControllers[index]
                                            ['selectedType'] = newValue;
                                        if (newValue == 'Other') {
                                          _expenseControllers[index]
                                              ['isOther'] = true;
                                          _expenseControllers[index]
                                              ['isPerson'] = false;
                                          _expenseControllers[index]['type']!
                                              .text = '';
                                        } else if (newValue == 'Person') {
                                          _expenseControllers[index]
                                              ['isPerson'] = true;
                                          _expenseControllers[index]
                                              ['isOther'] = false;
                                          _expenseControllers[index]['type']!
                                                  .text =
                                              ''; // Clear the text field if 'Person' is selected
                                        } else {
                                          _expenseControllers[index]
                                              ['isOther'] = false;
                                          _expenseControllers[index]
                                              ['isPerson'] = false;
                                          _expenseControllers[index]
                                              ['selectedType'] = newValue;
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 232, 231, 231)),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: primaryColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0)),
                                      ),
                                      filled: true,
                                      fillColor:
                                          Color.fromARGB(255, 232, 231, 231),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                      labelText: "Select Type",
                                      labelStyle: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 83, 82, 82)),
                                    ),
                                  ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.30,
                            child: TextFormField(
                              controller: _expenseControllers[index]['amount'],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          Color.fromARGB(255, 232, 231, 231)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                                filled: true,
                                fillColor: Color.fromARGB(255, 232, 231, 231),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.0)),
                                labelText: "Amount",
                                labelStyle: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 83, 82, 82)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: Icon(Icons.save),
        onPressed: _submitData,
      ),
    );
  }
}
