import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  SearchBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(16))),
        child: buildTextField());
  }

  Widget buildTextField() {
    return Row(children: [
      const Icon(Icons.search, size: 20),
      Expanded(
          child: TextField(
              controller: controller,
              decoration: const InputDecoration.collapsed(
                  hintText: "Search something……")))
    ]);
  }
}
