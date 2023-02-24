import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/models/todo_model.dart';

class TodolistService {
  static Future<List<TodoModel>> getTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getStringList("TodoList");

    if (result == null) {
      await prefs.setStringList("TodoList", []);
      return [];
    } else {
      List<TodoModel> todolist = [];
      for (var item in result) {
        todolist.add(TodoModel.fromJson(jsonDecode(item)));
      }
      return todolist;
    }
  }

  static Future saveTodoList(List<TodoModel> todolist) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> stringList = [];

    for (TodoModel todo in todolist) {
      stringList.add(encodeTodo(todo));
    }
    prefs.setStringList("TodoList", stringList);
    log("TodoList saved");
    log(stringList.toString());
  }

  static String encodeTodo(TodoModel todo) {
    String result = "{";

    result += '"title": "${todo.title}",';
    result += '"isCompleted": ${todo.isCompleted}';

    return "$result}";
  }
}
