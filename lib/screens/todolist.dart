import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todolist/models/todo_model.dart';
import 'package:todolist/models/todolist_model.dart';
import 'package:todolist/services/todolist_service.dart';
import 'package:todolist/widgets/input_todo.dart';
import 'package:todolist/widgets/todo.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late Future<TodoListModel> todolist;

  bool viewNewTodo = false;
  String editTodoId = "";

  @override
  void initState() {
    super.initState();
    todolist = TodolistService().getTodoListById();
  }

  void hideNewTodo() {
    setState(() {
      viewNewTodo = false;
    });
  }

  void updateTodoList() {
    setState(() {
      todolist = TodolistService().getTodoListById();
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

          return Scaffold(
            appBar: AppBar(
              title: Text(
                todoList.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              backgroundColor: Color(todoList.color),
              elevation: 0,
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.menu,
                  size: 30,
                ),
                color: Colors.black,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      viewNewTodo = true;
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 30,
                    color: Colors.black,
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
                            "${todoList.todolist.length} Total, ${getCompletedCount(todoList.todolist)} Completed"),
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
