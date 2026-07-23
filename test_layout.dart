import 'package:flutter/material.dart';

void main() => runApp(
  const MaterialApp(
    home: Scaffold(body: Center(child: TestWidget())),
  ),
);

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 50, height: 70, color: Colors.red),
          const Expanded(
            child: ColoredBox(
              color: Colors.blue,
              child: Text('Middle content\nLine 2\nLine3'),
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(Icons.more_vert), Icon(Icons.push_pin)],
          ),
        ],
      ),
    );
  }
}
