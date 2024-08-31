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
  final List<Map<String, dynamic>> expenseControllers = [
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
    "Fruits",
     "Vegetables",
      "Grocery",
       "Loan",
        "Tea/cofee",
       "Drinks",
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
    for (var controllers in expenseControllers) {
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
      expenseControllers.clear();
      expenseControllers.add({
        'type': TextEditingController(),
        'amount': TextEditingController(),
        'isOther': false,
        'isPerson': false
      });
    });
  }

  void _addNewRow() {
    setState(() {
      expenseControllers.add({
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
                "Available Balance: \₹${_availableBalance.toStringAsFixed(2)}"),
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
                  itemCount: expenseControllers.length,
                  itemBuilder: (ctx, index) {
                    final item =expenseControllers[index];
                    return Dismissible(
              key: Key(item['id'].toString()),
                       onDismissed: (direction) {
                // Remove the item from the data source.
                setState(() {
                  expenseControllers.removeAt(index);
                });
                

                // Then show a snackbar.
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(' Remove')));
              },
               background: Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 134, 126),
                  borderRadius: BorderRadius.circular(15)),
              
               child: Row(
            
                 children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text("Swipe To Remove"),
                  ),
                   Icon(Icons.delete_forever_rounded),
                 ],
               ),),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.061,
                              width: MediaQuery.of(context).size.width * 0.60,
                              child: expenseControllers[index]['isOther'] ||
                                      expenseControllers[index]['isPerson']
                                  ? TextFormField(
                                      controller: expenseControllers[index]
                                          ['type'],
                                      onChanged: (value) {
                                        if (expenseControllers[index]
                                            ['isPerson']) {
                                          // Check if 'Person ' is already a prefix
                                          if (!value.startsWith('Person ')) {
                                            // If not, prepend 'Person ' to the input text
                                            expenseControllers[index]['type']
                                                .text = 'Person $value';
                                            // Move the cursor to the end of the text field
                                            expenseControllers[index]['type']
                                                    .selection =
                                                TextSelection.fromPosition(
                                              TextPosition(
                                                  offset:
                                                      expenseControllers[index]
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
                                      alignment: Alignment.topRight,
                                      // padding: EdgeInsets.all(15),
                                      value: expenseControllers[index]
                                          ['selectedType'],
                                      items: typeList.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(
                                              fontSize:
                                                  14, // Adjust the font size as needed
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          expenseControllers[index]
                                              ['selectedType'] = newValue;
                                          if (newValue == 'Other') {
                                            expenseControllers[index]
                                                ['isOther'] = true;
                                            expenseControllers[index]
                                                ['isPerson'] = false;
                                            expenseControllers[index]['type']!
                                                .text = '';
                                          } else if (newValue == 'Person') {
                                            expenseControllers[index]
                                                ['isPerson'] = true;
                                            expenseControllers[index]
                                                ['isOther'] = false;
                                            expenseControllers[index]['type']!
                                                .text = '';
                                            // Clear the text field if 'Person' is selected
                                          } else {
                                            expenseControllers[index]
                                                ['isOther'] = false;
                                            expenseControllers[index]
                                                ['isPerson'] = false;
                                            expenseControllers[index]
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
                              height: MediaQuery.of(context).size.height * 0.060,
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: TextFormField(
                                controller: expenseControllers[index]['amount'],
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
                      ),
                    );
                  },
                ),
              ),
            ),
            ElevatedButton(
               style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(primaryColor)),
              
              
              onPressed: (){ _submitData();}, child: Text("Submit")),
            SizedBox(height: 30,)
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: primaryColor,
      //   child: Icon(Icons.save),
      //   onPressed: _submitData,
      // ),
    );
  }
}

