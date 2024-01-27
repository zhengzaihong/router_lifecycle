import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';
import 'package:router_lifecycle_example/pages/taobao_page_detail.dart';
import 'package:router_lifecycle_example/router_helper.dart';


class TaoBaoPage extends StatelessWidget {

  TaoBaoPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LifeCycle(
        onCreate: () {
          print("--------TaoBaoPage onCreate");
        },
        onStart: () {
          print("--------TaoBaoPage onStart");
        },
        onResume: () {
          print("--------TaoBaoPage onResume");
        },
        onPause: () {
          print("--------TaoBaoPage onPause");
        },
        onDestroy: () {
          print("--------TaoBaoPage onDestroy");
        },
        child: Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  var page = TaoBaoPageDetail();
                  router.push(page: page);
                },
                child: const Text("淘宝页面"),
              ),
            ),
          )
        ],
      ),
    ));
  }
}
