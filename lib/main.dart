import 'package:flutter/material.dart';
import 'package:todolist/screens/todolist.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        canvasColor: Colors.grey.shade200,
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStatePropertyAll(Colors.transparent),
          ),
        ),
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStatePropertyAll(Colors.transparent),
          ),
        ),
      ),
      home: const TodoList(),
    );
  }
}
