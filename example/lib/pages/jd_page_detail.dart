
import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';
import 'package:router_lifecycle_example/pages/login.dart';
import 'package:router_lifecycle_example/router_helper.dart';

class JdPageDetail extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return LifeCycle(
        onCreate: (){
          print("--------JdPageDetail onCreate");
        },
        onStart: (){
          print("--------JdPageDetail onStart");
        },
        onResume: (){
          print("--------JdPageDetail onResume");
        },
        onPause: (){
          print("--------JdPageDetail onPause");
        },
        onDestroy: (){
          print("--------JdPageDetail onDestroy");
        },
        child: Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            // router.pop(context);
            router.pushNamed(name: 'TaoBaoPageDetail1',custom: true);
          },
          child: const Icon(Icons.arrow_back_ios,size: 30,color: Colors.red),
        ),
      ),
      body: Column(
        children:  [
          Expanded(child:   Center(child:  GestureDetector(
            onTap: (){
              showDialog(context: context,
                  builder: (context){
                    return AlertDialog(
                      content:  Container(
                        height: 400,
                        child: const Text('aaaaaaaaaaaaaaaaaaaaaaa'),
                      ),
                    );
                  });
            },
            child:  const Text("京东详情页面"),
          ),))
        ],
      ),
    ));
  }
}
