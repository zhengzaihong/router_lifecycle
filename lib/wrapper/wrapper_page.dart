
import 'package:flutter/material.dart';

///
/// create_user: zhengzaihong
/// email:1096877329@qq.com
/// create_date: 2023/2/10
/// create_time: 13:33
/// describe: 通过代理路由跳转非直接需要监听生命周期的页面时
///需要此类包裹，并实现 wrapperPage中的接口。
///
abstract class WrapperPage{

  Widget? _child;

  Widget? childPage(){
    return null;
  }

  Widget? getChild(){
    _child ??= childPage();
    return _child;
  }
}