import 'dart:developer';

import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:todolist/models/todolist_model.dart';
import 'package:todolist/services/todolist_service.dart';
import 'package:todolist/widgets/todo.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late List<DragAndDropList> _contents;
  late TodoListModel todolist;
  late Future<bool> isLoaded;

  @override
  void initState() {
    super.initState();
    _contents = List.generate(0, (index) {
      return DragAndDropList(children: <DragAndDropItem>[]);
    });

    isLoaded = getTodolist();
  }

  Future<bool> getTodolist() async {
    todolist = await TodolistService().getTodoListById();

    // Generate a list
    _contents = List.generate(1, (index) {
      return DragAndDropList(
        children: <DragAndDropItem>[
          for (var todo in todolist.todolist)
            DragAndDropItem(
              // child: Text(todo.title),
              child: Todo(
                todoListId: "2",
                themeColor: Colors.black,
                todo: todo,
                updateTodoList: () {},
                setEditTodoId: () {},
              ),
            ),
        ],
      );
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("설정"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder(
        future: isLoaded,
        builder: (context, snapshot) => DragAndDropLists(
          children: _contents,
          onItemReorder: _onItemReorder,
          onListReorder: (oldListIndex, newListIndex) {},
        ),
      ),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      // var movedItem = _contents[oldListIndex].children.removeAt(oldItemIndex);
      // _contents[newListIndex].children.insert(newItemIndex, movedItem);

      log("moved");
    });
  }
}
