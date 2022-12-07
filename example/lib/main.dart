import 'package:flutter/material.dart';
import 'package:router_lifecycle_example/pages/login.dart';
import 'package:router_lifecycle_example/router_helper.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key) {
    router.push(page: const Login());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Navigator 2.0',
      debugShowCheckedModeBanner: false,
      routerDelegate: router,
      routeInformationParser: router.defaultParser(),
    );
  }
}

