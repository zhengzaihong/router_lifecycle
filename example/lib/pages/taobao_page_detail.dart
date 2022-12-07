import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';
import 'package:router_lifecycle_example/router_helper.dart';

class TaoBaoPageDetail extends StatefulLifeCycle {
  TaoBaoPageDetail({Key? key}) : super(key: key);

  @override
  State<TaoBaoPageDetail> getState() => _TaoBaoPageDetailState();
}

class _TaoBaoPageDetailState extends State<TaoBaoPageDetail>  with LifeCycle{
  bool isResume = false;

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
        children:  [Expanded(child: Center(child: Text("淘宝详情页面${isResume?"获得焦点":""}")))],
      ),
    );
  }

  @override
  void onResume() {
    super.onResume();
    isResume  = true;
    setState(() {

    });
    print("--------TaoBaoPageDetail 得到焦点");

  }

  @override
  void onPause() {
    super.onPause();
    print("--------TaoBaoPageDetail 失去焦点");
  }
}
