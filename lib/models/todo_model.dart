class TodoModel {
  final String id, title;
  final bool isCompleted;

  TodoModel({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  TodoModel.fromJson(Map<String, dynamic> data)
      : id = data["id"],
        title = data["title"],
        isCompleted = data["isCompleted"];
}
