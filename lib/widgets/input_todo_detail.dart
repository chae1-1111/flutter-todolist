import 'package:flutter/material.dart';

class InputTodoDetail extends StatefulWidget {
  const InputTodoDetail({super.key});

  @override
  State<InputTodoDetail> createState() => _InputTodoDetailState();
}

class _InputTodoDetailState extends State<InputTodoDetail> {
  bool isValid = false;

  final todoTitle = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkValidForm();
  }

  @override
  void dispose() {
    todoTitle.dispose();
    super.dispose();
  }

  void checkValidForm() {
    bool validCheck = false;

    if (todoTitle.text.isNotEmpty) {
      validCheck = true;
    }
    setState(() {
      isValid = validCheck;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 700,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
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
                onPressed: () {
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
          SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: todoTitle,
                  onChanged: (value) => checkValidForm(),
                  style: const TextStyle(),
                  decoration: const InputDecoration(
                    hintText: "할일 제목",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
