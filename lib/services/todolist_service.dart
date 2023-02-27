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

  Future removeTodoList({required String todoListId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getStringList("TodoLists");
    List<String> newTodoLists = [];

    if (result == null) {
      await prefs.setStringList("TodoLists", []);
      throw Error();
    } else {
      for (int i = 0; i < result.length; i++) {
        if (jsonDecode(result[i])["id"] != todoListId) {
          newTodoLists.add(result[i]);
        }
      }
      prefs.setStringList("TodoLists", newTodoLists);
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
    String? todoMemo,
    DateTime? todoDeadLine,
  }) async {
    TodoModel newTodo = TodoModel(
      id: const Uuid().v1(),
      title: todoTitle,
      memo: todoMemo,
      deadLine: todoDeadLine,
      isCompleted: false,
    );
    try {
      TodoListModel targetTodoList =
          await getTodoListById(todoListId: todoListId);
      targetTodoList.todolist.insert(0, newTodo);
      modifyTodoList(targetTodoList);
    } catch (e) {
      throw Error();
    }
  }

  Future changeCompleteTodo({
    required String todoListId,
    required String todoId,
  }) async {
    try {
      TodoListModel targetTodoList =
          await getTodoListById(todoListId: todoListId);
      List<TodoModel> newTodos = targetTodoList.todolist
          .map(
            (element) => TodoModel(
              id: element.id,
              title: element.title,
              memo: element.memo,
              deadLine: element.deadLine,
              isCompleted: element.id == todoId
                  ? !element.isCompleted
                  : element.isCompleted,
            ),
          )
          .toList();
      TodoListModel modifiedTodoList = TodoListModel(
        id: targetTodoList.id,
        name: targetTodoList.name,
        color: targetTodoList.color,
        todolist: newTodos,
      );
      modifyTodoList(modifiedTodoList);
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

  Future modifyTodo(
      {required String todoListId,
      required String todoId,
      required String newTitle,
      String? newMemo,
      DateTime? newDeadLine}) async {
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
              memo: newMemo,
              deadLine: newDeadLine,
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

  Future reOrderTodo({
    required String todoListId,
    required String todoId,
    required String prevTodoId,
  }) async {
    TodoListModel targetTodoList =
        await getTodoListById(todoListId: todoListId);

    List<TodoModel> newTodolist = [];
    if (prevTodoId.isEmpty) {
      newTodolist.add(
        targetTodoList.todolist.firstWhere(
          (element) => element.id == todoId,
        ),
      );
    }

    for (var element
        in targetTodoList.todolist.where((element) => element.id != todoId)) {
      {
        newTodolist.add(element);
        if (element.id == prevTodoId) {
          newTodolist.add(
            targetTodoList.todolist.firstWhere(
              (element) => element.id == todoId,
            ),
          );
        }
      }
    }

    TodoListModel reOrderedTodoList = TodoListModel(
      id: targetTodoList.id,
      name: targetTodoList.name,
      color: targetTodoList.color,
      todolist: newTodolist,
    );

    await modifyTodoList(reOrderedTodoList);
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

  Future modifyTodoListById({
    required String todoListId,
    required String name,
    required int color,
  }) async {
    TodoListModel targetTodoList =
        await getTodoListById(todoListId: todoListId);
    TodoListModel modifiedTodoList = TodoListModel(
      id: todoListId,
      name: name,
      color: color,
      todolist: targetTodoList.todolist,
    );
    await modifyTodoList(modifiedTodoList);
  }

  String encodeTodo(TodoModel todo) {
    String result = "{";

    result += '"id": "${todo.id}",';
    result += '"title": "${todo.title}",';
    result += todo.memo != null ? '"memo": "${todo.memo}",' : "";
    result += todo.deadLine != null ? '"deadLine": "${todo.deadLine}",' : "";
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
