import 'package:flutter/material.dart';

class InProgress extends StatelessWidget {
  const InProgress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
