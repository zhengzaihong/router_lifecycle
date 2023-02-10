
import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';
import 'package:router_lifecycle_example/pages/login.dart';

///
/// create_user: zhengzaihong
/// email:1096877329@qq.com
/// create_date: 2023/2/10
/// create_time: 13:46
/// describe: 子页面才需要生命周期监听的
///
class TestWrapperPage extends StatefulLifeCycle {

  TestWrapperPage({Key? key}) : super(key: key);

  @override
  State<TestWrapperPage> getState() => _TestWrapperPageState();
}

class _TestWrapperPageState extends State<TestWrapperPage> with WrapperPage {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getChild(),
    );
  }

  @override
  Login? childPage() {
    return Login();
  }
}
