class TodoModel {
  final String id, title;
  final String? memo;
  final DateTime? deadLine;
  final bool isCompleted;

  TodoModel({
    required this.id,
    required this.title,
    this.memo,
    this.deadLine,
    required this.isCompleted,
  });

  TodoModel.fromJson(Map<String, dynamic> data)
      : id = data["id"],
        title = data["title"],
        memo = data["memo"],
        // deadLine = null,
        deadLine = data["deadLine"] != null && data["deadLine"] != ""
            ? DateTime.parse(data["deadLine"])
            : null,
        isCompleted = data["isCompleted"];
}
