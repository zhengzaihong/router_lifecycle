import 'package:flutter/material.dart';
import 'package:router_pro/router_lib.dart';

import '../main.dart';

class TaoBaoPageDetail extends StatefulWidget {
  const TaoBaoPageDetail({Key? key}) : super(key: key);

  @override
  State<TaoBaoPageDetail> createState() => _TaoBaoPageDetailState();
}

class _TaoBaoPageDetailState extends State<TaoBaoPageDetail>{
  bool isResume = false;

  @override
  Widget build(BuildContext context) {
    return LifeCycle(
    onResume: (){
      setState(() {
        isResume  = true;
      });
      debugPrint("--------TaoBaoPageDetail onResume");
    },
    onPause: (){
      isResume  = false;
      debugPrint("--------TaoBaoPageDetail onPause");
    },
    onDestroy: (){
      debugPrint("--------TaoBaoPageDetail onDestroy");
    },
    child: Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            router.popWithResult("返回值：hello");
            router.pop("返回值：hello");
          },
          child: const Icon(Icons.arrow_back_ios,size: 30,color: Colors.red),
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: (){
            router.showAppBottomSheet(builder: (context){
                  return  Container(
                    height: 400,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.red,
                    child: GestureDetector(
                      onTap: (){
                        router.popWithResult("这是返回结果");
                      },
                      child: const Text('点击我获取BottomSheet返回值'),
                    ),
                  );
                }).then((value){
                    debugPrint("--------showAppBottomSheet value:${value}");
            });
          },
          child:  Text("淘宝详情页面${isResume?"获得焦点":""}"),
        ),
      ),
    ));
  }
}
