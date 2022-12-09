import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';
import 'package:router_lifecycle_example/pages/jd_page_detail.dart';
import 'package:router_lifecycle_example/router_helper.dart';

class JdPage extends StatefulLifeCycle {
  JdPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> getState() => _JdPageState();
}

class _JdPageState extends State<JdPage> with LifeCycle {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
                child: GestureDetector(
              onTap: () {
                router.push(page: JdPageDetail());
              },
              child: const Text("京东页面"),
            )),
          )
        ],
      ),
    );
  }

  @override
  void onResume() {
    super.onResume();
    print("--------JdPage onResume");
  }

  @override
  void onPause() {
    super.onPause();
    print("--------JdPage onPause");
  }
  @override
  void onDestroy() {
    super.onDestroy();
    print("--------JdPage onDestroy");
  }
}
