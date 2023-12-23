import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';

///
/// create_user: zhengzaihong
/// Email:1096877329@qq.com
/// create_date: 2022-12-05
/// create_time: 09:12
/// describe 提供给跳转界面的路由，要监听生命周期的 务必使用该路由跳转、关闭页面
///
typedef RoutePathCallBack = Future<void> Function(
    List<RouteSettings> configuration, List<Page> pages);

typedef ExitStyleCallBack = Future<bool> Function(BuildContext context);

class RouterProxy extends RouterDelegate<List<RouteSettings>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<RouteSettings>> {
  RoutePathCallBack? routePathCallBack;
  ExitStyleCallBack? styleCallBack;

  RouterProxy({this.styleCallBack, this.routePathCallBack}) : super();

  CustomParser defaultParser() {
    return const CustomParser();
  }

  final List<Page> _pages = [];

  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  List<Page> get currentConfiguration => List.of(_pages);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: popRoute,
        child: Navigator(
          key: navigatorKey,
          pages: List.of(_pages),
          onPopPage: _onPopPage,
        ));
  }

  void pop(BuildContext context, {dynamic result}) async{
    if (canPop()) {
      _pages.removeLast();
      Navigator.of(context).pop(result);
    }
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(List<RouteSettings> configuration) {
    return routePathCallBack == null
        ? Future.value(null)
        : routePathCallBack!.call(configuration, _pages);
  }


  @override
  Future<bool> popRoute() async {
    if (Navigator.of(navigatorKey.currentContext!).canPop()) {
      Navigator.of(navigatorKey.currentContext!).pop();
      return Future.value(true);
    }
    if (canPop()) {
      _pages.removeLast();
      notifyListeners();
      return Future.value(true);
    }
    ///外部可仿照传入 styleCallBack定制推出样式
    return styleCallBack == null
        ? Future.value(false)
        : styleCallBack!.call(navigatorKey.currentContext!);
  }

  /// 检测是否打开了 showModalBottomSheet 或 Dialog
  bool isShowingModalBottomSheet(BuildContext? context) {
    if (context == null) {
      return false;
    }
    return ModalRoute.of(context)?.isCurrent ?? false;
  }


  bool canPop() => _pages.length > 1;

  bool _onPopPage(Route route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }
    if (canPop()) {
      _pages.removeLast();
      return true;
    }
    return false;
  }

  void push({required Widget page, String? name, Object? arguments}) {
    var routeSettings = RouteSettings(
        name: name ?? page.runtimeType.toString(), arguments: arguments);

    ///展示新界面
    _pages.add(MaterialPage(
        child: page,
        name: routeSettings.name,
        arguments: routeSettings.arguments,
        restorationId: page.hashCode.toString()));

    notifyListeners();
  }


  void replace({required Widget page, String? name, Object? arguments}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    push(page: page, name: name, arguments: arguments);
  }


/// 例子：
///   Future<bool> _confirmExit(BuildContext context) async {
///     final result = await showDialog<bool>(
///         context: context,
///         builder: (context) {
///           return AlertDialog(
///             content: const Text('确定要退出App吗?'),
///             actions: [
///               TextButton(
///                 child: const Text('取消'),
///                 onPressed: () => Navigator.pop(context, true),
///               ),
///               TextButton(
///                 child: const Text('确定'),
///                 onPressed: () => Navigator.pop(context, false),
///               ),
///             ],
///           );
///         });
///     return result ?? true;
///   }
}
