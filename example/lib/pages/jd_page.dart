import 'package:flutter/material.dart';
import 'package:router_pro/router_lib.dart';
import 'package:router_lifecycle_example/pages/jd_page_detail.dart';

import '../main.dart';

class JdPage extends StatelessWidget {
  const JdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LifeCycle(
        onResume: () {
          debugPrint("--------JdPage onResume");
        },
        onPause: () {
          debugPrint("--------JdPage onPause");
        },
        onDestroy: () {
          debugPrint("--------JdPage onDestroy");
        },
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<Widget?>(
                  valueListenable: router.currentTargetPage,
                  builder: (context, value, child) {
                    return value ??
                        Center(
                            child: GestureDetector(
                          onTap: () {
                            router.push(page: const JdPageDetail(), arguments: {
                              'id': 1001,
                              'title': '测试详情'
                            });
                            // router.push(page: const JdPageDetail(), arguments: {
                            //   'id': 1001,
                            //   'title': '测试详情'
                            // }).then((result) {
                            //   debugPrint("----------result:$value");
                            // });
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
