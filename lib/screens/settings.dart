import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("설정"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Container(),
    );
  }
}
