import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/models/todo_model.dart';
import 'package:todolist/models/todolist_model.dart';
import 'package:uuid/uuid.dart';

class TodolistService {
  Future<TodoListModel> getTodoListById({String? todoListId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getStringList("TodoLists");

    if (todoListId == null || todoListId.isEmpty) {
      todoListId = await getDefaultTodoList();
    }

    if (result == null) {
      await addTodoList(name: "새로운 할 일 목록", color: 0xFF008CFF);
      return await getTodoListById();
    } else {
      var searchResult = result.singleWhere(
        (element) => jsonDecode(element)["id"] == todoListId,
        orElse: () => "",
      );
      if (searchResult == "") {
        await addTodoList(name: "새로운 할 일 목록", color: 0xFF008CFF);
        return await getTodoListById();
      } else {
        return TodoListModel.fromJson(jsonDecode(searchResult));
      }
    }
  }

  Future<List<TodoListModel>> getAllTodoLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getStringList("TodoLists");

    if (result == null || result.isEmpty) {
      await addTodoList(name: "새로운 할 일 목록", color: 0xFF008CFF);
      return await getAllTodoLists();
    } else {
      List<TodoListModel> list = [];
      for (var element in result) {
        list.add(TodoListModel.fromJson(jsonDecode(element)));
      }

      return list;
    }
  }

  Future addTodoList({
    required String name,
    required int color,
  }) async {
    final uuid = const Uuid().v1();
    TodoListModel newTodolist =
        TodoListModel(id: uuid, name: name, color: color);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getStringList("TodoLists");

    if (result == null || result.isEmpty) {
      List<String> newList = [];
      newList.add(encodeTodoList(newTodolist));
      await prefs.setStringList("TodoLists", newList);
      await setDefaultTodoList(uuid);
    } else {
      result.add(encodeTodoList(newTodolist));
      prefs.setStringList("TodoLists", result);
    }
  }

  Future<String> getDefaultTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("defaultTodoList") ?? "";
  }

  Future setDefaultTodoList(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("defaultTodoList", id);
  }

  Future addTodo({
    required String todoListId,
    required String todoTitle,
  }) async {
    TodoModel newTodo = TodoModel(
      id: const Uuid().v1(),
      title: todoTitle,
      isCompleted: false,
    );
    try {
      TodoListModel targetTodoList =
          await getTodoListById(todoListId: todoListId);
      targetTodoList.todolist.add(newTodo);
      modifyTodoList(targetTodoList);
    } catch (e) {
      throw Error();
    }
  }

  Future changeCompleteTodo({
    required String todoListId,
    required String todoId,
    required bool isCompleted,
  }) async {
    try {
      TodoListModel targetTodoList =
          await getTodoListById(todoListId: todoListId);
      for (int i = 0; i < targetTodoList.todolist.length; i++) {
        if (targetTodoList.todolist[i].id == todoId) {
          targetTodoList.todolist[i] = TodoModel(
            id: targetTodoList.todolist[i].id,
            title: targetTodoList.todolist[i].title,
            isCompleted: isCompleted,
          );
          break;
        }
      }
      modifyTodoList(targetTodoList);
    } catch (e) {
      throw Error();
    }
  }

  Future removeTodo({
    required String todoListId,
    required String todoId,
  }) async {
    try {
      TodoListModel targetTodoList =
          await getTodoListById(todoListId: todoListId);
      TodoListModel modifiedTodoList = TodoListModel(
        id: targetTodoList.id,
        name: targetTodoList.name,
        color: targetTodoList.color,
        todolist: targetTodoList.todolist
            .where((element) => element.id != todoId)
            .toList(),
      );
      modifyTodoList(modifiedTodoList);
    } catch (e) {
      throw Error();
    }
  }

  Future modifyTodoTitle({
    required String todoListId,
    required String todoId,
    required String newTitle,
  }) async {
    try {
      TodoListModel targetTodoList =
          await getTodoListById(todoListId: todoListId);
      TodoListModel modifiedTodoList = TodoListModel(
        id: targetTodoList.id,
        name: targetTodoList.name,
        color: targetTodoList.color,
        todolist: targetTodoList.todolist.map((element) {
          if (element.id == todoId) {
            return TodoModel(
              id: element.id,
              title: newTitle,
              isCompleted: element.isCompleted,
            );
          }
          return element;
        }).toList(),
      );
      modifyTodoList(modifiedTodoList);
    } catch (e) {
      throw Error();
    }
  }

  Future removeCompletedTodo({
    required String todoListId,
  }) async {
    try {
      TodoListModel targetTodoList =
          await getTodoListById(todoListId: todoListId);
      TodoListModel modifiedTodoList = TodoListModel(
        id: targetTodoList.id,
        name: targetTodoList.name,
        color: targetTodoList.color,
        todolist: targetTodoList.todolist.where((element) {
          return !element.isCompleted;
        }).toList(),
      );
      modifyTodoList(modifiedTodoList);
    } catch (e) {
      throw Error();
    }
  }

  Future modifyTodoList(TodoListModel todolist) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getStringList("TodoLists");

    if (result == null) {
      await prefs.setStringList("TodoLists", []);
      throw Error();
    } else {
      for (int i = 0; i < result.length; i++) {
        if (jsonDecode(result[i])["id"] == todolist.id) {
          result[i] = encodeTodoList(todolist);
        }
      }
      prefs.setStringList("TodoLists", result);
    }
  }

  String encodeTodo(TodoModel todo) {
    String result = "{";

    result += '"id": "${todo.id}",';
    result += '"title": "${todo.title}",';
    result += '"isCompleted": ${todo.isCompleted}';

    return "$result}";
  }

  String encodeTodoList(TodoListModel todolist) {
    String result = "{";

    result += '"id": "${todolist.id}",';
    result += '"name": "${todolist.name}",';
    result += '"color": "${todolist.color}",';

    result += '"todolist": [';

    for (var i = 0; i < todolist.todolist.length; i++) {
      result += encodeTodo(todolist.todolist[i]);
      if (i != todolist.todolist.length - 1) {
        result += ", ";
      }
    }

    result += "]";

    return "$result}";
  }
}
