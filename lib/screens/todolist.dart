import 'package:flutter/material.dart';
import 'package:todolist/models/todo_model.dart';
import 'package:todolist/services/todolist_service.dart';

class TodoList extends StatelessWidget {
  TodoList({super.key});

  final Future<List<TodoModel>> todolist = TodolistService.getTodoList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TodoList",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.amber,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
          color: Colors.black,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 30,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("3 Total, 1 Complete"),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  FutureBuilder(
                    future: todolist,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return makeTodolist(snapshot);
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {
                    List<TodoModel> array = [];
                    array.add(
                        TodoModel(title: "Sample Todo 1", isCompleted: false));
                    array.add(
                        TodoModel(title: "Sample Todo 2", isCompleted: false));
                    TodolistService.saveTodoList(array);
                  },
                  backgroundColor: Colors.amber,
                  child: const Icon(
                    Icons.add,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListView makeTodolist(AsyncSnapshot<List<TodoModel>> snapshot) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        return Todo(title: snapshot.data![index].title);
      },
      separatorBuilder: (context, index) => const Divider(
        thickness: 1,
      ),
    );
  }
}

class Todo extends StatefulWidget {
  final String title;

  const Todo({
    super.key,
    required this.title,
  });

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    isCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
                isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
            onPressed: () {
              setState(() {
                isCompleted = !isCompleted;
              });
            },
            color: Colors.amber,
          ),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 21,
              decoration: isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: isCompleted ? Colors.black54 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class NewTodo extends StatelessWidget {
  const NewTodo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
      ),
      child: Row(
        children: [
          const Flexible(
            child: TextField(
              style: TextStyle(
                fontSize: 20,
              ),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: "New Task",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.check,
              color: Colors.amber,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
