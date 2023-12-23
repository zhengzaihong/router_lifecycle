import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/wrapper/life_cycle_page.dart';
import 'package:router_lifecycle_example/pages/jd_page_detail.dart';
import 'package:router_lifecycle_example/router_helper.dart';

class JdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LifeCyclePage(
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
    ));
  }
}
