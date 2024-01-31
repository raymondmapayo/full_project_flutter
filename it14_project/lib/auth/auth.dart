import 'package:flutter/material.dart';
import 'package:it14_project/login.dart';
import 'package:it14_project/project/SignUP.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool a = true;
  void to() {
    setState(() {
      a = !a;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (a) {
      return Login(to);
    } else {
      return SignUP(to);
    }
  }
}
