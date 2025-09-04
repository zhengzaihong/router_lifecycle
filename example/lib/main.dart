import 'package:flutter/material.dart';
import 'package:router_lifecycle_example/router_helper.dart';

void main() {
  // final String url = window.location.href;
  // final Uri uri = Uri.parse(url);
  // final queryParams = uri.queryParameters;
  // print('--> uri: ${uri.toString()}');
  // print('--> scheme: ${uri.scheme}');
  // print('--> path: ${uri.path}');
  // print('--> queryParams: $queryParams');
  // print('--> authority: ${uri.authority}');
  // print('--> data: ${uri.data}');
  // print('--> userInfo: ${uri.userInfo}');


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
