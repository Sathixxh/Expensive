import 'package:animations/animations.dart';
import 'package:expensiveapp/Domine/provider/mainprovider.dart';
import 'package:expensiveapp/data/model/expensemodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonthlySummaryScreen extends StatelessWidget {
 
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses;

    // Group expenses by date
    final groupedExpenses = <DateTime, List<Expense>>{};
    for (var expense in expenses) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (!groupedExpenses.containsKey(date)) {
        groupedExpenses[date] = [];
      }
      groupedExpenses[date]!.add(expense);
    }

    final monthlyDates = groupedExpenses.keys.toList();
    monthlyDates.sort();

    // Initial amount (adjust as necessary)
    double initialAmount = 1000.0;
    double currentBalance = initialAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(),
              // padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SNo', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Balance', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
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
        
                  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
                  final types = dailyExpenses.map((e) => e.type).join(', ');
        
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
                    child: OpenContainer(
                      transitionType: ContainerTransitionType.fade,
                      closedElevation: 0,
                      openElevation: 4,
                      closedBuilder: (context, openContainer) {
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text((index + 1).toString(),style: TextStyle(fontSize: 13)),
                              Center(child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(formattedDate,style: TextStyle(fontSize: 13),),
                              )),
                              Container(
                          
                                width: 50,
                                child: Text(
                                  types,
                                  style: TextStyle(fontSize: 13, overflow: TextOverflow.ellipsis),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                              Container(
                                 width: 50,
                            
                                child: Text('\$${dayTotal.toStringAsFixed(2)}',style: TextStyle(fontSize: 13))),
                              Text('\$${currentBalance.toStringAsFixed(2)}',style: TextStyle(fontSize: 13)),
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
    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses.where((e) =>
        e.date.year == date.year &&
        e.date.month == date.month &&
        e.date.day == date.day).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions for ${DateFormat('yyyy-MM-dd').format(date)}'),
      ),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (ctx, index) {
          final expense = expenses[index];
          return ListTile(
            title: Text(expense.type),
            subtitle: Text('\$${expense.amount.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}
