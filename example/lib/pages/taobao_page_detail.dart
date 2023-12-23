import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';
import 'package:flutter_router_forzzh/wrapper/life_cycle_page.dart';
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
    return WillPopScope(
        onWillPop: onWillPop,
        child: LifeCyclePage(
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
                router.pop(context);
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



  Future<bool> onWillPop() {
    if(router.isShowingModalBottomSheet(context)){
      router.pop(context);
      return Future.value(false);
    }
    return Future.value(true);
  }
}
