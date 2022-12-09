
import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';
import 'package:router_lifecycle_example/pages/login.dart';
import 'package:router_lifecycle_example/router_helper.dart';

class JdPageDetail extends StatefulLifeCycle {
  JdPageDetail({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> getState() => _JdPageDetailState();
}

class _JdPageDetailState extends State<JdPageDetail> with LifeCycle{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            router.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios,size: 30,color: Colors.red),
        ),
      ),
      body: Column(
        children:  [
          Expanded(child:   Center(child:  GestureDetector(
            onTap: (){
              router.push(page:   Login());
            },
            child:  const Text("京东详情页面"),
          ),))
        ],
      ),
    );
  }

  @override
  void onResume() {
    super.onResume();
    print("--------JdPageDetail onResume");
  }
  @override
  void onPause() {
    super.onPause();
    print("--------JdPageDetail onPause");
  }
  @override
  void onDestroy() {
    super.onDestroy();
    print("--------JdPageDetail onDestroy");
  }
}
