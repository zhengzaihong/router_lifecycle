import 'package:flutter/material.dart';
import 'package:router_pro/router_lib.dart';
import 'package:router_lifecycle_example/pages/nav_page.dart';

import '../main.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LifeCycle(
        onCreate: () {
          debugPrint("------onCreate--Login ${this.hashCode}");
        },
        onStart: () {
          debugPrint("--------Login onStart");
        },
        onResume: () {
          debugPrint("--------Login onResume");
        },
        onPause: () {
          debugPrint("--------Login onPause");
        },
        onDestroy: () {
          debugPrint("------onDestroy--Login ${this.hashCode}");
        },
        child: Scaffold(
            body: Stack(
          children: [
            Container(
              constraints: const BoxConstraints.expand(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(
                        width: 16,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        onPressed: () {
                          router.pushNamed(name: 'hhahaha');
                        },
                        child: const Text(
                          '注册',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          side: const BorderSide(color: Colors.black),
                        ),
                        onPressed: () {
                          router.push(page: const NavPage());
                        },
                        child: const Text(
                          '登录',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )));
  }
}
