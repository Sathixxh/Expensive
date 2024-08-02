// lib/screens/expense_list_screen.dart
import 'package:expensiveapp/Domine/provider/mainprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// class ExpenseListScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final expenses = Provider.of<ExpenseProvider>(context).expenses;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Expense List'),
//       ),
//       body: ListView.builder(
//         itemCount: expenses.length,
//         itemBuilder: (ctx, index) {
//           return ListTile(
//             title: Text(expenses[index].type),
//             subtitle: Text(expenses[index].date.toLocal().toString().split(' ')[0]),
//             trailing: Text('\$${expenses[index].amount.toStringAsFixed(2)}'),
//           );
//         },
//       ),
//     );
//   }
// }



class ExpenseListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpenseProvider>(context).expenses;

    return Scaffold(
      appBar: AppBar(
        title: Text('Expense List'),
      ),
      body: expenses.isEmpty
          ? Center(child: Text('No expenses added yet!'))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (ctx, index) {
                return ListTile(
                  title: Text(expenses[index].type),
                  subtitle: Text(expenses[index].date.toLocal().toString().split(' ')[0]),
                  trailing: Text('\$${expenses[index].amount.toStringAsFixed(2)}'),
                );
              },
            ),
    );
  }
}
