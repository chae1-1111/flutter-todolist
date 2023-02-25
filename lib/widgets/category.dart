import 'package:flutter/material.dart';
import 'package:todolist/models/todolist_model.dart';

class CategoryItem extends StatelessWidget {
  final TodoListModel category;
  final Function setTodoListId;

  const CategoryItem({
    super.key,
    required this.category,
    required this.setTodoListId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await setTodoListId(category.id);
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 17,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Color(category.color),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Text(
                      "${category.todolist.length}",
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 25,
                    ),
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
