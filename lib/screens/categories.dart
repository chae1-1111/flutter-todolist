import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todolist/models/todolist_model.dart';
import 'package:todolist/screens/category_editor.dart';
import 'package:todolist/screens/settings.dart';
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
  List<TodoListModel> categories = [];
  String defaultCategoryId = "";

  late Future<bool> isLoaded;

  @override
  void initState() {
    super.initState();
    isLoaded = refreshCategories();
  }

  Future<bool> refreshCategories() async {
    categories = await TodolistService().getAllTodoLists();
    defaultCategoryId = await TodolistService().getDefaultTodoList();
    setState(() {});
    return true;
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Settings(),
                ),
              );
            },
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
                  future: isLoaded,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // defaut TodoList 최상단으로 정렬
                      var sortedCategories = [];
                      for (var element in categories) {
                        if (element.id == defaultCategoryId) {
                          sortedCategories.insert(0, element);
                        } else {
                          sortedCategories.add(element);
                        }
                      }
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
                            child: SlidableAutoCloseBehavior(
                              child: ListView.separated(
                                itemCount: sortedCategories.length,
                                itemBuilder: (context, index) => CategoryItem(
                                  category: sortedCategories[index],
                                  isDefault: sortedCategories[index].id ==
                                      defaultCategoryId,
                                  setTodoListId: widget.setTodoListId,
                                  refreshCategories: refreshCategories,
                                ),
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                  height: 20,
                                ),
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
                              builder: (context) => CategoryEditor.newCategory(
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
