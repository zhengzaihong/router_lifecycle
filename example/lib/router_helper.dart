import 'package:flutter/material.dart';
import 'package:router_lifecycle_example/pages/login.dart';
import 'package:router_pro/router/router_proxy.dart';

RouterProxy router = RouterProxy.getInstance(
    // routePathCallBack: (routeInformation) {
    //   print('routeInformation.location:${routeInformation.uri}');
    //   //自定义的动态路由 跳转
    //   if (routeInformation.uri.toString() == 'TaoBaoPageDetail1') {
    //     return JdPageDetail();
    //   }
    // },
    // navigateToTargetCallBack: (context,page){
    //   router.currentTargetPage.value = page;
    // },
    pageMap: {'/': const Login()},
    exitWindowStyle: _confirmExit);

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
