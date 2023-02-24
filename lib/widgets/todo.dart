import 'package:flutter/material.dart';

class Todo extends StatefulWidget {
  final String title;

  const Todo({
    super.key,
    required this.title,
  });

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    isCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
                isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
            onPressed: () {
              setState(() {
                isCompleted = !isCompleted;
              });
            },
            color: Colors.amber,
          ),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 21,
              decoration: isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: isCompleted ? Colors.black54 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
