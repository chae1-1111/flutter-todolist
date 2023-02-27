import 'package:flutter/material.dart';
import 'package:todolist/services/todolist_service.dart';
import 'package:todolist/widgets/input_todo_detail.dart';

class InputTodo extends StatefulWidget {
  final String todoListId, type;
  String? todoId, defaultTitle, defaultMemo;
  DateTime? defaultDeadline;
  final Color themeColor;
  final Function updateTodoList;
  final Function hideInputTodo;

  InputTodo.newTodo({
    super.key,
    required this.todoListId,
    this.defaultTitle,
    this.type = "newTodo",
    this.todoId,
    required this.themeColor,
    required this.updateTodoList,
    required this.hideInputTodo,
  });

  InputTodo.editTodo({
    super.key,
    this.type = "editTodo",
    required this.todoListId,
    required this.todoId,
    required this.defaultTitle,
    this.defaultMemo,
    this.defaultDeadline,
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
    if (widget.type == "editTodo") {
      todoText.text = widget.defaultTitle!;
    }
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
      await TodolistService().modifyTodo(
        todoListId: widget.todoListId,
        todoId: widget.todoId!,
        newTitle: todoText.text,
      );
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
              maxLength: 100,
              style: const TextStyle(
                fontSize: 20,
              ),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                counterText: "",
                hintText: "새로운 할 일",
                fillColor: Colors.grey.shade50,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.themeColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.themeColor),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    if (widget.type == "newTodo" || widget.type == "editTodo") {
                      widget.hideInputTodo();
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          if (widget.type == "newTodo") {
                            return InputTodoDetail.newTodo(
                              todoListId: widget.todoListId,
                              updateTodoList: widget.updateTodoList,
                            );
                          } else {
                            return InputTodoDetail.editTodo(
                              todoListId: widget.todoListId,
                              updateTodoList: widget.updateTodoList,
                              todoId: widget.todoId!,
                              defaultTitle: todoText.text.isNotEmpty
                                  ? todoText.text
                                  : widget.defaultTitle,
                              defaultMemo: widget.defaultMemo,
                              defaultDeadline: widget.defaultDeadline,
                            );
                          }
                        },
                        isScrollControlled: true,
                      );
                    }
                  },
                  icon: Icon(
                    Icons.add_box,
                    color: widget.themeColor,
                    size: 30,
                  ),
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
        ],
      ),
    );
  }
}
