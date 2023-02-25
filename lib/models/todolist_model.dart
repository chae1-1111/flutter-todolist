import 'package:todolist/models/todo_model.dart';

class TodoListModel {
  final String id, name;
  final int color;
  final List<TodoModel> todolist;

  TodoListModel({
    required this.id,
    required this.name,
    required this.color,
    this.todolist = const [],
  });

  TodoListModel.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        color = int.parse(json["color"]),
        todolist = (json["todolist"] as List).map((todo) {
          return TodoModel.fromJson(todo);
        }).toList();
}
