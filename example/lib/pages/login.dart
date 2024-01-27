
import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';
import 'package:router_lifecycle_example/pages/nav_page.dart';
import 'package:router_lifecycle_example/pages/taobao_page_detail.dart';
import 'package:router_lifecycle_example/router_helper.dart';


  class Login extends StatelessWidget {
    const Login({Key? key}) : super(key: key);
    @override
    Widget build(BuildContext context) {
      return LifeCycle(
        onCreate: (){
          print("--------Login onCreate");
        },
        onStart: (){
          print("--------Login onStart");
        },
        onResume: (){
          print("--------Login onResume");
        },
        onPause: (){
          print("--------Login onPause");
        },
        onDestroy: (){
          print("--------Login onDestroy");
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
                            primary: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                          onPressed: () {
                            router.pushNamed(name: 'hhahaha');

                          },
                          child: const Text(
                            '注册',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            side: const BorderSide(color: Colors.black),
                          ),
                          onPressed: () {
                            router.push(page: NavPage());
                          },
                          child: const Text('登录', style: TextStyle(color: Colors.black),),
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
          )
      ));
    }
  }
