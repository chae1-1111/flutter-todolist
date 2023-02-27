import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/services/todolist_service.dart';

class InputTodoDetail extends StatefulWidget {
  final String todoListId, todoId, type;
  String? defaultTitle, defaultMemo;
  final Function updateTodoList;
  DateTime? defaultDeadline;

  InputTodoDetail.newTodo({
    super.key,
    this.type = "newTodo",
    required this.todoListId,
    this.todoId = "",
    required this.updateTodoList,
  });

  InputTodoDetail.editTodo({
    super.key,
    this.type = "editTodo",
    required this.todoListId,
    required this.todoId,
    required this.defaultTitle,
    required this.updateTodoList,
    this.defaultMemo,
    this.defaultDeadline,
  });

  @override
  State<InputTodoDetail> createState() => _InputTodoDetailState();
}

class _InputTodoDetailState extends State<InputTodoDetail> {
  bool isValid = false;

  final todoTitleCont = TextEditingController();
  final todoMemoCont = TextEditingController();

  FocusNode titleFocusNode = FocusNode();
  FocusNode memoFocusNode = FocusNode();

  var todoDeadlineDate = "";
  var todoDeadlineTime = "";

  @override
  void initState() {
    super.initState();
    if (widget.type == "editTodo") {
      todoTitleCont.text = widget.defaultTitle ?? "";
      todoMemoCont.text = widget.defaultMemo ?? "";
      if (widget.defaultDeadline != null) {
        todoDeadlineDate =
            DateFormat("yyyy-MM-dd").format(widget.defaultDeadline!);
        todoDeadlineTime =
            "${NumberFormat("00").format(widget.defaultDeadline!.hour)}:${NumberFormat("00").format(widget.defaultDeadline!.minute)}";
      }
      setState(() {});
    }
    checkValidForm();
  }

  @override
  void dispose() {
    todoTitleCont.dispose();
    super.dispose();
  }

  void checkValidForm() {
    bool validCheck = false;

    if (todoTitleCont.text.trim().isNotEmpty) {
      validCheck = true;
    }
    setState(() {
      isValid = validCheck;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).viewInsets.bottom + 400,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 8,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "취소",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                const Text(
                  "세부사항",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (!isValid) return;

                    if (widget.type == "newTodo") {
                      await TodolistService().addTodo(
                        todoListId: widget.todoListId,
                        todoTitle: todoTitleCont.text,
                        todoMemo: todoMemoCont.text.trim().isEmpty
                            ? null
                            : todoMemoCont.text.trim(),
                        todoDeadLine: todoDeadlineDate.isEmpty
                            ? null
                            : DateTime.parse(
                                "$todoDeadlineDate ${todoDeadlineTime.isNotEmpty ? todoDeadlineTime : "00:00"}"),
                      );
                    } else if (widget.type == "editTodo") {
                      await TodolistService().modifyTodo(
                        todoListId: widget.todoListId,
                        todoId: widget.todoId,
                        newTitle: todoTitleCont.text,
                        newMemo: todoMemoCont.text.trim().isEmpty
                            ? null
                            : todoMemoCont.text.trim(),
                        newDeadLine: todoDeadlineDate.isEmpty
                            ? null
                            : DateTime.parse(
                                "$todoDeadlineDate ${todoDeadlineTime.isNotEmpty ? todoDeadlineTime : "00:00"}"),
                      );
                    }
                    await widget.updateTodoList();
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  child: Text(
                    "완료",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isValid ? FontWeight.w600 : FontWeight.w500,
                      color: isValid ? Colors.blue : Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                children: [
                  TextField(
                    controller: todoTitleCont,
                    focusNode: titleFocusNode,
                    onChanged: (value) => checkValidForm(),
                    onTapOutside: (event) => titleFocusNode.unfocus(),
                    maxLines: 1,
                    maxLength: 100,
                    style: const TextStyle(
                      fontSize: 22,
                    ),
                    decoration: const InputDecoration(
                      hintText: "할일 제목",
                      counterText: "",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          style: BorderStyle.none,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          style: BorderStyle.none,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 30,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: todoMemoCont,
                    focusNode: memoFocusNode,
                    onChanged: (value) => checkValidForm(),
                    onTapOutside: (event) => memoFocusNode.unfocus(),
                    minLines: 1,
                    maxLines: 3,
                    maxLength: 400,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                    decoration: const InputDecoration(
                      hintText: "메모",
                      counterText: "",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          style: BorderStyle.none,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          style: BorderStyle.none,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 15,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: SizedBox.expand(
                                child: TextButton(
                                  focusNode: FocusNode(),
                                  onPressed: setTodoDeadlineDate,
                                  child: Text(
                                    todoDeadlineDate.isEmpty
                                        ? "날짜"
                                        : todoDeadlineDate.replaceAll("-", "."),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: todoDeadlineDate.isEmpty
                                          ? Colors.grey.shade600
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const VerticalDivider(
                            thickness: 1,
                            color: Colors.grey,
                            indent: 10,
                            endIndent: 10,
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: SizedBox.expand(
                                child: TextButton(
                                  focusNode: FocusNode(),
                                  onPressed: setTodoDeadlineTime,
                                  child: Text(
                                    todoDeadlineTime.isEmpty
                                        ? "시간"
                                        : todoDeadlineTime,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: todoDeadlineTime.isEmpty
                                          ? Colors.grey.shade600
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future setTodoDeadlineDate() async {
    var result = await showDatePicker(
      context: context,
      initialDate: todoDeadlineDate.isEmpty ||
              DateTime.parse(todoDeadlineDate).compareTo(DateTime.now()) == -1
          ? DateTime.now()
          : DateTime.parse(todoDeadlineDate),
      firstDate:
          DateTime.parse(DateFormat("yyyy-MM-dd").format(DateTime.now())),
      lastDate: DateTime(DateTime.now().year + 100),
    );
    if (result == null) {
      setState(() {});
      return;
    } else {
      setState(() {
        todoDeadlineDate = DateFormat("yyyy-MM-dd").format(result);
      });
    }
  }

  Future setTodoDeadlineTime() async {
    if (todoDeadlineDate.isEmpty) {
      await setTodoDeadlineDate();
    }
    if (!mounted || todoDeadlineDate.isEmpty) return;
    var timeResult = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: todoDeadlineTime.isEmpty
            ? 0
            : int.parse(todoDeadlineTime.split(":")[0]),
        minute: todoDeadlineTime.isEmpty
            ? 0
            : int.parse(todoDeadlineTime.split(":")[1]),
      ),
    );
    if (timeResult == null) {
      setState(() {});
    } else {
      setState(() {
        todoDeadlineTime =
            "${NumberFormat("00").format(timeResult.hour)}:${NumberFormat("00").format(timeResult.minute)}";
      });
    }
  }
}
