import 'dart:async';
import 'package:flutter/material.dart';

import 'custom_parser.dart';
import 'empty_page.dart';
import 'drawer_config.dart';

///
/// author:郑再红
/// email:1096877329@qq.com
/// date: 2022-12-05
/// time: 09:12
/// describe 基于路由2.0实现界面跳转
/// 支持1.0中的路由传值，回传取值
/// 支持多路由栈架构（主路由栈 + 抽屉路由栈）
///
///
// ============ 主路由栈使用示例 ============
//
// void initRouter() {
//   router = RouterProxy.getInstance(
//     pageMap: {
//       '/': const HomePage(),
//       '/login': const LoginPage(),
//       '/profile': const ProfilePage(),
//     },
//     notFoundPage: const NotFoundPage(),
//     exitWindowStyle: _confirmExit,
//   );
//
//   // 添加命名路由守卫
//   router.addRouteGuard((from, to) async {
//     final protectedRoutes = ['/profile'];
//     if (protectedRoutes.contains(to.uri.toString()) && !_isLoggedIn) {
//       router.pushNamed(name: '/login');
//       return false;
//     }
//     return true;
//   });
//
//   // 添加页面类型守卫
//   router.addPageTypeGuard((fromPageType, toPageType) async {
//     final protectedPageTypes = [ProfilePage];
//     if (protectedPageTypes.contains(toPageType) && !_isLoggedIn) {
//       router.pushNamed(name: '/login');
//       return false;
//     }
//     return true;
//   });
// }
//
// MaterialApp.router(
//   routerDelegate: router,
//   routeInformationParser: router.defaultParser(),
// );
//
// ============ 抽屉路由栈使用示例 ============
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   late final RouterProxy drawerRouter;
//
//   @override
//   void initState() {
//     super.initState();
//     
//     // 创建抽屉路由实例
//     drawerRouter = RouterProxy.getDrawerInstance(
//       stackId: 'main-drawer',
//       pageMap: {
//         '/': DrawerHomePage(),
//         '/settings': DrawerSettingsPage(),
//       },
//       drawerConfig: DrawerConfig(
//         autoOpen: true,   // 首次 push 时自动打开抽屉
//         autoClose: true,  // 栈为空时自动关闭抽屉
//         isEndDrawer: true, // 右侧抽屉
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     // 清理资源
//     RouterProxy.removeDrawerInstance('main-drawer');
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('主页')),
//       // 使用 SimpleDrawerWidget，自动处理 context 绑定和刷新
//       endDrawer: SimpleDrawerWidget(
//         router: drawerRouter,
//         width: 300,
//       ),
//       body: ElevatedButton(
//         onPressed: () {
//           // 打开抽屉并跳转到设置页
//           drawerRouter.pushNamed(name: '/settings');
//         },
//         child: Text('打开抽屉设置'),
//       ),
//     );
//   }
// }
//
// // 抽屉内的页面
// class DrawerHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
//     
//     return Column(
//       children: [
//         AppBar(
//           title: Text('抽屉菜单'),
//           actions: [
//             IconButton(
//               icon: Icon(Icons.close),
//               onPressed: () => drawerRouter.closeDrawerStack(),
//             ),
//           ],
//         ),
//         ListTile(
//           leading: Icon(Icons.settings),
//           title: Text('设置'),
//           onTap: () => drawerRouter.push(page: DrawerSettingsPage()),
//         ),
//       ],
//     );
//   }
// }
//
// ============ 抽屉路由栈特性 ============
//
// 1. 自动刷新：push/pop 时自动更新抽屉显示
// 2. 自动绑定：SimpleDrawerWidget 自动处理 context 绑定
// 3. 完整功能：支持路由守卫、启动模式、值回传等
// 4. 多实例：可创建多个独立的抽屉路由栈
//
// 三种封装 Widget：
// - SimpleDrawerWidget：最简单，推荐使用
// - StyledDrawerWidget：支持自定义样式
// - DrawerRouterWidget：完全自定义子组件
//
// 查看完整文档：DRAWER_ROUTER_USAGE.md
//
// ============ exitWindowStyle 示例 ============
//
//   Future<bool> _confirmExit(BuildContext context) async {
//     final result = await showDialog<bool>(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             content: const Text('确定要退出App吗?'),
//             actions: [
//               TextButton(
//                 child: const Text('取消'),
//                 onPressed: () => Navigator.pop(context, true),
//               ),
//               TextButton(
//                 child: const Text('确定'),
//                 onPressed: () => Navigator.pop(context, false),
//               ),
//             ],
//           );
//         });
//     return result ?? true;
//   }

typedef RoutePathCallBack = Widget? Function(RouteInformation routeInformation);
typedef ExitWindowStyle = Future<bool> Function(BuildContext context);
typedef NavigateToTargetCallBack = void Function(BuildContext context, Widget? page);
typedef ResultCallBack = void Function(dynamic result);
typedef RouteGuard = Future<bool> Function(RouteInformation from, RouteInformation to);
typedef PageTypeGuard = Future<bool> Function(Type? fromPageType, Type toPageType);

/// 路由启动模式
enum LaunchMode {
  /// 标准模式：允许同一页面多个实例存在
  standard,
  /// 栈顶复用：如果目标页面已在栈顶，则不创建新实例
  singleTop,
  /// 单例模式：整个栈中只保留一个实例，如果已存在则移到栈顶
  singleInstance,
}

class RouterProxy extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  
  // ========== 静态管理 ==========
  
  /// 主路由实例（单例）
  static RouterProxy? _mainInstance;
  
  /// 抽屉路由栈实例（多实例，按 stackId 管理）
  static final Map<String, RouterProxy> _drawerInstances = {};
  
  // ========== 实例属性 ==========
  
  /// 路由栈标识
  final String stackId;
  
  /// 是否为主路由栈
  final bool isMainStack;
  
  /// 是否为抽屉路由栈
  final bool isDrawerStack;
  
  /// NavigatorKey（每个栈独立）
  final GlobalKey<NavigatorState> _navigatorKey;
  
  /// 抽屉配置（仅用于抽屉栈）
  DrawerConfig? _drawerConfig;
  
  /// 抽屉上下文（仅用于抽屉栈）
  /// 注意：这是 Scaffold 子组件的 context，不是根 context
  BuildContext? _drawerContext;
  
  /// 可用于动态路由实现跳转
  RoutePathCallBack? _routePathCallBack;

  /// 移动端退出程序时自定义页面的回调（仅用于主路由栈）
  ExitWindowStyle? _exitWindowStyle;

  /// 特定页面跳转(非实际跳转)的回调, 例如切换底部Tab（仅用于主路由栈）
  NavigateToTargetCallBack? _navigateToTargetCallBack;

  /// 路由导航守卫
  final List<RouteGuard> _routeGuards = [];
  
  /// 页面类型导航守卫
  final List<PageTypeGuard> _pageTypeGuards = [];

  /// 静态路由的页面
  Map? pageMap = {};

  /// 当前路由的名称 用web浏览器中
  String? _location;

  /// 用于非页面跳转的目标页面队列（仅用于主路由栈）
  final List<dynamic> _targetPageQueue = [];
  int _maxQueue = 30;

  /// 具体的页面集
  final List<MaterialPage> _pages = [];
  final Map<int,ResultCallBack?> _result = {};

  /// 通知特定的页面 ValueListenableBuilder（仅用于主路由栈）
  ValueNotifier<Widget?> currentTargetPage = ValueNotifier(null);

  /// 404错误页面
  Widget? _notFoundPage;

  RouterProxy._({
    required this.stackId,
    this.isMainStack = false,
    this.isDrawerStack = false,
    DrawerConfig? drawerConfig,
    ExitWindowStyle? exitWindowStyle,
    RoutePathCallBack? routePathCallBack,
    NavigateToTargetCallBack? navigateToTargetCallBack,
    this.pageMap,
    int maxQueue = 30,
    Widget? notFoundPage,
  }) : _navigatorKey = GlobalKey<NavigatorState>(debugLabel: stackId),
       _drawerConfig = drawerConfig,
       super() {
    _exitWindowStyle = exitWindowStyle;
    _routePathCallBack = routePathCallBack;
    _navigateToTargetCallBack = navigateToTargetCallBack;
    _maxQueue = maxQueue;
    _notFoundPage = notFoundPage;
    pageMap?.forEach((key, value) {
      _pages.add(MaterialPage(child: value));
    });
  }

  /// 获取主路由实例（单例）
  /// 
  /// 用于应用的主路由导航
  /// 
  /// 示例：
  /// ```dart
  /// final router = RouterProxy.getInstance(
  ///   pageMap: {'/': HomePage()},
  /// );
  /// 
  /// MaterialApp.router(
  ///   routerDelegate: router,
  ///   routeInformationParser: router.defaultParser(),
  /// );
  /// ```
  static RouterProxy getInstance({
    RoutePathCallBack? routePathCallBack,
    ExitWindowStyle? exitWindowStyle,
    NavigateToTargetCallBack? navigateToTargetCallBack,
    Map? pageMap,
    Widget? notFoundPage,
  }) {
    _mainInstance ??= RouterProxy._(
      stackId: 'main',
      isMainStack: true,
      isDrawerStack: false,
      routePathCallBack: routePathCallBack,
      exitWindowStyle: exitWindowStyle,
      navigateToTargetCallBack: navigateToTargetCallBack,
      pageMap: pageMap,
      notFoundPage: notFoundPage,
    );
    return _mainInstance!;
  }

  /// 获取抽屉路由实例（多实例）
  /// 
  /// 用于管理抽屉内的路由栈，支持多个独立的抽屉路由栈
  /// 
  /// 参数：
  /// - [stackId]: 路由栈标识，用于区分不同的抽屉路由栈
  /// - [pageMap]: 静态路由映射
  /// - [drawerConfig]: 抽屉配置
  /// 
  /// 示例：
  /// ```dart
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
  /// Scaffold(
  ///   endDrawer: Container(
  ///     width: 300,
  ///     child: drawerRouter.build(context),
  ///   ),
  /// );
  /// 
  /// // 绑定 Scaffold 的 context（重要！）
  /// drawerRouter.bindDrawerContext(context);
  /// 
  /// // 使用
  /// drawerRouter.push(page: SettingsPage());
  /// ```
  static RouterProxy getDrawerInstance({
    required String stackId,
    Map? pageMap,
    DrawerConfig? drawerConfig,
  }) {
    if (!_drawerInstances.containsKey(stackId)) {
      _drawerInstances[stackId] = RouterProxy._(
        stackId: stackId,
        isMainStack: false,
        isDrawerStack: true,
        pageMap: pageMap,
        drawerConfig: drawerConfig ?? const DrawerConfig(),
      );
    }
    return _drawerInstances[stackId]!;
  }

  /// 移除抽屉路由实例
  /// 
  /// 当不再需要某个抽屉路由栈时，调用此方法释放资源
  static void removeDrawerInstance(String stackId) {
    final instance = _drawerInstances[stackId];
    if (instance != null) {
      instance.dispose();
      _drawerInstances.remove(stackId);
    }
  }

  /// 获取所有抽屉路由实例
  static Map<String, RouterProxy> getAllDrawerInstances() {
    return Map.unmodifiable(_drawerInstances);
  }

  CustomParser defaultParser() {
    return const CustomParser();
  }

  // ========== 抽屉相关方法（仅用于抽屉栈）==========
  
  /// 绑定抽屉上下文（仅抽屉路由栈可用）
  /// 
  /// 重要：必须传入 Scaffold 子组件的 context，不是根 context
  /// 
  /// 示例：
  /// ```dart
  /// Scaffold(
  ///   endDrawer: Builder(
  ///     builder: (context) {
  ///       // 在这里绑定 context
  ///       drawerRouter.bindDrawerContext(context);
  ///       return Container(
  ///         width: 300,
  ///         child: drawerRouter.build(context),
  ///       );
  ///     },
  ///   ),
  /// );
  /// ```
  void bindDrawerContext(BuildContext context) {
    if (isDrawerStack) {
      _drawerContext = context;
    } else {
      debugPrint('Warning: bindDrawerContext() should only be called on drawer stack');
    }
  }

  /// 配置抽屉行为（仅抽屉路由栈可用）
  /// 
  /// 可以在运行时修改抽屉配置
  void configureDrawer(DrawerConfig config) {
    if (isDrawerStack) {
      _drawerConfig = config;
    } else {
      debugPrint('Warning: configureDrawer() should only be called on drawer stack');
    }
  }

  /// 获取当前抽屉配置（仅抽屉路由栈可用）
  DrawerConfig? get drawerConfig => _drawerConfig;

  /// 打开抽屉（仅抽屉路由栈可用）
  /// 
  /// 手动打开抽屉，通常在自动打开被禁用时使用
  /// 
  /// 示例：
  /// ```dart
  /// final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
  /// drawerRouter.openDrawerStack();
  /// ```
  void openDrawerStack() {
    if (!isDrawerStack) {
      debugPrint('Warning: openDrawerStack() should only be called on drawer stack');
      return;
    }
    
    if (_drawerContext == null) {
      debugPrint('Warning: Drawer context not bound. Call bindDrawerContext() first.');
      return;
    }

    try {
      if (_drawerConfig!.isEndDrawer) {
        if (!Scaffold.of(_drawerContext!).isEndDrawerOpen) {
          Scaffold.of(_drawerContext!).openEndDrawer();
        }
      } else {
        if (!Scaffold.of(_drawerContext!).isDrawerOpen) {
          Scaffold.of(_drawerContext!).openDrawer();
        }
      }
    } catch (e) {
      debugPrint('Error opening drawer: $e');
    }
  }

  /// 关闭抽屉（仅抽屉路由栈可用）
  /// 
  /// 手动关闭抽屉，通常在自动关闭被禁用时使用
  /// 
  /// 示例：
  /// ```dart
  /// final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
  /// drawerRouter.closeDrawerStack();
  /// ```
  void closeDrawerStack() {
    if (!isDrawerStack) {
      debugPrint('Warning: closeDrawerStack() should only be called on drawer stack');
      return;
    }
    
    if (_drawerContext == null) {
      debugPrint('Warning: Drawer context not bound. Call bindDrawerContext() first.');
      return;
    }

    try {
      if (_drawerConfig!.isEndDrawer) {
        if (Scaffold.of(_drawerContext!).isEndDrawerOpen) {
          Scaffold.of(_drawerContext!).closeEndDrawer();
        }
      } else {
        if (Scaffold.of(_drawerContext!).isDrawerOpen) {
          Scaffold.of(_drawerContext!).closeDrawer();
        }
      }
    } catch (e) {
      debugPrint('Error closing drawer: $e');
    }
  }

  /// 检查抽屉是否打开（仅抽屉路由栈可用）
  bool get isDrawerStackOpen {
    if (!isDrawerStack || _drawerContext == null) return false;
    
    try {
      if (_drawerConfig!.isEndDrawer) {
        return Scaffold.of(_drawerContext!).isEndDrawerOpen;
      } else {
        return Scaffold.of(_drawerContext!).isDrawerOpen;
      }
    } catch (e) {
      return false;
    }
  }

  // ========== 主路由栈的抽屉控制方法 ==========
  
  /// 打开主页面的抽屉（主路由栈可用）
  /// 
  /// 用于主路由栈控制 Scaffold 的抽屉
  /// 
  /// 参数：
  /// - [isEndDrawer]: true 表示右侧抽屉，false 表示左侧抽屉
  /// 
  /// 示例：
  /// ```dart
  /// final router = RouterProxy.getInstance();
  /// router.openMainDrawer(isEndDrawer: true); // 打开右侧抽屉
  /// router.openMainDrawer(isEndDrawer: false); // 打开左侧抽屉
  /// ```
  void openMainDrawer({bool isEndDrawer = false}) {
    if (!isMainStack) {
      debugPrint('Warning: openMainDrawer() should only be called on main stack');
      return;
    }
    
    if (_context == null) {
      debugPrint('Warning: Context not available');
      return;
    }

    try {
      if (isEndDrawer) {
        if (!Scaffold.of(_context!).isEndDrawerOpen) {
          Scaffold.of(_context!).openEndDrawer();
        }
      } else {
        if (!Scaffold.of(_context!).isDrawerOpen) {
          Scaffold.of(_context!).openDrawer();
        }
      }
    } catch (e) {
      debugPrint('Error opening main drawer: $e');
    }
  }

  /// 关闭主页面的抽屉（主路由栈可用）
  /// 
  /// 用于主路由栈控制 Scaffold 的抽屉
  /// 
  /// 参数：
  /// - [isEndDrawer]: true 表示右侧抽屉，false 表示左侧抽屉
  /// 
  /// 示例：
  /// ```dart
  /// final router = RouterProxy.getInstance();
  /// router.closeMainDrawer(isEndDrawer: true); // 关闭右侧抽屉
  /// router.closeMainDrawer(isEndDrawer: false); // 关闭左侧抽屉
  /// ```
  void closeMainDrawer({bool isEndDrawer = false}) {
    if (!isMainStack) {
      debugPrint('Warning: closeMainDrawer() should only be called on main stack');
      return;
    }
    
    if (_context == null) {
      debugPrint('Warning: Context not available');
      return;
    }

    try {
      if (isEndDrawer) {
        if (Scaffold.of(_context!).isEndDrawerOpen) {
          Scaffold.of(_context!).closeEndDrawer();
        }
      } else {
        if (Scaffold.of(_context!).isDrawerOpen) {
          Scaffold.of(_context!).closeDrawer();
        }
      }
    } catch (e) {
      debugPrint('Error closing main drawer: $e');
    }
  }

  /// 检查主页面的抽屉是否打开（主路由栈可用）
  /// 
  /// 参数：
  /// - [isEndDrawer]: true 表示检查右侧抽屉，false 表示检查左侧抽屉
  /// 
  /// 示例：
  /// ```dart
  /// final router = RouterProxy.getInstance();
  /// if (router.isMainDrawerOpen(isEndDrawer: true)) {
  ///   print('右侧抽屉已打开');
  /// }
  /// ```
  bool isMainDrawerOpen({bool isEndDrawer = false}) {
    if (!isMainStack || _context == null) return false;
    
    try {
      if (isEndDrawer) {
        return Scaffold.of(_context!).isEndDrawerOpen;
      } else {
        return Scaffold.of(_context!).isDrawerOpen;
      }
    } catch (e) {
      return false;
    }
  }

  /// 添加路由守卫
  /// 守卫会在路由跳转前执行，返回true允许跳转，false拦截跳转
  void addRouteGuard(RouteGuard guard) {
    _routeGuards.add(guard);
  }

  /// 移除路由守卫
  void removeRouteGuard(RouteGuard guard) {
    _routeGuards.remove(guard);
  }

  /// 清空所有路由守卫
  void clearRouteGuards() {
    _routeGuards.clear();
  }
  
  /// 添加页面类型守卫
  /// 用于 push(page: xxx) 方式的导航守卫
  /// 守卫会在路由跳转前执行，返回true允许跳转，false拦截跳转
  void addPageTypeGuard(PageTypeGuard guard) {
    _pageTypeGuards.add(guard);
  }

  /// 移除页面类型守卫
  void removePageTypeGuard(PageTypeGuard guard) {
    _pageTypeGuards.remove(guard);
  }

  /// 清空所有页面类型守卫
  void clearPageTypeGuards() {
    _pageTypeGuards.clear();
  }

  /// 执行路由守卫检查
  Future<bool> _checkRouteGuards(RouteInformation from, RouteInformation to) async {
    for (var guard in _routeGuards) {
      final result = await guard(from, to);
      if (!result) {
        return false;
      }
    }
    return true;
  }
  
  /// 执行页面类型守卫检查
  Future<bool> _checkPageTypeGuards(Type? fromPageType, Type toPageType) async {
    for (var guard in _pageTypeGuards) {
      final result = await guard(fromPageType, toPageType);
      if (!result) {
        return false;
      }
    }
    return true;
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
    // 抽屉路由栈也需要返回 Navigator，但不需要 PopScope
    if (isDrawerStack) {
      return Navigator(
        key: navigatorKey,
        pages: _pages.isEmpty ? [MaterialPage(child: const SizedBox.shrink())] : List.of(_pages),
        onDidRemovePage: _onDidRemovePage,
      );
    }
    
    // 主路由栈返回完整的 Navigator with PopScope
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: _onPopInvokedWithResult,
        child: Navigator(
          key: navigatorKey,
          pages: List.of(_pages),
          onDidRemovePage: _onDidRemovePage,
        ));
  }

  void _onPopInvokedWithResult(bool didPop, dynamic result) {
    // 当 canPop 为 false 时, didPop 总是 false.
    // 我们在此处手动处理返回手势.
    if (!didPop) {
      popRoute();
    }
  }

  void _onDidRemovePage(Page page) {
    // 页面被移除时的回调（通知性质，不需要返回值）
    // 这里不需要做任何操作，因为我们在 pop() 方法中已经处理了页面移除
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
      _popAndOnResult(null);
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

  /// 推出一个新页面到导航栈
  Future<void> push<T>(
      {required Widget page,
      ResultCallBack? onResult,
      String? name,
      Object? arguments,
      String? restorationId,
      bool maintainState = true,
      bool fullscreenDialog = false,
      bool allowSnapshotting = true,
      LaunchMode launchMode = LaunchMode.standard}) async {
    
    // 抽屉栈：首次 push 时自动打开抽屉
    if (isDrawerStack && _pages.isEmpty && _drawerConfig?.autoOpen == true) {
      openDrawerStack();
    }
    
    // 执行路由守卫检查（基于路由名称）
    final from = RouteInformation(uri: Uri.parse(_location ?? '/'));
    final to = RouteInformation(uri: Uri.parse(name ?? page.runtimeType.toString()));
    final canNavigate = await _checkRouteGuards(from, to);
    if (!canNavigate) {
      return;
    }
    
    // 执行页面类型守卫检查
    final fromPageType = _pages.isNotEmpty ? _pages.last.child.runtimeType : null;
    final toPageType = page.runtimeType;
    final canNavigateByType = await _checkPageTypeGuards(fromPageType, toPageType);
    if (!canNavigateByType) {
      return;
    }

    final routeSettings = RouteSettings(
        name: name ?? page.runtimeType.toString(), arguments: arguments);
    
    // 处理启动模式
    switch (launchMode) {
      case LaunchMode.singleTop:
        // 如果栈顶已是该页面类型，则更新参数而不创建新实例（类似Android的onNewIntent）
        if (_pages.isNotEmpty && 
            _pages.last.child.runtimeType == page.runtimeType) {
          // 更新栈顶页面的参数
          final lastPage = _pages.removeLast();
          _result.remove(lastPage.hashCode);
          
          final updatedPage = MaterialPage(
              child: page,
              name: routeSettings.name,
              arguments: routeSettings.arguments,
              restorationId: restorationId,
              maintainState: maintainState,
              fullscreenDialog: fullscreenDialog,
              allowSnapshotting: allowSnapshotting);
          _pages.add(updatedPage);
          _result[updatedPage.hashCode] = onResult;
          notify();
          return;
        }
        break;
      case LaunchMode.singleInstance:
        // 如果栈中已存在该页面，清除它上面的所有页面，并更新参数（类似Android的onNewIntent）
        final existingIndex = _pages.indexWhere(
            (element) => element.child.runtimeType == page.runtimeType);
        
        if (existingIndex != -1) {
          // 找到已存在的页面
          // 1. 清除该页面上面的所有页面
          final pagesToRemove = _pages.sublist(existingIndex);
          for (var pageToRemove in pagesToRemove) {
            _result.remove(pageToRemove.hashCode);
          }
          _pages.removeRange(existingIndex, _pages.length);
          
          // 2. 用新参数重新创建该页面（类似onNewIntent）
          final updatedPage = MaterialPage(
              child: page,
              name: routeSettings.name,
              arguments: routeSettings.arguments,
              restorationId: restorationId,
              maintainState: maintainState,
              fullscreenDialog: fullscreenDialog,
              allowSnapshotting: allowSnapshotting);
          _pages.add(updatedPage);
          _result[updatedPage.hashCode] = onResult;
          notify();
          return;
        }
        // 如果不存在，继续执行后面的代码创建新实例
        break;
      case LaunchMode.standard:
        // 标准模式，不做特殊处理
        break;
    }

    final target = MaterialPage(
        child: page,
        name: routeSettings.name,
        arguments: routeSettings.arguments,
        restorationId: restorationId,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        allowSnapshotting: allowSnapshotting);
    _pages.add(target);
    _result[target.hashCode] = onResult;
    notify();
  }

  /// 获取当前显示的页面Widget
  Widget getCurrentPage()=>_pages.last.child;

  /// 获取当前显示页面的MaterialPage对象，可用于获取参数
  MaterialPage getCurrentMaterialPage()=>_pages.last;

  ///获取当前显示页面的参数
  T? getArguments<T>() {
    if (_pages.isNotEmpty) {
      return _pages.last.arguments as T?;
    }
    return null;
  }

  void pop<T>([T? result]) async {
    if (canPop()) {
      _popAndOnResult(result);
      notify();
    }
    
    // 抽屉栈：栈为空时自动关闭抽屉
    if (isDrawerStack && _pages.length <= 1 && _drawerConfig?.autoClose == true) {
      closeDrawerStack();
    }
  }
  void _popAndOnResult<T>([T? result]){
    final page = _pages.removeLast();
    _result[page.hashCode]?.call(result);
    _result.remove(page.hashCode);
  }

  /// 关闭当前窗口，并附带返回值
  /// 示例:
  /// RouterProxy.getInstance().popWithResult('从页面返回的数据');
  void popWithResult<T>([T? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop(result);
    }
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


  /// pop当前页面，然后push一个新页面
  void popAndPushNamed(
      {required String name, Object? arguments, Widget? emptyPage}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    pushNamed(name: name, arguments: arguments, emptyPage: emptyPage);
  }

  /// 根据名称跳转页面
  Future<void> pushNamed(
      {required String name,
        ResultCallBack? onResult,
      Object? arguments,
      Widget? emptyPage,
      bool custom = true,
      String? restorationId,
      LaunchMode launchMode = LaunchMode.standard}) async {
    
    // 执行路由守卫检查
    final from = RouteInformation(uri: Uri.parse(_location ?? '/'));
    final to = RouteInformation(uri: Uri.parse(name));
    final canNavigate = await _checkRouteGuards(from, to);
    if (!canNavigate) {
      return;
    }

    var page = pageMap?[name];
    _location = name;
    if (custom && page == null) {
      page = _routePathCallBack
          ?.call(RouteInformation(uri: Uri.parse(_location!)));
    }
    if (page == null) {
      _location = '404';
      page = emptyPage ?? _notFoundPage ?? const EmptyPage();
    }
    push(
        page: page,
        name: name,
        onResult: onResult,
        arguments: arguments,
        restorationId: restorationId,
        launchMode: launchMode);
  }

  /// 回到根页面
  void goRootPage() {
    _pages.clear();
    _location = '/';
    pushNamed(name: _location!);
  }

  /// 清空页面栈并push新页面
  void pushAndRemoveAll(Widget page) {
    pages.clear();
    push(page: page);
  }
  /// 跳转到指定页面，并清空之前的所有页面
  void pushNamedAndRemoveAll(
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




  /// 显示一个通用的对话框(Dialog)
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
  }) async {
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
  }) async {
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
  /// 示例:
  /// RouterProxy.getInstance().showAppSnackBar(message: '这是一个提示！');
  void showAppSnackBar({required String message}) {
    if (_context == null) return;
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(_context!).showSnackBar(snackBar);
  }

  /// 非页面跳转，只切换到目标页面 (例如主页的Tab切换)
  void goToTarget(Widget page, {bool insert = true}) {
    _navigateToTargetCallBack?.call(navigatorKey.currentContext!, page);
    if (insert) {
      // 避免重复添加
      if (_targetPageQueue.isNotEmpty &&
          _targetPageQueue.last.runtimeType == page.runtimeType) {
        return;
      }
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
}
