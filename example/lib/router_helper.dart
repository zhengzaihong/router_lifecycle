


import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';

RouterProxy router = RouterProxy(
  styleCallBack: (context){
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