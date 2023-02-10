
import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';
import 'package:router_lifecycle_example/pages/nav_page.dart';
import 'package:router_lifecycle_example/router_helper.dart';


class Login extends StatefulLifeCycle {

  Login({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> getState() => _LoginState();
}

class _LoginState extends State<Login> with LifeCycle{


  @override
  void initState() {
    super.initState();
  }
  @override
  void onResume() {
    super.onResume();
    print("--------Login onResume");
  }
  @override
  void onPause() {
    super.onPause();
    print("--------Login onPause");
  }

  @override
  void onDestroy() {
    super.onDestroy();
    print("--------Login onDestroy");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      onPressed: () {},
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
    );
  }
}
