import 'package:animations/animations.dart';
import 'package:expensiveapp/Domine/provider/mainprovider.dart';
import 'package:expensiveapp/data/model/expensemodel.dart';
import 'package:expensiveapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonthlySummaryScreen extends StatefulWidget {
  final double initialAmount; // Explicitly type as double

  const MonthlySummaryScreen({required this.initialAmount});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses;

    // Group expenses by date
    final groupedExpenses = <DateTime, List<Expense>>{};
    for (var expense in expenses) {
      final date =
          DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (!groupedExpenses.containsKey(date)) {
        groupedExpenses[date] = [];
      }
      groupedExpenses[date]!.add(expense);
    }

    final monthlyDates = groupedExpenses.keys.toList();
    monthlyDates.sort();

    // Initial amount (adjust as necessary)
    double currentBalance = widget.initialAmount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Monthly Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SNo', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Balance',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: monthlyDates.length,
                itemBuilder: (ctx, index) {
                  final date = monthlyDates[index];
                  final dailyExpenses = groupedExpenses[date]!;

                  final dayTotal = dailyExpenses.fold(
                    0.0,
                    (sum, expense) => sum + expense.amount,
                  );

                  // Update the current balance
                  currentBalance -= dayTotal;

                  final formattedDate = DateFormat('dd-MM-yyyy').format(date);
                  final types = dailyExpenses.map((e) => e.type).join(', ');

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 0.0),
                    child: OpenContainer(
                      transitionType: ContainerTransitionType.fade,
                      closedElevation: 0,
                      openElevation: 4,
                      closedBuilder: (context, openContainer) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text((index + 1).toString(),
                                    style: TextStyle(fontSize: 13)),
                              ),
                              Center(
                                  child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(formattedDate,
                                    style: TextStyle(fontSize: 13)),
                              )),
                              Container(
                                width: 50,
                                child: Center(
                                  child: Text(
                                    types,
                                    style: TextStyle(
                                        fontSize: 13,
                                        overflow: TextOverflow.ellipsis),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ),
                              ),
                              Container(
                                width: 50,
                                child: Text(dayTotal.toStringAsFixed(2),
                                    style: TextStyle(fontSize: 13)),
                              ),
                              Container(
                                  width: 50,
                                  child: Center(
                                      child: Text(
                                          currentBalance.toStringAsFixed(2),
                                          style: TextStyle(fontSize: 13)))),
                            ],
                          ),
                          onTap: openContainer,
                        );
                      },
                      openBuilder: (context, closeContainer) {
                        return ExpenseListScreen(date: date);
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 3,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseListScreen extends StatelessWidget {
  final DateTime date;

  ExpenseListScreen({required this.date});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> imageMap = {
      "Person": "assets/images/man.png",
      "Petrol": "assets/images/petrol.png",
      "Bus": "assets/images/bus.png",
      "FoodBF": "assets/images/breakfast.png",
      "FoodLunch": "assets/images/fried-rice.png",
      "Metro": "assets/images/train.png",
      "Movie": "assets/images/movie-theater.png",
      "Snacks": "assets/images/snack.png",
      "HouseRent": "assets/images/residential.png",
      "Medical": "assets/images/hospital.png",
      "Juice": "assets/images/watermelon-smoothie.png",
      "MobileRecharge": "assets/images/smartphone.png",
      "Cosmetics": "assets/images/cosmetics.png",
      "Haircut": "assets/images/haircut.png",
      "Dress": "assets/images/bomber.png",
      "shoes": "assets/images/shoes.png",
      "Others": "assets/images/unknown.png",
      "Fruit": "assets/images/fruit.png",
      "Loan": "assets/images/loan.png",
      "Grocery": "assets/images/shopping-bag.png",
      "Vegetables": "assets/images/vegetable.png",
      "Drinks": "assets/images/drink.png",
      "Tea/cofee": "assets/images/green-tea.png",
      "Trip": "assets/images/travel-bag.png",

      // Add other mappings for expense types and their corresponding images
    };

    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses
        .where((e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Transactions for ${DateFormat('yyyy-MM-dd').format(date)}'),
      ),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (ctx, index) {
          final expense = expenses[index];

          // Determine the image path based on expense type containing keywords
          String imagePath = "assets/images/default.png"; // Default image path
          String displayText = expense.type; // Default display text

          for (var key in imageMap.keys) {
            if (expense.type.contains(key)) {
              imagePath = imageMap[key]!;
              break;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Card(
              color: Color.fromRGBO(253, 253, 255, 1),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(displayText),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('\₹${expense.amount.toStringAsFixed(2)}'),
                ),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Image.asset(
                    imagePath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Remove the expense from the provider
                    provider.removeExpense(expense);

                    // Show a snackbar to confirm deletion
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Expense removed!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
