import 'package:flutter_router_forzzh/router/router_proxy.dart';

///
/// create_user: zhengzaihong
/// Email:1096877329@qq.com
/// create_date: 2022-12-06
/// create_time: 12:19
/// describe 用于项目中具备导航菜单的页面 实现监听生命周期
/// 通常容器界面不做监听，只需监听具体展示的子页面
///
abstract class TabPageObserve{

  TabPageInfo? onCreateTabPage(){
    return null;
  }
}