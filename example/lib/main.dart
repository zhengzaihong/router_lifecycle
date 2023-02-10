import 'package:flutter/material.dart';
import 'package:router_lifecycle_example/pages/login.dart';
import 'package:router_lifecycle_example/pages/test_wrapper_page.dart';
import 'package:router_lifecycle_example/router_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key) {
    // router.push(page:  Login());
    router.push(page:  TestWrapperPage());
  }

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
