import 'package:flutter/material.dart';

class MyBird extends StatefulWidget {
  MyBird({super.key, required this.birdWeight});

  final double birdWeight;

  @override
  State<MyBird> createState() => _MyBirdState();
}

class _MyBirdState extends State<MyBird> {
  @override
  Widget build(BuildContext context) {
    double customHeight;

    if (widget.birdWeight < 3) {
      customHeight = MediaQuery.of(context).size.height * 0.3;
    } else {
      customHeight = MediaQuery.of(context).size.height * 0.1;
    }

    return Container(
      height: customHeight,
      width: customHeight,
      child: Image.asset(
        'lib/images/pngegg.png',
      ),
    );
  }
}
