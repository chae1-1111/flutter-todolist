import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:todolist/models/todo_model.dart';
import 'package:todolist/services/todolist_service.dart';
import 'package:todolist/widgets/input_todo_detail.dart';

class Todo extends StatelessWidget {
  final String todoListId;
  final Color themeColor;
  final TodoModel todo;
  final Function updateTodoList, setEditTodoId, scrollToBottom;

  const Todo({
    super.key,
    required this.todoListId,
    required this.themeColor,
    required this.todo,
    required this.updateTodoList,
    required this.setEditTodoId,
    required this.scrollToBottom,
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
              onPressed: (context) async {
                if ((todo.memo != null && todo.memo != "") ||
                    todo.deadLine != null) {
                  showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return InputTodoDetail.editTodo(
                        todoListId: todoListId,
                        todoId: todo.id,
                        defaultTitle: todo.title,
                        defaultMemo: todo.memo,
                        defaultDeadline: todo.deadLine,
                        updateTodoList: updateTodoList,
                      );
                    },
                    isScrollControlled: true,
                  );
                } else {
                  await setEditTodoId(todo.id);
                  await updateTodoList();
                }
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(todo.isCompleted
                    ? Icons.check_box
                    : Icons.check_box_outline_blank),
                onPressed: () async {
                  await TodolistService().changeCompleteTodo(
                    todoListId: todoListId,
                    todoId: todo.id,
                  );
                  if (!todo.isCompleted) {
                    scrollToBottom();
                  }
                  await updateTodoList();
                },
                color: themeColor,
              ),
              Flexible(
                child: TextButton(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 21,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color:
                              todo.isCompleted ? Colors.black54 : Colors.black,
                        ),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (todo.memo != null)
                        Text(
                          todo.memo!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      if (todo.deadLine != null)
                        Text(
                          dateTimeFormatter(todo.deadLine!),
                          style: TextStyle(
                            color: todo.isCompleted
                                ? Colors.grey.shade600
                                : getDateTimeColor(todo.deadLine!),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () async {
                    if ((todo.memo != null && todo.memo != "") ||
                        todo.deadLine != null) {
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return InputTodoDetail.editTodo(
                            todoListId: todoListId,
                            todoId: todo.id,
                            defaultTitle: todo.title,
                            defaultMemo: todo.memo,
                            defaultDeadline: todo.deadLine,
                            updateTodoList: updateTodoList,
                          );
                        },
                        isScrollControlled: true,
                      );
                    } else {
                      await setEditTodoId(todo.id);
                      await updateTodoList();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String dateTimeFormatter(DateTime dateTime) {
    if (isToday(dateTime) == 0) {
      if (dateTime.hour != 0 || dateTime.minute != 0) {
        return DateFormat("오늘 HH:mm").format(dateTime);
      } else {
        return "오늘";
      }
    } else if (isToday(dateTime) == 1) {
      if (dateTime.hour != 0 || dateTime.minute != 0) {
        return DateFormat("내일 HH:mm").format(dateTime);
      } else {
        return "내일";
      }
    } else if (dateTime.hour != 0 || dateTime.minute != 0) {
      return DateFormat("yyyy.MM.dd HH:mm").format(dateTime);
    }
    return DateFormat("yyyy.MM.dd").format(dateTime);
  }

  int isToday(DateTime date) {
    var now = DateTime.now();
    var todayStart = DateTime(now.year, now.month, now.day);
    var todayEnd = todayStart.add(const Duration(days: 1));

    var date1Ago = date.add(const Duration(days: -1));

    if (date.compareTo(todayStart) >= 0 && date.compareTo(todayEnd) < 0) {
      // 오늘
      return 0;
    } else if (date1Ago.compareTo(todayStart) >= 0 &&
        date1Ago.compareTo(todayEnd) < 0) {
      // 내일
      return 1;
    }
    // 나머지
    return -1;
  }

  getDateTimeColor(dateTime) {
    var result = isToday(dateTime);
    if (result == 0) {
      return Colors.red;
    } else if (result == 1) {
      return Colors.orange;
    } else {
      return Colors.grey.shade600;
    }
  }
}
