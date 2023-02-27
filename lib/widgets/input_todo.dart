import 'package:flutter/material.dart';
import 'package:todolist/services/todolist_service.dart';
import 'package:todolist/widgets/input_todo_detail.dart';

class InputTodo extends StatefulWidget {
  final String todoListId, defaultValue, type, todoId;
  final Color themeColor;
  final Function updateTodoList;
  final Function hideInputTodo;

  const InputTodo.newTodo({
    super.key,
    required this.todoListId,
    this.defaultValue = "",
    this.type = "newTodo",
    this.todoId = "",
    required this.themeColor,
    required this.updateTodoList,
    required this.hideInputTodo,
  });

  const InputTodo.editTodo({
    super.key,
    required this.todoListId,
    required this.defaultValue,
    this.type = "editTodo",
    required this.todoId,
    required this.themeColor,
    required this.updateTodoList,
    required this.hideInputTodo,
  });

  @override
  State<InputTodo> createState() => _InputTodoState();
}

class _InputTodoState extends State<InputTodo> {
  final todoText = TextEditingController();

  @override
  void initState() {
    super.initState();
    todoText.text = widget.defaultValue;
  }

  @override
  void dispose() {
    todoText.dispose();
    super.dispose();
  }

  void saveInputTodo() async {
    if (widget.type == "newTodo") {
      await TodolistService().addTodo(
        todoListId: widget.todoListId,
        todoTitle: todoText.text,
      );
    } else if (widget.type == "editTodo") {
      await TodolistService().modifyTodoTitle(
          todoListId: widget.todoListId,
          todoId: widget.todoId,
          newTitle: todoText.text);
    }

    todoText.clear();
    widget.hideInputTodo();
    widget.updateTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              autofocus: true,
              controller: todoText,
              style: const TextStyle(
                fontSize: 20,
              ),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: "새로운 할 일",
                fillColor: Colors.grey.shade50,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.themeColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.themeColor),
                ),
              ),
              onTapOutside: (event) {
                if (todoText.text.isNotEmpty) {
                  saveInputTodo();
                } else {
                  widget.hideInputTodo();
                  widget.updateTodoList();
                }
              },
            ),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  return const InputTodoDetail();
                },
                isScrollControlled: true,
              );
            },
            icon: Icon(
              Icons.add_box,
              color: widget.themeColor,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
