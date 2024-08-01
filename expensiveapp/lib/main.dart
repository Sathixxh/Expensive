// lib/main.dart
import 'package:expensiveapp/Domine/provider/mainprovider.dart';
import 'package:expensiveapp/presentation/homescrenn.dart';
import 'package:expensiveapp/presentation/listscrenn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ExpenseProvider(),
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MainScreen(),
        routes: {
          '/expenses': (ctx) => ExpenseListScreen(),
        },
      ),
    );
  }
}
