import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
        child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Personal Information"),
                SizedBox(
                  height: 8.0,
                ),
                Text("Isthiyaque"),
              ],
            )));
  }
}
