import 'package:flutter/material.dart';
import 'package:router_plus/router_lib.dart';
import 'package:router_lifecycle_example/router_helper.dart';

class TaoBaoPageDetail extends StatefulWidget {
  TaoBaoPageDetail({Key? key}) : super(key: key);

  @override
  State<TaoBaoPageDetail> createState() => _TaoBaoPageDetailState();
}

class _TaoBaoPageDetailState extends State<TaoBaoPageDetail>{
  bool isResume = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop){
          router.pop();
        },
        child: LifeCycle(
        onResume: (){
          setState(() {
            isResume  = true;
          });
          print("--------TaoBaoPageDetail onResume");
        },
        onPause: (){
          isResume  = false;
          print("--------TaoBaoPageDetail onPause");
        },
        onDestroy: (){
          print("--------TaoBaoPageDetail onDestroy");
        },
        child: Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: (){
                router.pop();
              },
              child: const Icon(Icons.arrow_back_ios,size: 30,color: Colors.red),
            ),
          ),
          body: Column(
            children:  [Expanded(child: Center(child:GestureDetector(
              onTap: (){
                showModalBottomSheet(context: context,
                    builder: (context){
                      return  Container(
                        height: 400,
                        color: Colors.red,
                        child: const Text('aaaaaaaaaaaaaaaaaaaaaaa'),
                      );
                    });
              },
              child:  Text("淘宝详情页面${isResume?"获得焦点":""}"),
            )))],
          ),
        )));
  }
}
