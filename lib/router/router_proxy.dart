import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';


///
/// create_user: zhengzaihong
/// Email:1096877329@qq.com
/// create_date: 2022-12-05
/// create_time: 09:12
/// describe 基于路由2.0实现界面跳转
///
typedef RoutePathCallBack = Widget? Function(RouteInformation routeInformation);
// typedef RoutePathCallBack = Future<void> Function(List<RouteSettings> configuration, List<Page> pages);

typedef ExitStyleCallBack = Future<bool> Function(BuildContext context);

// class RouterProxy extends RouterDelegate<List<RouteSettings>> with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<RouteSettings>> {

class RouterProxy extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {

  /// 可用于动态路由实现跳转
  RoutePathCallBack? routePathCallBack;

  /// 移动端退出程序时自定义页面的回调
  ExitStyleCallBack? exitStyleCallBack;

  /// 静态路由的页面
  Map? pageMap = {};

  /// 当前路由的名称 用web浏览器中
  String? _location;

  /// 具体的页面集
  final List<Page> _pages = [];

  static final _navigatorKey = GlobalKey<NavigatorState>();

  RouterProxy._({this.exitStyleCallBack, this.routePathCallBack, this.pageMap}) : super(){
    pageMap?.forEach((key, value) {
      _pages.add(MaterialPage(child: value));
    });
  }

  static RouterProxy? _instance;
  static RouterProxy getInstance(
      {RoutePathCallBack? routePathCallBack,
      ExitStyleCallBack? exitStyleCallBack,
      Map? pageMap}) {
    _instance ??= RouterProxy._(
        routePathCallBack: routePathCallBack,
        exitStyleCallBack: exitStyleCallBack,
        pageMap: pageMap);
    return _instance!;
  }

  CustomParser defaultParser() {
    return const CustomParser();
  }

  // @override
  // List<Page> get currentConfiguration => List.of(_pages);
  @override
  RouteInformation get currentConfiguration {
    return RouteInformation(location: _location ?? '/');
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

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

  void pop() async {
    if (canPop()) {
      _pages.removeLast();
    }
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    return popAndPushNamed(name: configuration.location ?? '/');
  }

  // @override
  // Future<void> setNewRoutePath(List<RouteSettings> configuration) {
  //   return routePathCallBack == null
  //       ? Future.value(null)
  //       : routePathCallBack!.call(configuration, _pages);
  // }

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

    ///外部可仿照传入 exitStyleCallBack 定制推出样式
    return exitStyleCallBack == null
        ? Future.value(false)
        : exitStyleCallBack!.call(navigatorKey.currentContext!);
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

  void pushNamedAndRemove(
      {required String name, Object? arguments, Widget? emptyPage}) {
    if (_pages.isNotEmpty) {
      _pages.clear();
    }
    pushNamed(name: name, arguments: arguments, emptyPage: emptyPage);
  }

  void popAndPushNamed(
      {required String name, Object? arguments, Widget? emptyPage}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    pushNamed(name: name, arguments: arguments, emptyPage: emptyPage);
  }

  void pushNamed({required String name,
    Object? arguments,
    Widget? emptyPage,
    bool custom = false
  }) {
    var page = pageMap?[name];
    _location = name;
    if (custom) {
      page = routePathCallBack?.call(RouteInformation(location: _location));
    }
    if (page == null) {
      _location = '404';
      page = emptyPage ?? const EmptyPage();
    }
    push(page: page, name: name, arguments: arguments);
  }


  void goRootPage() {
    _pages.clear();
    _location = '/';
    pushNamed(name: _location!);
  }

  List<Page> get pages => _pages;

  String? getLocation() {
    return _location;
  }

  set location(String value) {
    _location = value;
    popAndPushNamed(name:_location!);
  }

  /// exitStyleCallBack 例子：
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
