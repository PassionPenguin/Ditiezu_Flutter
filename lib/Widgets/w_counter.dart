import 'package:flutter/material.dart';

class Counter extends StatefulWidget {
  final double max;
  final double min;

  CounterState state;

  Counter({Key key, this.max = double.infinity, this.min = double.negativeInfinity}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    state = CounterState();
    return state;
  }
}

class CounterState extends State<Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0), border: Border.all(width: 2, color: Colors.grey[200])),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
              child: Container(margin: EdgeInsets.symmetric(horizontal: 3), width: 30, height: 30, child: Center(child: Icon(Icons.remove, size: 16))),
              onTap: () {
                if (count >= widget.min + 1) count--;
                setState(() {});
              }),
          SizedBox(width: 24, child: Center(child: Text(count.toString()))),
          GestureDetector(
              child: Container(margin: EdgeInsets.symmetric(horizontal: 3), width: 30, height: 30, child: Center(child: Icon(Icons.add, size: 16))),
              onTap: () {
                if (count <= widget.max - 1) count++;
                setState(() {});
              }),
        ]));
  }
}
