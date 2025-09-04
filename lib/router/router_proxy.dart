import 'dart:async';
import 'package:flutter/material.dart';

import 'custom_parser.dart';
import 'empty_page.dart';

///
/// create_user: zhengzaihong
/// Email:1096877329@qq.com
/// create_date: 2022-12-05
/// create_time: 09:12
/// describe 基于路由2.0实现界面跳转
///
typedef RoutePathCallBack = Widget? Function(RouteInformation routeInformation);

typedef ExitWindowStyle = Future<bool> Function(BuildContext context);

typedef NavigateToTargetCallBack = void Function(BuildContext context, Widget? page);

class RouterProxy extends RouterDelegate<RouteInformation> with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  /// 可用于动态路由实现跳转
  RoutePathCallBack? _routePathCallBack;

  /// 移动端退出程序时自定义页面的回调
  ExitWindowStyle? _exitWindowStyle;

  /// 特定页面跳转(非实际跳转)的回调, 例如切换底部Tab
  NavigateToTargetCallBack? _navigateToTargetCallBack;

  /// 静态路由的页面
  Map? pageMap = {};

  /// 当前路由的名称 用web浏览器中
  String? _location;

  /// 用于非页面跳转的目标页面队列
  final List<dynamic> _targetPageQueue = [];
  int _maxQueue = 30;

  /// 具体的页面集
  final List<MaterialPage> _pages = [];

  /// 通知特定的页面 ValueListenableBuilder
  ValueNotifier<Widget?> currentTargetPage = ValueNotifier(null);

  static final _navigatorKey = GlobalKey<NavigatorState>();

  RouterProxy._({
    ExitWindowStyle? exitWindowStyle,
    RoutePathCallBack? routePathCallBack,
    NavigateToTargetCallBack? navigateToTargetCallBack,
    this.pageMap,
    int maxQueue = 30,
  }) : super() {
    _exitWindowStyle = exitWindowStyle;
    _routePathCallBack = routePathCallBack;
    _navigateToTargetCallBack = navigateToTargetCallBack;
    _maxQueue = maxQueue;
    pageMap?.forEach((key, value) {
      _pages.add(MaterialPage(child: value));
    });
  }

  static RouterProxy? _instance;

  static RouterProxy getInstance(
      {RoutePathCallBack? routePathCallBack,
      ExitWindowStyle? exitWindowStyle,
      NavigateToTargetCallBack? navigateToTargetCallBack,
      Map? pageMap}) {
    _instance ??= RouterProxy._(
        routePathCallBack: routePathCallBack,
        exitWindowStyle: exitWindowStyle,
        navigateToTargetCallBack: navigateToTargetCallBack,
        pageMap: pageMap);
    return _instance!;
  }

  CustomParser defaultParser() {
    return const CustomParser();
  }

  @override
  RouteInformation get currentConfiguration {
    return RouteInformation(uri: Uri.parse(_location ?? '/'));
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  BuildContext? get _context => navigatorKey.currentContext;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: _onPopInvoked,
        child: Navigator(
          key: navigatorKey,
          pages: List.of(_pages),
          onPopPage: _onPopPage,
        ));
  }

  void _onPopInvoked(bool didPop) {
    // 当 canPop 为 false 时, didPop 总是 false.
    // 我们在此处手动处理返回手势.
    if (!didPop) {
      popRoute();
    }
  }

  void pop() async {
    if (canPop()) {
      _pages.removeLast();
    }
    notify();
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    return popAndPushNamed(name: configuration.uri.toString());
  }

  @override
  Future<bool> popRoute() async {
    // 首先检查当前的Navigator是否可以pop（例如，一个对话框或底部面板）
    if (Navigator.of(navigatorKey.currentContext!).canPop()) {
      Navigator.of(navigatorKey.currentContext!).pop();
      return Future.value(true);
    }
    // 如果不行，则尝试从我们自己的页面栈中pop一个页面
    if (canPop()) {
      _pages.removeLast();
      notify();
      return Future.value(true);
    }

    /// 如果页面栈也不能pop，则执行自定义的退出逻辑
    return _exitWindowStyle == null
        ? Future.value(false)
        : _exitWindowStyle!.call(navigatorKey.currentContext!);
  }

  /// 检查页面栈是否可以pop
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

  /// 推出一个新页面到导航栈
  void push(
      {required Widget page,
      String? name,
      Object? arguments,
      String? restorationId}) {
    var routeSettings = RouteSettings(
        name: name ?? page.runtimeType.toString(), arguments: arguments);

    _pages.add(MaterialPage(
        child: page,
        name: routeSettings.name,
        arguments: routeSettings.arguments,
        restorationId: restorationId));

    notify();
  }

  /// 获取当前显示的页面Widget
  Widget getCurrentPage() {
    return (_pages.last).child;
  }

  /// 获取当前显示页面的MaterialPage对象，可用于获取参数
  MaterialPage getCurrentMaterialPage() {
    return (_pages.last);
  }

  /// 关闭当前页面，并附带返回值
  ///
  /// 示例:
  /// RouterProxy.getInstance().popWithResult('从页面返回的数据');
  void popWithResult<T>([T? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop(result);
    }
  }

  /// 显示一个通用的对话框(Dialog)
  ///
  /// 示例:
  /// RouterProxy.getInstance().showAppDialog(
  ///   builder: (context) => AlertDialog(
  ///     title: Text('提示'),
  ///     content: Text('这是一个通过路由服务显示的对话框。'),
  ///     actions: <Widget>[
  ///       TextButton(
  ///         child: Text('确定'),
  ///         onPressed: () => Navigator.of(context).pop(),
  ///       ),
  ///     ],
  ///   ),
  /// );
  Future<T?> showAppDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
  }) {
    if (_context == null) return Future.value(null);
    return showDialog<T>(
      context: _context!,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
    );
  }

  /// 显示一个通用的模态底部面板(Modal Bottom Sheet)
  ///
  /// 示例:
  /// RouterProxy.getInstance().showAppBottomSheet(
  ///   builder: (context) => Container(
  ///     height: 200,
  ///     child: Center(child: Text('这是一个底部面板')),
  ///   ),
  /// );
  Future<T?> showAppBottomSheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
  }) {
    if (_context == null) return Future.value(null);
    return showModalBottomSheet<T>(
      context: _context!,
      builder: builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      routeSettings: routeSettings,
      transitionAnimationController: transitionAnimationController,
      anchorPoint: anchorPoint,
      isScrollControlled: isScrollControlled,
    );
  }

  /// 显示一个提示条(SnackBar)
  ///
  /// 示例:
  /// RouterProxy.getInstance().showAppSnackBar(message: '这是一个提示！');
  void showAppSnackBar({required String message}) {
    if (_context == null) return;
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(_context!).showSnackBar(snackBar);
  }

  /// 替换当前页面
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

  /// 跳转到指定页面，并清空之前的所有页面
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

  /// pop当前页面，然后push一个新页面
  void popAndPushNamed(
      {required String name, Object? arguments, Widget? emptyPage}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    pushNamed(name: name, arguments: arguments, emptyPage: emptyPage);
  }

  /// 根据名称跳转页面
  void pushNamed(
      {required String name,
      Object? arguments,
      Widget? emptyPage,
      bool custom = false,
      String? restorationId}) {
    var page = pageMap?[name];
    _location = name;
    if (custom) {
      page = _routePathCallBack
          ?.call(RouteInformation(uri: Uri.parse(_location!)));
    }
    if (page == null) {
      _location = '404';
      page = emptyPage ?? const EmptyPage();
    }
    push(
        page: page,
        name: name,
        arguments: arguments,
        restorationId: restorationId);
  }

  /// 回到根页面
  void goRootPage() {
    _pages.clear();
    _location = '/';
    pushNamed(name: _location!);
  }

  /// 清空页面栈并push新页面
  void pushAndRemoveUntil(Widget page) {
    pages.clear();
    push(page: page);
  }

  /// 将页面置于栈顶（如果已存在则先移除）
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

  /// 非页面跳转，只切换到目标页面 (例如主页的Tab切换)
  void goToTarget(Widget page, {bool insert = true}) {
    _navigateToTargetCallBack?.call(navigatorKey.currentContext!, page);
    if (insert) {
      // 避免重复添加
      if (_targetPageQueue.isNotEmpty &&
          _targetPageQueue.last.runtimeType == page.runtimeType) return;
      _targetPageQueue.add(page);
    }
    if (_targetPageQueue.length > _maxQueue) {
      _targetPageQueue.removeAt(0);
    }
  }

  /// 返回到上一个非页面跳转的目标
  void backTarget() {
    // Pop当前的目标
    if (_targetPageQueue.isNotEmpty) {
      _targetPageQueue.removeLast();
    }

    // 获取新的目标，如果队列为空则为null
    final Widget? targetPage =
        _targetPageQueue.isNotEmpty ? _targetPageQueue.last : null;

    _navigateToTargetCallBack?.call(navigatorKey.currentContext!, targetPage);
  }

  /// 清空所有非页面跳转的目标
  void clearTargets() {
    _targetPageQueue.clear();
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
