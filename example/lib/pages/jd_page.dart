import 'package:flutter/material.dart';
import 'package:router_plus/router_lib.dart';
import 'package:router_lifecycle_example/pages/jd_page_detail.dart';
import 'package:router_lifecycle_example/router_helper.dart';

class JdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LifeCycle(
      onResume: (){
        print("--------JdPage onResume");
      },
      onPause: (){
        print("--------JdPage onPause");
      },
      onDestroy: (){
        print("--------JdPage onDestroy");
      },
        child: Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<Widget?>(
              valueListenable: router.currentTargetPage,
              builder: (context, value, child) {
                print("----------value:${value.hashCode}");
                return value ?? Center(
                    child: GestureDetector(
                      onTap: () {
                        router.push(page: JdPageDetail());
                      },
                      child: const Text("京东页面"),
                    ));
              },
            ),
          )
        ],
      ),
    ));
  }
}
