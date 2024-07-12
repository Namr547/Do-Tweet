// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const Comment(
      {super.key, required this.text, required this.time, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(4)),
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //comment
          Text(text),
          SizedBox(
            height: 5,
          ),

          //user, time
          Row(
            children: [
              Text(
                user,
                style: TextStyle(color: Colors.grey.shade500),
              ),
              Text(' . ', style: TextStyle(color: Colors.grey.shade500)),
              Text(time, style: TextStyle(color: Colors.grey.shade500))
            ],
          )
        ],
      ),
    );
  }
}
