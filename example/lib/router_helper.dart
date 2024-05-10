


import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';
import 'package:router_lifecycle_example/pages/jd_page_detail.dart';
import 'package:router_lifecycle_example/pages/login.dart';
import 'package:router_lifecycle_example/pages/taobao_page_detail.dart';

RouterProxy router = RouterProxy.getInstance(
    routePathCallBack: (routeInformation) {
      print('routeInformation.location:${routeInformation.location}');
      ///自定义的动态路由 跳转
      if (routeInformation.location == 'TaoBaoPageDetail1') {
        return JdPageDetail();
      }
    },
    navigateToTargetCallBack: (context,page){
      print("----------page:${page.runtimeType}");
      router.targetPageNotifier.value = Random().nextInt(100);
    },
    pageMap: {
      '/': const Login(),
      'TaoBaoPageDetail':  TaoBaoPageDetail(),
      // 'JdPageDetail':  JdPageDetail(),
    },
    exitStyleCallBack: (context){
    return _confirmExit(context);
  }
);

Future<bool> _confirmExit(BuildContext context) async {
  final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text('确定要退出App吗?'),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.pop(context, true),
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        );
      });
  return result ?? true;
}