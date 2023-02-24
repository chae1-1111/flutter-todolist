class TodoModel {
  final String title;
  final bool isCompleted;

  TodoModel({
    required this.title,
    required this.isCompleted,
  });

  TodoModel.fromJson(Map<String, dynamic> data)
      : title = data["title"],
        isCompleted = data["isCompleted"];
}
