import 'dart:async';
import 'package:flutter/material.dart';

///
/// author:郑再红
/// email:1096877329@qq.com
/// date: 2025/2/6
/// time: 15:26
/// describe: 基于 router_pro 路由
/// 
/// ⚠️ 废弃警告：此类将在未来版本中删除
/// 
/// 请使用新的抽屉路由栈实现方式：
/// 
/// ```dart
/// // 旧方式（将被删除）
/// final drawerRouter = DrawerRouter.getInstance();
/// 
/// // 新方式（推荐）
/// final drawerRouter = RouterProxy.getDrawerInstance(
///   stackId: 'main-drawer',
///   pageMap: {'/': DrawerHomePage()},
///   drawerConfig: DrawerConfig(
///     autoOpen: true,
///     autoClose: true,
///     isEndDrawer: true,
///   ),
/// );
/// 
/// // 使用封装 Widget（自动处理绑定和刷新）
/// Scaffold(
///   endDrawer: SimpleDrawerWidget(
///     router: drawerRouter,
///     width: 300,
///   ),
/// );
/// 
/// // 路由操作
/// drawerRouter.push(page: SettingsPage());
/// drawerRouter.pop();
/// ```
/// 
/// 查看完整文档：DRAWER_ROUTER_USAGE.md

@Deprecated('Use RouterProxy.getDrawerInstance() instead. This class will be removed in future versions.')
class DrawerRouter extends RouterDelegate<RouteInformation> with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {

  Map? pageMap = {};

  String? _location;

  BuildContext? drawerNavigatorContextContext;

  final List<MaterialPage> _pages = [];

  static final _navigatorKey = GlobalKey<NavigatorState>();

  DrawerRouter._({
    this.pageMap,
  }) : super() {
    pageMap?.forEach((key, value) {
      _pages.add(MaterialPage(child: value));
    });
  }

  // 非单例
  // static DrawerRouter? _instance;
  static DrawerRouter getInstance({Map? pageMap}) {
    // _instance ??= DrawerRouter._(pageMap: pageMap);
    // return _instance!;
    return DrawerRouter._(pageMap: pageMap);
  }

  @override
  RouteInformation get currentConfiguration {
    return RouteInformation(uri: Uri.parse(_location ?? '/'));
  }


  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  void bindDrawerNavigatorContext(BuildContext context) {
    drawerNavigatorContextContext = context;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: _onPopInvokedWithResult,
        child: Navigator(
          key: navigatorKey,
          pages: List.of(_pages),
          onPopPage: _onPopPage,
        ));
  }

  void _onPopInvokedWithResult(bool didPop, dynamic result) {
    // 当 canPop 为 false 时, didPop 总是 false.
    // 我们在此处手动处理返回手势.
    if (!didPop) {
      popRoute();
    }
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    return popAndPushNamed(name: configuration.uri.toString());
  }


  @override
  Future<bool> popRoute() async {
    if (Navigator.of(navigatorKey.currentContext!).canPop()) {
      Navigator.of(navigatorKey.currentContext!).pop();
      return Future.value(true);
    }
    if (canPop()) {
      _pages.removeLast();
      notify();
      return Future.value(true);
    }
    return Future.value(false);
  }

  bool canPop() => _pages.isNotEmpty;

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

  void pop({bool closeDrawer = false,bool endDrawer = true}) async {
    if (canPop()) {
      _pages.removeLast();
    }
    if (_pages.isEmpty && closeDrawer  && drawerNavigatorContextContext != null) {
      if(endDrawer){
        if(Scaffold.of(drawerNavigatorContextContext!).isEndDrawerOpen){
          Scaffold.of(drawerNavigatorContextContext!).closeEndDrawer();
        }
      }else{
        if(Scaffold.of(drawerNavigatorContextContext!).isDrawerOpen){
          Scaffold.of(drawerNavigatorContextContext!).closeDrawer();
        }
      }
    }
    notify();
  }
  void push(
      {required Widget page,
      bool openDrawer = true,
      bool endDrawer = true,
      String? name,
      Object? arguments,
      String? restorationId}) {
    var routeSettings = RouteSettings(
        name: name ?? page.runtimeType.toString(), arguments: arguments);

    if(_pages.isEmpty && openDrawer && drawerNavigatorContextContext != null){
      if(endDrawer){
        if(!Scaffold.of(drawerNavigatorContextContext!).isEndDrawerOpen){
          Scaffold.of(drawerNavigatorContextContext!).openEndDrawer();
        }
      }else{
        if(!Scaffold.of(drawerNavigatorContextContext!).isDrawerOpen){
          Scaffold.of(drawerNavigatorContextContext!).openDrawer();
        }
      }
    }
    ///展示新界面
    _pages.add(MaterialPage(
        child: page,
        name: routeSettings.name,
        arguments: routeSettings.arguments,
        restorationId: restorationId));

    notify();
  }

  void openDrawer(){
    if(!Scaffold.of(drawerNavigatorContextContext!).isDrawerOpen){
      Scaffold.of(drawerNavigatorContextContext!).openDrawer();
    }
  }
  void openEndDrawer(){
    if(!Scaffold.of(drawerNavigatorContextContext!).isEndDrawerOpen){
      Scaffold.of(drawerNavigatorContextContext!).openEndDrawer();
    }
  }
  void closeDrawer(){
    if(Scaffold.of(drawerNavigatorContextContext!).isDrawerOpen){
      Scaffold.of(drawerNavigatorContextContext!).closeDrawer();
    }
  }
  void closeEndDrawer(){
    if(Scaffold.of(drawerNavigatorContextContext!).isEndDrawerOpen){
      Scaffold.of(drawerNavigatorContextContext!).closeEndDrawer();
    }
  }

  Widget getCurrentPage() {
    return (_pages.last).child;
  }

  //获取 参数：arguments时使用
  MaterialPage getCurrentMaterialPage() {
    return (_pages.last);
  }

  void replace(
      {required Widget page,
      String? name,
      Object? arguments,
      String? restorationId}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    push(
        page: page,
        name: name,
        arguments: arguments,
        restorationId: restorationId);
  }

  void pushNamedAndRemove(
      {required String name,
      Object? arguments,
      Widget? emptyPage,
      String? restorationId}) {
    if (_pages.isNotEmpty) {
      _pages.clear();
    }
    pushNamed(
        name: name,
        arguments: arguments,
        emptyPage: emptyPage,
        restorationId: restorationId);
  }

  void popAndPushNamed(
      {required String name, Object? arguments, Widget? emptyPage}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    pushNamed(name: name, arguments: arguments, emptyPage: emptyPage);
  }

  void pushNamed(
      {required String name,
      Object? arguments,
      Widget? emptyPage,
      String? restorationId}) {
    var page = pageMap?[name];
    _location = name;
    if (page == null) {
      _location = '404';
      page = emptyPage ?? const Center(child: Text('404'));
    }
    push(
        page: page,
        name: name,
        arguments: arguments,
        restorationId: restorationId);
  }

  void goRootPage() {
    _pages.clear();
    _location = '/';
    pushNamed(name: _location!);
  }

  void pushAndRemoveUntil(Widget page) {
    pages.clear();
    push(page: page);
  }

  //栈顶跳转
  void pushStackTop({required Widget page}) {
    if (_pages.isNotEmpty) {
      _pages.removeWhere(
          (element) => element.child.runtimeType == page.runtimeType);
    }
    push(page: page);
  }

  List<MaterialPage> get pages => _pages;

  String? getLocation() {
    return _location;
  }

  set location(String value) {
    _location = value;
    popAndPushNamed(name: _location!);
  }

  void notify() {
    notifyListeners();
  }
}
