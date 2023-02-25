import 'package:flutter/material.dart';
import 'package:todolist/models/todolist_model.dart';
import 'package:todolist/screens/new_category.dart';
import 'package:todolist/services/todolist_service.dart';
import 'package:todolist/widgets/category.dart';

class Categories extends StatefulWidget {
  final Function setTodoListId;

  const Categories({
    super.key,
    required this.setTodoListId,
  });

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  late Future<List<TodoListModel>> categories;

  @override
  void initState() {
    super.initState();
    categories = TodolistService().getAllTodoLists();
  }

  void refreshCategories() {
    setState(() {
      categories = TodolistService().getAllTodoLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings,
            ),
          ),
        ],
        leading: const SizedBox.shrink(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [
              Flexible(
                flex: 10,
                child: FutureBuilder(
                  future: categories,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var categories = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "할일 목록",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: categories.length,
                              itemBuilder: (context, index) => CategoryItem(
                                category: categories[index],
                                setTodoListId: widget.setTodoListId,
                              ),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 20,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegistCategory(
                                    refreshCategories: refreshCategories,
                                  ),
                              fullscreenDialog: true),
                        );
                      },
                      child: const Text(
                        "목록 생성",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
