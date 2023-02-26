import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todolist/models/todo_model.dart';
import 'package:todolist/services/todolist_service.dart';

class Todo extends StatelessWidget {
  final String todoListId;
  final Color themeColor;
  final TodoModel todo;
  final Function updateTodoList, setEditTodoId;

  const Todo({
    super.key,
    required this.todoListId,
    required this.themeColor,
    required this.todo,
    required this.updateTodoList,
    required this.setEditTodoId,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      viewportBuilder: (context, position) => Slidable(
        groupTag: "0",
        key: UniqueKey(),
        endActionPane: ActionPane(
          extentRatio: 0.35,
          motion: const StretchMotion(),
          dismissible: DismissiblePane(onDismissed: () async {
            await TodolistService()
                .removeTodo(todoListId: todoListId, todoId: todo.id);
            updateTodoList();
          }),
          children: [
            CustomSlidableAction(
              onPressed: (context) {
                setEditTodoId(todo.id);
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Flexible(
                    child: Icon(
                      Icons.edit_outlined,
                      size: 30,
                    ),
                  )
                ],
              ),
            ),
            CustomSlidableAction(
              onPressed: (context) async {
                await TodolistService()
                    .removeTodo(todoListId: todoListId, todoId: todo.id);
                updateTodoList();
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Flexible(
                    child: Icon(
                      Icons.delete_forever,
                      size: 30,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 20, 5),
          child: Row(
            children: [
              IconButton(
                icon: Icon(todo.isCompleted
                    ? Icons.check_box
                    : Icons.check_box_outline_blank),
                onPressed: () async {
                  await TodolistService().changeCompleteTodo(
                    todoListId: todoListId,
                    todoId: todo.id,
                    isCompleted: !todo.isCompleted,
                  );
                  await updateTodoList();
                },
                color: themeColor,
              ),
              Flexible(
                child: TextButton(
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 21,
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: todo.isCompleted ? Colors.black54 : Colors.black,
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () async {
                    await TodolistService().changeCompleteTodo(
                      todoListId: todoListId,
                      todoId: todo.id,
                      isCompleted: !todo.isCompleted,
                    );
                    await updateTodoList();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
