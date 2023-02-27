import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todolist/models/todolist_model.dart';
import 'package:todolist/screens/category_editor.dart';
import 'package:todolist/services/todolist_service.dart';

class CategoryItem extends StatelessWidget {
  final TodoListModel category;
  final bool isDefault;
  final Function setTodoListId, refreshCategories;

  const CategoryItem({
    super.key,
    required this.category,
    required this.isDefault,
    required this.setTodoListId,
    required this.refreshCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: UniqueKey(),
      groupTag: 1,
      startActionPane: isDefault
          ? null
          : ActionPane(
              extentRatio: 0.17,
              motion: const StretchMotion(),
              children: [
                CustomSlidableAction(
                  onPressed: (context) async {
                    await TodolistService().setDefaultTodoList(category.id);
                    await refreshCategories();
                  },
                  backgroundColor: Colors.yellow.shade600,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Flexible(
                        child: Icon(
                          Icons.star_border,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      endActionPane: ActionPane(
        extentRatio: 0.35,
        motion: const StretchMotion(),
        // dismissible: DismissiblePane(onDismissed: () async {
        //   showDeleteConfirmDialog(context);
        // }),
        children: [
          CustomSlidableAction(
            onPressed: (context) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CategoryEditor.editCategory(
                          refreshCategories: refreshCategories,
                          todoListId: category.id,
                          name: category.name,
                          color: category.color,
                        ),
                    fullscreenDialog: true),
              );
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
              if (isDefault) {
                showChangeDefaultDialog(
                  context: context,
                );
              } else {
                showDeleteConfirmDialog(
                  context: context,
                  todoListId: category.id,
                  refreshCategories: refreshCategories,
                );
              }
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
      child: GestureDetector(
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
                  flex: 20,
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
                      isDefault
                          ? Icon(
                              Icons.star,
                              size: 23,
                              color: Colors.yellow.shade700,
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(
                        width: 5,
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
                  flex: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${category.todolist.where(
                              (element) => !element.isCompleted,
                            ).length > 99 ? "99+" : category.todolist.where(
                              (element) => !element.isCompleted,
                            ).length}",
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
      ),
    );
  }

  void showDeleteConfirmDialog({
    required BuildContext context,
    required String todoListId,
    required Function refreshCategories,
  }) {
    showDialog(
      context: context,
      // barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "이 목록을 삭제하시겠습니까?",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text("포함된 모든 할일이 삭제됩니다."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("취소")),
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await TodolistService()
                      .removeTodoList(todoListId: todoListId);
                  await refreshCategories();
                },
                child: const Text("확인")),
          ],
        );
      },
    );
  }

  void showChangeDefaultDialog({
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      // barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "즐겨찾기 목록은 삭제할 수 없습니다.",
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: const Text("확인")),
          ],
        );
      },
    );
  }
}
