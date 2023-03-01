import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todolist/models/todo_model.dart';
import 'package:todolist/models/todolist_model.dart';
import 'package:todolist/screens/categories.dart';
import 'package:todolist/services/todolist_service.dart';
import 'package:todolist/statics/get_text_color.dart';
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
  late Future<bool> isLoaded;
  late TodoListModel todolist;
  late String todoListId;
  late List<DragAndDropList> dndLists;

  List<TodoModel> sortedList = [];
  Color textColor = Colors.black;

  bool viewNewTodo = false;
  String editTodoId = "";

  var scrollCont = ScrollController();

  @override
  void initState() {
    super.initState();
    todoListId = widget.todoListId;
    isLoaded = updateTodoList();
    dndLists = List.generate(0, (index) {
      return DragAndDropList(children: <DragAndDropItem>[]);
    });
  }

  void setTodoListId(String newTodoListId) {
    todoListId = newTodoListId;
    updateTodoList();
  }

  void hideInputTodo() {
    setState(() {
      viewNewTodo = false;
      editTodoId = "";
    });
    updateTodoList();
  }

  Future<bool> updateTodoList() async {
    todolist = await TodolistService().getTodoListById(todoListId: todoListId);

    sortedList =
        todolist.todolist.where((element) => !element.isCompleted).toList();
    sortedList
        .addAll(todolist.todolist.where((element) => element.isCompleted));

    TodoListModel sortedTodoList = TodoListModel(
      id: todolist.id,
      name: todolist.name,
      color: todolist.color,
      todolist: sortedList,
    );

    dndLists = List.generate(1, (index) {
      return DragAndDropList(
        children: <DragAndDropItem>[
          for (var todo in sortedTodoList.todolist)
            DragAndDropItem(
              // child: Text(todo.title),
              child: todo.id == editTodoId
                  ? InputTodo.editTodo(
                      todoListId: todoListId,
                      defaultTitle: todo.title,
                      defaultMemo: todo.memo,
                      defaultDeadline: todo.deadLine,
                      todoId: todo.id,
                      themeColor: Color(sortedTodoList.color),
                      updateTodoList: updateTodoList,
                      hideInputTodo: hideInputTodo)
                  : Todo(
                      todoListId: sortedTodoList.id,
                      themeColor: Color(sortedTodoList.color),
                      todo: todo,
                      updateTodoList: updateTodoList,
                      setEditTodoId: setEditTodoId,
                      scrollToBottom: scrollToBottom,
                    ),
            ),
        ],
      );
    });
    setState(() {
      textColor = ColorMethods.getTextColor(todolist.color);
    });
    return true;
  }

  void setEditTodoId(String todoId) {
    setState(() {
      editTodoId = todoId;
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

  void scrollToBottom() {
    scrollCont.animateTo(
      scrollCont.position.pixels > scrollCont.position.maxScrollExtent / 2
          ? scrollCont.position.maxScrollExtent
          : scrollCont.position.maxScrollExtent / 2,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Color(todolist.color),
        elevation: 0,
        title: FutureBuilder(
            future: isLoaded,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return Text(
                  todolist.name,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                );
              } else {
                return const Text("할일 목록");
              }
            }),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              SlideRightRoute(
                page: Categories(
                  setTodoListId: setTodoListId,
                ),
              ),
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
              if (todolist.todolist.isNotEmpty) {
                scrollCont.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              }
            },
            icon: Icon(
              Icons.add,
              size: 30,
              color: textColor,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
        child: FutureBuilder(
          future: isLoaded,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sortedList.isEmpty
                      ? const SizedBox.shrink()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "전체 ${todolist.todolist.length}, 완료됨 ${getCompletedCount(todolist.todolist)}"),
                            TextButton(
                              onPressed: () async {
                                await TodolistService().removeCompletedTodo(
                                    todoListId: todolist.id);
                                updateTodoList();
                              },
                              child: const Text(
                                "완료된 항목 지우기",
                              ),
                            ),
                          ],
                        ),
                  sortedList.isEmpty
                      ? const SizedBox.shrink()
                      : const Divider(
                          thickness: 1,
                        ),
                  viewNewTodo
                      ? InputTodo.newTodo(
                          todoListId: todolist.id,
                          themeColor: Color(todolist.color),
                          hideInputTodo: hideInputTodo,
                          updateTodoList: updateTodoList,
                        )
                      : const SizedBox.shrink(),
                  sortedList.isEmpty && !viewNewTodo
                      ? Expanded(
                          child: Center(
                            child: Text(
                              "목록 없음",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  sortedList.isEmpty
                      ? const SizedBox.shrink()
                      : SlidableAutoCloseBehavior(
                          child: Flexible(
                            child: DragAndDropLists(
                              scrollController: scrollCont,
                              lastListTargetSize: 0,
                              lastItemTargetHeight: 20,
                              children: dndLists,
                              onItemReorder: _onItemReorder,
                              onListReorder: (oldListIndex, newListIndex) {},
                            ),
                          ),
                        ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  int getUncompletedCount() {
    return todolist.todolist
        .where(
          (element) => !element.isCompleted,
        )
        .length;
  }

  void _onItemReorder(
    int oldItemIndex,
    int oldListIndex,
    int newItemIndex,
    int newListIndex,
  ) async {
    if (newItemIndex == oldItemIndex || newItemIndex >= getUncompletedCount()) {
      return;
    }

    String prevTodoId;

    if (newItemIndex == 0) {
      prevTodoId = "";
    } else if (newItemIndex > oldItemIndex) {
      prevTodoId = sortedList[newItemIndex].id;
    } else {
      prevTodoId = sortedList[newItemIndex - 1].id;
    }

    await TodolistService().reOrderTodo(
      todoListId: todoListId,
      todoId: sortedList[oldItemIndex].id,
      prevTodoId: prevTodoId,
    );
    await updateTodoList();

    setState(() {});
  }
}
