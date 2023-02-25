import 'package:flutter/material.dart';
import 'package:todolist/constances/custom_colors.dart';
import 'package:todolist/services/todolist_service.dart';

class RegistCategory extends StatefulWidget {
  final Function refreshCategories;

  const RegistCategory({
    super.key,
    required this.refreshCategories,
  });

  @override
  State<RegistCategory> createState() => _RegistCategoryState();
}

class _RegistCategoryState extends State<RegistCategory> {
  final newTodoListName = TextEditingController();
  final customColors = CustomColors.colors;

  int selectedColor = 0;

  @override
  void dispose() {
    newTodoListName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "새로운 목록",
        ),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "취소",
            style: TextStyle(
              fontSize: 19,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (newTodoListName.text.isNotEmpty) {
                await TodolistService().addTodoList(
                    name: newTodoListName.text,
                    color: customColors[selectedColor]);
                await widget.refreshCategories();
                Navigator.pop(context);
              }
            },
            child: Text(
              "완료",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: newTodoListName.text.isEmpty
                    ? Colors.blue.shade100
                    : Colors.blue,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraint) => SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minHeight: constraint.maxHeight),
            color: Colors.grey.shade200,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      controller: newTodoListName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20,
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            style: BorderStyle.none,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            style: BorderStyle.none,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        hintText: "목록 이름",
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (var i = 0; i < customColors.length / 2; i++)
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                    border: Border.all(
                                      color: i == selectedColor
                                          ? Colors.grey.shade400
                                          : Colors.white,
                                      width: 3,
                                    )),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedColor = i;
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.circle,
                                    size: 45,
                                    color: Color(customColors[i]),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (var i = 0; i < customColors.length / 2; i++)
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                    border: Border.all(
                                      color: i +
                                                  (customColors.length / 2)
                                                      .ceil() ==
                                              selectedColor
                                          ? Colors.grey.shade400
                                          : Colors.white,
                                      width: 3,
                                    )),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() {
                                      selectedColor =
                                          i + (customColors.length / 2).ceil();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.circle,
                                    size: 45,
                                    color: Color(customColors[
                                        i + (customColors.length / 2).ceil()]),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
