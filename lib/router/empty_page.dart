
import 'package:flutter/material.dart';
import 'package:router_pro/router/router_proxy.dart';

///
/// author:郑再红
/// email:1096877329@qq.com
/// date: 2024/1/26
/// time: 11:07
/// describe:
///
class EmptyPage extends StatelessWidget {
  const EmptyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('你访问的页面不存在',style: TextStyle(color: Colors.red,fontSize: 30),),
            TextButton(
                child:  const Text('返回首页',style: TextStyle(color: Colors.blue,fontSize: 20),),
                onPressed: () {
                  RouterProxy.getInstance().goRootPage();
                }
            )
          ],
        ),
      ),
    );
  }
}
