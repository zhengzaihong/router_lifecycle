


import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';
import 'package:router_lifecycle_example/pages/login.dart';
import 'package:router_lifecycle_example/pages/taobao_page_detail.dart';

    RouterProxy router = RouterProxy.getInstance(
        routePathCallBack: (routeInformation) {
          ///自定义的动态路由 跳转
          if (routeInformation.location == 'TaoBaoPageDetail1') {
            return TaoBaoPageDetail();
          }
        },
        pageMap: {
          '/': const Login(),
          'TaoBaoPageDetail':  TaoBaoPageDetail(),
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