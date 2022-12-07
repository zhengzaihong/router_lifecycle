import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';
import 'package:router_lifecycle_example/pages/taobao_page_detail.dart';
import 'package:router_lifecycle_example/router_helper.dart';


class TaoBaoPage extends StatelessWidget with LifeCycle {
  TaoBaoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  @override
  void onResume() {
    super.onResume();
    print("--------TaoBaoPage 得到焦点");
  }

  @override
  void onPause() {
    super.onPause();
    print("--------TaoBaoPage 失去焦点");
  }
}
