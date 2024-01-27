import 'package:flutter/material.dart';
import 'package:router_lifecycle_example/router_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'router_lifecycle',
      debugShowCheckedModeBanner: false,
      routerDelegate: router,
      routeInformationParser: router.defaultParser(),
    );
  }
}
