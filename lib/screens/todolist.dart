import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todolist/models/todo_model.dart';
import 'package:todolist/models/todolist_model.dart';
import 'package:todolist/screens/categories.dart';
import 'package:todolist/services/todolist_service.dart';
import 'package:todolist/widgets/input_todo.dart';
import 'package:todolist/widgets/slide_right_route.dart';
import 'package:todolist/widgets/todo.dart';

class TodoList extends StatefulWidget {
  final String todoListId;

  const TodoList({
    super.key,
    this.todoListId = "",
  });

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late Future<TodoListModel> todolist;
  late String todoListId;

  bool viewNewTodo = false;
  String editTodoId = "";

  @override
  void initState() {
    super.initState();
    todoListId = widget.todoListId;
    todolist = TodolistService().getTodoListById(todoListId: todoListId);
  }

  void setTodoListId(String newTodoListId) {
    setState(() {
      todoListId = newTodoListId;
      todolist = TodolistService().getTodoListById(todoListId: todoListId);
    });
  }

  void hideNewTodo() {
    setState(() {
      viewNewTodo = false;
    });
  }

  void updateTodoList() {
    setState(() {
      todolist = TodolistService().getTodoListById(todoListId: todoListId);
    });
  }

  void setEditTodoId(String todoId) {
    setState(() {
      editTodoId = todoId;
    });
  }

  void resetEditTodoId() {
    setState(() {
      editTodoId = "";
    });
  }

  int getCompletedCount(List<TodoModel> todoList) {
    int count = 0;
    for (TodoModel todo in todoList) {
      if (todo.isCompleted) {
        count++;
      }
    }
    return count;
  }

  Color getTextColor(int colorCode) {
    Map<String, int> rgbMap = {
      "R": ((colorCode - 0xFF000000) / (256 * 256)).ceil(),
      "G": (((colorCode - 0xFF000000) / 256) % 256).ceil(),
      "B": ((colorCode - 0xFF000000) % 256).ceil(),
    };

    // convert RGB to YIQ (사람 눈의 시신경 분포에 맞게 보정)
    var lightness =
        (rgbMap["R"]! * 0.299 + rgbMap["G"]! * 0.587 + rgbMap["B"]! * 0.114) /
            255;

    return lightness >= 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: todolist,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // 완료된 Todo를 리스트 하단으로 정렬
          List<TodoModel> sortedList = snapshot.data!.todolist
              .where((element) => !element.isCompleted)
              .toList();
          sortedList.addAll(
              snapshot.data!.todolist.where((element) => element.isCompleted));

          TodoListModel todoList = TodoListModel(
            id: snapshot.data!.id,
            name: snapshot.data!.name,
            color: snapshot.data!.color,
            todolist: sortedList,
          );

          Color textColor = getTextColor(todoList.color);

          return Scaffold(
            appBar: AppBar(
              title: Text(
                todoList.name,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              backgroundColor: Color(todoList.color),
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    SlideRightRoute(
                        page: Categories(
                      setTodoListId: setTodoListId,
                    )),
                  );
                },
                icon: const Icon(
                  Icons.menu,
                  size: 30,
                ),
                color: textColor,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      viewNewTodo = true;
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    size: 30,
                    color: textColor,
                  ),
                )
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "전체 ${todoList.todolist.length}, 완료됨 ${getCompletedCount(todoList.todolist)}"),
                        TextButton(
                          onPressed: () async {
                            await TodolistService()
                                .removeCompletedTodo(todoListId: todoList.id);
                            updateTodoList();
                          },
                          child: const Text(
                            "완료된 항목 지우기",
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SlidableAutoCloseBehavior(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(children: [
                                for (var todo in todoList.todolist)
                                  Column(
                                    children: [
                                      todo.id != editTodoId
                                          ? Todo(
                                              todoListId: todoList.id,
                                              themeColor: Color(todoList.color),
                                              todo: todo,
                                              updateTodoList: updateTodoList,
                                              setEditTodoId: setEditTodoId,
                                            )
                                          : InputTodo.editTodo(
                                              todoListId: todoList.id,
                                              defaultValue: todo.title,
                                              todoId: todo.id,
                                              themeColor: Color(todoList.color),
                                              updateTodoList: updateTodoList,
                                              hideInputTodo: resetEditTodoId,
                                            ),
                                      const Divider(
                                        thickness: 1,
                                      )
                                    ],
                                  ),
                                viewNewTodo
                                    ? InputTodo.newTodo(
                                        todoListId: todoList.id,
                                        themeColor: Color(todoList.color),
                                        hideInputTodo: hideNewTodo,
                                        updateTodoList: updateTodoList,
                                      )
                                    : const SizedBox.shrink(),
                              ])
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "",
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
