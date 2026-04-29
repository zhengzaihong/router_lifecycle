
import 'package:flutter/material.dart';
import 'package:router_pro/router_lib.dart';
import 'package:router_lifecycle_example/pages/login.dart';
import 'package:router_lifecycle_example/pages/taobao_page_detail.dart';

import '../main.dart';

class JdPageDetail extends StatelessWidget {
  const JdPageDetail({super.key});


  @override
  Widget build(BuildContext context) {
    return LifeCycle(
        onCreate: (){
          debugPrint("--------JdPageDetail onCreate");
        },
        onStart: (){
          debugPrint("--------JdPageDetail onStart");
        },
        onResume: (){
          debugPrint("--------JdPageDetail onResume");
          // final argument = router.getArguments<Object?>();
          // debugPrint("--------JdPageDetail argument:${argument.toString()}");
        },
        onPause: (){
          debugPrint("--------JdPageDetail onPause");
        },
        onDestroy: (){
          debugPrint("--------JdPageDetail onDestroy");
        },
        child: Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            router.pop();
            // router.popWithResult("详情的返回值：hello");
          },
          child: const Icon(Icons.arrow_back_ios,size: 30,color: Colors.red),
        ),
      ),
      body: Column(
        children:  [
          Expanded(child:   Center(child:  GestureDetector(
            onTap: (){

              router.pushAndRemoveAll(const Login());


            },
            child: ValueListenableBuilder(
              valueListenable: router.currentTargetPage,
              builder: (context, value, child) {
                return  Text("京东详情页面 ${value}");
              },
            ),
          ),))
        ],
      ),
    ));
  }
}
