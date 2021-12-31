import 'package:flutter/material.dart';

class PageIndicators extends StatelessWidget {
  const PageIndicators(
      {Key? key,
      required this.pages,
      required this.currentPage,
      required this.callback})
      : super(key: key);

  final int pages;
  final int currentPage;
  final ValueChanged<int> callback;

  @override
  Widget build(BuildContext context) {
    if (pages != 1) {
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.topCenter,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Offstage(
                offstage: !(currentPage > 1),
                child: TextButton(
                    child: const Icon(Icons.first_page, size: 18),
                    onPressed: () {
                      callback(1);
                    })),
            Offstage(
                offstage: !(currentPage >= 3),
                child: TextButton(
                    child: Text((currentPage - 2).toString()),
                    onPressed: () {
                      callback(currentPage - 2);
                    })),
            Offstage(
                offstage: !(currentPage >= 2),
                child: TextButton(
                    child: Text((currentPage - 1).toString()),
                    onPressed: () {
                      callback(currentPage - 1);
                    })),
            Offstage(
                offstage: pages == 1,
                child: TextButton(
                    child: Text((currentPage).toString(),
                        style: const TextStyle(color: Colors.grey)),
                    onPressed: () {})),
            Offstage(
                offstage: !(currentPage <= pages - 1),
                child: TextButton(
                    child: Text((currentPage + 1).toString()),
                    onPressed: () {
                      callback(currentPage + 1);
                    })),
            Offstage(
                offstage: !(currentPage <= pages - 2),
                child: TextButton(
                    child: Text((currentPage + 2).toString()),
                    onPressed: () {
                      callback(currentPage + 2);
                    })),
            Offstage(
                offstage: !(currentPage < pages),
                child: TextButton(
                    child: const Icon(Icons.last_page, size: 18),
                    onPressed: () {
                      callback(pages);
                    })),
          ]));
    } else {
      return const SizedBox();
    }
  }
}
