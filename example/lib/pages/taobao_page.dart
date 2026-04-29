import 'package:flutter/material.dart';
import 'package:router_pro/router_lib.dart';
import 'package:router_lifecycle_example/pages/taobao_page_detail.dart';

import '../main.dart';

class TaoBaoPage extends StatelessWidget {
  const TaoBaoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LifeCycle(
        onCreate: () {
          debugPrint("--------TaoBaoPage onCreate");
        },
        onStart: () {
          debugPrint("--------TaoBaoPage onStart");
        },
        onResume: () {
          debugPrint("--------TaoBaoPage onResume");
        },
        onPause: () {
          debugPrint("--------TaoBaoPage onPause");
        },
        onDestroy: () {
          debugPrint("--------TaoBaoPage onDestroy");
        },
        child: Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                router.pop();
              },
              child: const Icon(Icons.arrow_back_ios, size: 30, color: Colors.red),
            ),
          ),
          body: Builder(
            builder: (context) {
              var title = "淘宝页面";
              return StatefulBuilder(
                builder: (context,setState) {
                  return Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              router.push(
                                  page:const TaoBaoPageDetail(),
                                  onResult: (value){ //可选
                                    setState((){
                                      title = "淘宝页面$value";
                                    });
                              });
                              router.pushNamed(
                                  name: 'TaoBaoPageDetail',
                                  onResult: (value){ //可选
                                    setState((){
                                      title = "淘宝页面$value";
                                    });
                                  });
                            },
                            child: Text(title),
                          ),
                        ),
                      )
                    ],
                  );
                }
              );
            }
          ),
        ));
  }
}
