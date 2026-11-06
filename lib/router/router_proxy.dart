import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'custom_parser.dart';
import 'empty_page.dart';
import 'drawer_config.dart';

part 'router_proxy_internal.dart';

///
/// author:郑再红
/// email:1096877329@qq.com
/// date: 2022-12-05
/// time: 09:12
/// describe 基于路由2.0实现界面跳转
/// 支持1.0中的路由传值，回传取值
/// 支持多路由栈架构（主路由栈 + 抽屉路由栈）
/// A Navigator 2.0 based router with support for route stacks, guards,
/// drawer stacks, and lifecycle-friendly helpers.
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
//     exitWindow: _confirmExit,
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
//       endDrawer: DrawerNavigator(
//         controller: controller,
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
//     final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer'); //子页面中可以 InheritedDrawerStackController.of(context);
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

//
// ============ exitWindow 示例 ============
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

typedef RoutePathCallback = Widget? Function(RouteInformation routeInformation);
typedef ExitWindow = Future<bool> Function(BuildContext context);
typedef ResultCallback = void Function(Object? result);
typedef RouteGuard = Future<bool> Function(
    RouteInformation from, RouteInformation to);
typedef PageTypeGuard = Future<bool> Function(
    Type? fromPageType, Type toPageType);

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

  /// Main stack Scaffold key, used by main drawer control methods.
  GlobalKey<ScaffoldState>? _mainScaffoldKey;

  /// Auto-bound ScaffoldState for the current main-stack page.
  ScaffoldState? _autoMainScaffoldState;

  /// 可用于动态路由实现跳转
  RoutePathCallback? _routePathCallback;

  /// 移动端退出程序时自定义页面的回调（仅用于主路由栈）
  ExitWindow? _exitWindow;

  /// 路由导航守卫
  final List<RouteGuard> _routeGuards = [];

  /// 页面类型导航守卫
  final List<PageTypeGuard> _pageTypeGuards = [];

  /// 静态路由的页面
  Map<String, Widget> pageMap;

  /// 当前路由的名称 用web浏览器中
  String? _location;

  /// 具体的页面集
  final List<_RouterPageEntry> _pages = [];
  final Map<int, ResultCallback?> _result = {};
  final Map<int, Object?> _pendingPopResults = {};

  /// 页面唯一 id，用于生成稳定的 Page key
  int _nextPageId = 0;

  /// 是否输出调试日志。release 下默认关闭，避免泄露路由信息。
  static bool debugLogging = kDebugMode;

  /// 导航操作串行状态。
  ///
  /// 使用同步标志 + 等待者队列，而不是持有跨测试/跨 zone 的 Future，
  /// 避免在测试等场景下出现 Future 永不完成的问题。
  bool _isNavigating = false;
  final List<Completer<void>> _navigationWaiters = [];

  bool _disposed = false;

  /// 与 MaterialApp.router 共享的路由解析器
  RouteInformationParser<RouteInformation> _routeInformationParser =
      const CustomParser();

  /// 404错误页面
  Widget? _notFoundPage;

  RouterProxy._({
    required this.stackId,
    this.isMainStack = false,
    this.isDrawerStack = false,
    DrawerConfig? drawerConfig,
    ExitWindow? exitWindow,
    RoutePathCallback? pathCallback,
    Map<String, Widget>? pageMap,
    Widget? notFoundPage,
  })  : _navigatorKey = GlobalKey<NavigatorState>(debugLabel: stackId),
        _drawerConfig = drawerConfig,
        pageMap = pageMap ?? {},
        super() {
    _exitWindow = exitWindow;
    _routePathCallback = pathCallback;
    _notFoundPage = notFoundPage;

    // 只添加根页面到初始栈
    if (pageMap != null && pageMap.containsKey('/')) {
      _pages.add(_createPageEntry(page: pageMap['/']!, name: '/'));
      _location = '/';
    }
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
    RoutePathCallback? routePathCallback,
    ExitWindow? exitWindow,
    Map<String, Widget>? pageMap,
    Widget? notFoundPage,
  }) {
    _mainInstance ??= RouterProxy._(
      stackId: 'main',
      isMainStack: true,
      isDrawerStack: false,
      pathCallback: routePathCallback,
      exitWindow: exitWindow,
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
    Map<String, Widget>? pageMap,
    DrawerConfig? drawerConfig,
    RoutePathCallback? routePathCallback,
    Widget? notFoundPage,
  }) {
    if (!_drawerInstances.containsKey(stackId)) {
      _drawerInstances[stackId] = RouterProxy._(
        stackId: stackId,
        isMainStack: false,
        isDrawerStack: true,
        pageMap: pageMap,
        drawerConfig: drawerConfig ?? const DrawerConfig(),
        pathCallback: routePathCallback,
        notFoundPage: notFoundPage,
      );
    } else {
      // 如果实例已存在，更新 pageMap、drawerConfig 和动态路由配置
      final instance = _drawerInstances[stackId]!;
      if (pageMap != null) {
        instance.pageMap = pageMap;
      }
      if (drawerConfig != null) {
        instance._drawerConfig = drawerConfig;
      }
      if (routePathCallback != null) {
        instance._routePathCallback = routePathCallback;
      }
      if (notFoundPage != null) {
        instance._notFoundPage = notFoundPage;
      }
    }
    return _drawerInstances[stackId]!;
  }

  /// 移除抽屉路由实例
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

  /// 设置与 [MaterialApp.router] 共享的路由解析器。
  ///
  /// [RouterProxy] 在 [pushNamed] 等命名导航中会使用同一个解析器，
  /// 以便把 `state`（路径参数、查询参数、匹配模式等）传递给路由回调。
  void setRouteInformationParser(
    RouteInformationParser<RouteInformation> parser,
  ) {
    _routeInformationParser = parser;
  }

  /// 当前使用的路由解析器。
  RouteInformationParser<RouteInformation> get routeInformationParser =>
      _routeInformationParser;

  RouteInformationParser<RouteInformation> defaultParser() {
    return _routeInformationParser;
  }

  MaterialPage<Object?> _createMaterialPage({
    required LocalKey key,
    required Widget page,
    String? name,
    Object? arguments,
    String? restorationId,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool allowSnapshotting = true,
    required PopInvokedWithResultCallback<Object?> onPopInvoked,
  }) {
    final pageChild =
        isMainStack ? _MainStackPageBinding(router: this, child: page) : page;

    return MaterialPage(
      key: key,
      child: pageChild,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      allowSnapshotting: allowSnapshotting,
      onPopInvoked: onPopInvoked,
    );
  }

  _RouterPageEntry _createPageEntry({
    required Widget page,
    String? name,
    Object? arguments,
    String? restorationId,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool allowSnapshotting = true,
  }) {
    final id = _nextPageId++;
    late final MaterialPage<Object?> materialPage;
    materialPage = _createMaterialPage(
      key: ValueKey<int>(id),
      page: page,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      allowSnapshotting: allowSnapshotting,
      onPopInvoked: (didPop, result) {
        if (didPop) {
          _pendingPopResults[id] = result;
        }
      },
    );

    return _RouterPageEntry(
      id: id,
      page: page,
      materialPage: materialPage,
    );
  }

  List<MaterialPage<Object?>> get _materialPages =>
      _pages.map((entry) => entry.materialPage).toList(growable: false);

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
      _log(
          'Warning: bindDrawerContext() should only be called on drawer stack');
    }
  }

  /// Explicitly binds the [ScaffoldState] used by main drawer helpers.
  ///
  /// Main-stack drawer helpers auto-bind to the current page when possible.
  /// Use this method only when you want to override that behavior.
  void bindMainScaffoldKey(GlobalKey<ScaffoldState> scaffoldKey) {
    if (isMainStack) {
      _mainScaffoldKey = scaffoldKey;
    } else {
      _log(
          'Warning: bindMainScaffoldKey() should only be called on main stack');
    }
  }

  void _bindAutoMainScaffoldState(ScaffoldState? scaffoldState) {
    if (isMainStack) {
      _autoMainScaffoldState = scaffoldState;
    }
  }

  void _unbindAutoMainScaffoldState(ScaffoldState scaffoldState) {
    if (identical(_autoMainScaffoldState, scaffoldState)) {
      _autoMainScaffoldState = null;
    }
  }

  ScaffoldState? get _mainScaffoldState =>
      _mainScaffoldKey?.currentState ?? _autoMainScaffoldState;

  void _syncLocationWithTopPage() {
    _location = _pages.isEmpty ? null : _pages.last.materialPage.name;
  }

  void _removePageEntryAt(int index, [Object? result]) {
    final pageEntry = _pages.removeAt(index);
    _result[pageEntry.id]?.call(result);
    _result.remove(pageEntry.id);
    _pendingPopResults.remove(pageEntry.id);
    _syncLocationWithTopPage();
  }

  void _handleDidRemovePage(Page<Object?> page) {
    final index = _pages.indexWhere(
      (entry) => identical(entry.materialPage, page),
    );
    if (index == -1) return;

    final entry = _pages[index];
    final result = _pendingPopResults[entry.id];
    _removePageEntryAt(index, result);
    notify();

    if (isDrawerStack &&
        _pages.length <= 1 &&
        _drawerConfig?.autoClose == true) {
      closeDrawerStack();
    }
  }

  void _clearPageStack() {
    _pages.clear();
    _result.clear();
    _pendingPopResults.clear();
  }

  /// 配置抽屉行为（仅抽屉路由栈可用）
  ///
  /// 可以在运行时修改抽屉配置
  void configureDrawer(DrawerConfig config) {
    if (isDrawerStack) {
      _drawerConfig = config;
    } else {
      _log('Warning: configureDrawer() should only be called on drawer stack');
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
      _log('Warning: openDrawerStack() should only be called on drawer stack');
      return;
    }

    if (_drawerContext == null) {
      _log(
          'Warning: Drawer context not bound. Call bindDrawerContext() first.');
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
      _log('Error opening drawer: $e');
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
      _log('Warning: closeDrawerStack() should only be called on drawer stack');
      return;
    }

    if (_drawerContext == null) {
      _log(
          'Warning: Drawer context not bound. Call bindDrawerContext() first.');
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
      _log('Error closing drawer: $e');
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
      _log('Warning: openMainDrawer() should only be called on main stack');
      return;
    }

    final state = _mainScaffoldState;
    if (state == null) {
      _log(
          'Warning: Main ScaffoldState not available. Ensure the current page contains a Scaffold, or call bindMainScaffoldKey() explicitly.');
      return;
    }

    try {
      if (isEndDrawer) {
        if (!state.isEndDrawerOpen) {
          state.openEndDrawer();
        }
      } else {
        if (!state.isDrawerOpen) {
          state.openDrawer();
        }
      }
    } catch (e) {
      _log('Error opening main drawer: $e');
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
      _log('Warning: closeMainDrawer() should only be called on main stack');
      return;
    }

    final state = _mainScaffoldState;
    if (state == null) {
      _log(
          'Warning: Main ScaffoldState not available. Ensure the current page contains a Scaffold, or call bindMainScaffoldKey() explicitly.');
      return;
    }

    try {
      if (isEndDrawer) {
        if (state.isEndDrawerOpen) {
          state.closeEndDrawer();
        }
      } else {
        if (state.isDrawerOpen) {
          state.closeDrawer();
        }
      }
    } catch (e) {
      _log('Error closing main drawer: $e');
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
    final state = _mainScaffoldState;
    if (!isMainStack || state == null) return false;

    try {
      if (isEndDrawer) {
        return state.isEndDrawerOpen;
      } else {
        return state.isDrawerOpen;
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
  Future<bool> _checkRouteGuards(
      RouteInformation from, RouteInformation to) async {
    for (var guard in List<RouteGuard>.of(_routeGuards)) {
      final result = await guard(from, to);
      if (!result) {
        return false;
      }
    }
    return true;
  }

  /// 执行页面类型守卫检查
  Future<bool> _checkPageTypeGuards(Type? fromPageType, Type toPageType) async {
    for (var guard in List<PageTypeGuard>.of(_pageTypeGuards)) {
      final result = await guard(fromPageType, toPageType);
      if (!result) {
        return false;
      }
    }
    return true;
  }

  /// 统一执行路由守卫和页面类型守卫。
  ///
  /// 所有导航入口都应在修改页面栈之前调用该方法，避免守卫拦截后
  /// 页面栈已被破坏。
  Future<bool> _checkGuards({
    required RouteInformation to,
    required Type toPageType,
  }) async {
    final fromUri = _tryParseUri(_location ?? '/') ?? Uri.parse('/');
    if (!await _checkRouteGuards(
      RouteInformation(uri: fromUri),
      to,
    )) {
      return false;
    }

    final fromPageType =
        _pages.isNotEmpty ? _pages.last.page.runtimeType : null;
    return _checkPageTypeGuards(fromPageType, toPageType);
  }

  Uri? _tryParseUri(String value) {
    try {
      return Uri.parse(value);
    } on FormatException {
      _log('invalid route name "$value"');
      return null;
    }
  }

  void _log(String message) {
    if (debugLogging) {
      debugPrint('RouterProxy[$stackId]: $message');
    }
  }

  /// 将导航操作串行化执行。
  ///
  /// 守卫通常是异步的；如果多个导航同时等待守卫，页面栈可能被交错修改。
  Future<T> _serializeNavigation<T>(Future<T> Function() action) async {
    while (_isNavigating) {
      final waiter = Completer<void>();
      _navigationWaiters.add(waiter);
      await waiter.future;
    }

    if (_disposed) {
      throw StateError('RouterProxy has been disposed');
    }

    _isNavigating = true;
    try {
      return await action();
    } finally {
      _isNavigating = false;
      if (_navigationWaiters.isNotEmpty) {
        final waiters = List<Completer<void>>.of(_navigationWaiters);
        _navigationWaiters.clear();
        for (final waiter in waiters) {
          waiter.complete();
        }
      }
    }
  }

  /// 根据 `pageMap` 或动态路由回调解析目标页面。
  ///
  /// 查找顺序：path -> 完整 URI -> [RoutePathCallback]。
  Widget? _resolvePage(
    RouteInformation routeInformation, {
    bool custom = true,
  }) {
    final uri = routeInformation.uri;
    final staticPage = pageMap[uri.path] ?? pageMap[uri.toString()];
    if (staticPage != null) {
      return staticPage;
    }
    if (!custom) {
      return null;
    }
    return _routePathCallback?.call(routeInformation);
  }

  /// 解析命名路由并完成守卫检查。
  ///
  /// 返回 `null` 表示解析失败、目标未找到或守卫拦截，调用方不得修改页面栈。
  Future<_PreparedNavigation?> _prepareNamedNavigation({
    required String name,
    bool custom = true,
    Widget? emptyPage,
  }) async {
    final uri = _tryParseUri(name);
    if (uri == null) {
      return null;
    }

    RouteInformation routeInformation;
    try {
      routeInformation = await _routeInformationParser.parseRouteInformation(
        RouteInformation(uri: uri),
      );
    } catch (error) {
      _log('failed to parse "$name": $error');
      return null;
    }

    final resolvedPage = _resolvePage(routeInformation, custom: custom) ??
        emptyPage ??
        _notFoundPage ??
        const EmptyPage();

    if (!await _checkGuards(
      to: routeInformation,
      toPageType: resolvedPage.runtimeType,
    )) {
      return null;
    }

    return _PreparedNavigation(
      page: resolvedPage,
      location: routeInformation.uri.toString(),
    );
  }

  @override
  RouteInformation get currentConfiguration {
    return RouteInformation(
      uri: _tryParseUri(_location ?? '/') ?? Uri.parse('/'),
    );
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  BuildContext? get _context => navigatorKey.currentContext;

  @override
  Widget build(BuildContext context) {
    final pages = _pages.isEmpty ? [_fallbackMaterialPage()] : _materialPages;

    // 抽屉路由栈也需要返回 Navigator，但不需要 PopScope
    if (isDrawerStack) {
      return Navigator(
        key: navigatorKey,
        pages: pages,
        onDidRemovePage: _handleDidRemovePage,
      );
    }

    // 主路由栈返回完整的 Navigator with PopScope
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: _onPopInvokedWithResult,
        child: Navigator(
          key: navigatorKey,
          pages: pages,
          onDidRemovePage: _handleDidRemovePage,
        ));
  }

  /// 页面栈为空时使用的兜底页面，避免 Navigator 渲染空栈导致黑屏。
  MaterialPage<Object?> _fallbackMaterialPage() {
    final fallback = _notFoundPage ?? const EmptyPage();
    return MaterialPage(
      key: const ValueKey<String>('__router_fallback__'),
      child: isMainStack
          ? _MainStackPageBinding(router: this, child: fallback)
          : fallback,
    );
  }

  void _onPopInvokedWithResult(bool didPop, Object? result) {
    // 当 canPop 为 false 时, didPop 总是 false.
    // 我们在此处手动处理返回手势.
    if (!didPop) {
      popRoute();
    }
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) {
    return _serializeNavigation(() async {
      final location = configuration.uri.toString();
      if (location == _location) {
        return;
      }

      // 浏览器后退/前进：目标页面已存在于当前栈中，直接回退到该页面。
      final existingIndex = _pages.lastIndexWhere((entry) {
        final entryName = entry.materialPage.name;
        return entryName == location || entryName == configuration.uri.path;
      });
      if (existingIndex != -1) {
        for (var index = _pages.length - 1; index > existingIndex; index--) {
          final removedPage = _pages.removeAt(index);
          _result.remove(removedPage.id);
          _pendingPopResults.remove(removedPage.id);
        }
        _location = location;
        notify();
        return;
      }

      //
      final resolvedPage =
          _resolvePage(configuration) ?? _notFoundPage ?? const EmptyPage();

      if (!await _checkGuards(
        to: configuration,
        toPageType: resolvedPage.runtimeType,
      )) {
        return;
      }

      // 初始 URL 或栈中只有根页面时，替换而不是叠加。
      if (_pages.length <= 1) {
        _clearPageStack();
      }

      await _pushEntry(page: resolvedPage, name: location);
    });
  }

  @override
  Future<bool> popRoute() async {
    final navigatorState = navigatorKey.currentState;
    if (navigatorState == null) {
      return Future.value(false);
    }

    // Pageless routes (dialogs, bottom sheets, etc.) should still be dismissed
    // imperatively. Page-based routes must stay in sync with our declarative
    // stack to avoid transient reinsertions during system back gestures.
    if (_hasPagelessTopRoute()) {
      navigatorState.pop();
      return Future.value(true);
    }

    // 如果不行，则尝试从我们自己的页面栈中pop一个页面
    if (canPop()) {
      _popAndOnResult(null);
      notify();
      return Future.value(true);
    }

    /// 如果页面栈也不能pop，则执行自定义的退出逻辑
    return _exitWindow == null
        ? Future.value(false)
        : _exitWindow!.call(navigatorState.context);
  }

  Route<dynamic>? _topNavigatorRoute() {
    final navigatorState = navigatorKey.currentState;
    if (navigatorState == null) return null;

    Route<dynamic>? topRoute;
    navigatorState.popUntil((route) {
      topRoute = route;
      return true;
    });
    return topRoute;
  }

  bool _hasPagelessTopRoute() {
    final topRoute = _topNavigatorRoute();
    return topRoute != null && topRoute.settings is! Page;
  }

  /// 检查页面栈是否可以pop
  bool canPop() => _pages.length > 1;

  /// 推出一个新页面到导航栈
  Future<void> push(
      {required Widget page,
      ResultCallback? onResult,
      String? name,
      Object? arguments,
      String? restorationId,
      bool maintainState = true,
      bool fullscreenDialog = false,
      bool allowSnapshotting = true,
      LaunchMode launchMode = LaunchMode.standard}) {
    return _serializeNavigation(() async {
      final routeName = name ?? page.runtimeType.toString();
      final uri = _tryParseUri(routeName);
      if (uri == null) {
        return;
      }

      // 守卫必须在修改页面栈之前执行。
      if (!await _checkGuards(
        to: RouteInformation(uri: uri),
        toPageType: page.runtimeType,
      )) {
        return;
      }

      await _pushEntry(
        page: page,
        onResult: onResult,
        name: routeName,
        arguments: arguments,
        restorationId: restorationId,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        allowSnapshotting: allowSnapshotting,
        launchMode: launchMode,
      );
    });
  }

  /// 将已通过守卫校验的页面写入页面栈。
  Future<void> _pushEntry(
      {required Widget page,
      ResultCallback? onResult,
      String? name,
      Object? arguments,
      String? restorationId,
      bool maintainState = true,
      bool fullscreenDialog = false,
      bool allowSnapshotting = true,
      LaunchMode launchMode = LaunchMode.standard}) async {
    final routeSettings = RouteSettings(
        name: name ?? page.runtimeType.toString(), arguments: arguments);

    // 处理启动模式
    switch (launchMode) {
      case LaunchMode.singleTop:
        // 如果栈顶已是同一个路由（类型 + name 相同），则重建页面并更新参数
        if (_pages.isNotEmpty &&
            _pages.last.page.runtimeType == page.runtimeType &&
            _pages.last.materialPage.name == routeSettings.name) {
          final lastPage = _pages.removeLast();
          _result.remove(lastPage.id);
          _pendingPopResults.remove(lastPage.id);

          final updatedPage = _createPageEntry(
            page: page,
            name: routeSettings.name,
            arguments: routeSettings.arguments,
            restorationId: restorationId,
            maintainState: maintainState,
            fullscreenDialog: fullscreenDialog,
            allowSnapshotting: allowSnapshotting,
          );
          _pages.add(updatedPage);
          _result[updatedPage.id] = onResult;
          _location = routeSettings.name;
          notify();
          return;
        }
        break;
      case LaunchMode.singleInstance:
        // 如果栈中已存在同一个路由（类型 + name 相同），清除它上面的所有页面，并重建该页面
        final existingIndex = _pages.indexWhere((element) =>
            element.page.runtimeType == page.runtimeType &&
            element.materialPage.name == routeSettings.name);

        if (existingIndex != -1) {
          // 1. 清除该页面及其上面的所有页面
          final pagesToRemove = _pages.sublist(existingIndex);
          for (var pageToRemove in pagesToRemove) {
            _result.remove(pageToRemove.id);
            _pendingPopResults.remove(pageToRemove.id);
          }
          _pages.removeRange(existingIndex, _pages.length);

          // 2. 用新参数重新创建该页面
          final updatedPage = _createPageEntry(
            page: page,
            name: routeSettings.name,
            arguments: routeSettings.arguments,
            restorationId: restorationId,
            maintainState: maintainState,
            fullscreenDialog: fullscreenDialog,
            allowSnapshotting: allowSnapshotting,
          );
          _pages.add(updatedPage);
          _result[updatedPage.id] = onResult;
          _location = routeSettings.name;
          notify();
          return;
        }
        // 如果不存在，继续执行后面的代码创建新实例
        break;
      case LaunchMode.standard:
        // 标准模式，不做特殊处理
        break;
    }

    final target = _createPageEntry(
      page: page,
      name: routeSettings.name,
      arguments: routeSettings.arguments,
      restorationId: restorationId,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      allowSnapshotting: allowSnapshotting,
    );
    _pages.add(target);
    _result[target.id] = onResult;
    _location = routeSettings.name;
    notify();
  }

  /// 获取当前显示的页面Widget
  Widget getCurrentPage() =>
      _pages.isEmpty ? (_notFoundPage ?? const EmptyPage()) : _pages.last.page;

  /// 获取当前显示页面的MaterialPage对象，可用于获取参数
  MaterialPage<Object?> getCurrentMaterialPage() => _pages.isEmpty
      ? MaterialPage(
          key: const ValueKey<String>('__router_current_fallback__'),
          child: _notFoundPage ?? const EmptyPage(),
        )
      : _pages.last.materialPage;

  /// 获取当前显示页面的参数
  ///
  /// 类型不匹配时返回 null，而不是抛出 [TypeError]。
  T? getArguments<T>() {
    if (_pages.isEmpty) {
      return null;
    }
    final arguments = _pages.last.materialPage.arguments;
    return arguments is T ? arguments : null;
  }

  void pop([Object? result]) {
    if (canPop()) {
      _popAndOnResult(result);
      notify();
    }

    // 抽屉栈：栈为空时自动关闭抽屉
    if (isDrawerStack &&
        _pages.length <= 1 &&
        _drawerConfig?.autoClose == true) {
      closeDrawerStack();
    }
  }

  void _popAndOnResult([Object? result]) {
    _removePageEntryAt(_pages.length - 1, result);
  }

  /// 关闭当前窗口，并附带返回值
  /// 示例:
  /// RouterProxy.getInstance().popWithResult('从页面返回的数据');
  void popWithResult([Object? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop(result);
    }
  }

  /// 替换当前页面
  Future<void> replace(
      {required Widget page,
      String? name,
      Object? arguments,
      String? restorationId}) {
    return _serializeNavigation(() async {
      final routeName = name ?? page.runtimeType.toString();
      final uri = _tryParseUri(routeName);
      if (uri == null) {
        return;
      }

      // 守卫失败时保留当前页面。
      if (!await _checkGuards(
        to: RouteInformation(uri: uri),
        toPageType: page.runtimeType,
      )) {
        return;
      }

      if (_pages.isNotEmpty) {
        final removedPage = _pages.removeLast();
        _result.remove(removedPage.id);
        _pendingPopResults.remove(removedPage.id);
      }
      await _pushEntry(
          page: page,
          name: routeName,
          arguments: arguments,
          restorationId: restorationId);
    });
  }

  /// pop当前页面，然后push一个新页面
  Future<void> popAndPushNamed(
      {required String name, Object? arguments, Widget? emptyPage}) {
    return _serializeNavigation(() async {
      final prepared =
          await _prepareNamedNavigation(name: name, emptyPage: emptyPage);
      if (prepared == null) {
        return;
      }

      if (_pages.isNotEmpty) {
        final removedPage = _pages.removeLast();
        _result.remove(removedPage.id);
        _pendingPopResults.remove(removedPage.id);
      }
      await _pushEntry(
          page: prepared.page, name: prepared.location, arguments: arguments);
    });
  }

  /// 根据名称跳转页面
  Future<void> pushNamed(
      {required String name,
      ResultCallback? onResult,
      Object? arguments,
      Widget? emptyPage,
      bool custom = true,
      String? restorationId,
      LaunchMode launchMode = LaunchMode.standard}) {
    return _serializeNavigation(() async {
      final prepared = await _prepareNamedNavigation(
        name: name,
        custom: custom,
        emptyPage: emptyPage,
      );
      if (prepared == null) {
        return;
      }

      await _pushEntry(
          page: prepared.page,
          name: prepared.location,
          onResult: onResult,
          arguments: arguments,
          restorationId: restorationId,
          launchMode: launchMode);
    });
  }

  /// 回到根页面
  Future<void> goRootPage() {
    return pushNamedAndRemoveAll(name: '/');
  }

  /// 清空页面栈并push新页面
  Future<void> pushAndRemoveAll(
    Widget page, {
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return _serializeNavigation(() async {
      final routeName = name ?? page.runtimeType.toString();
      final uri = _tryParseUri(routeName);
      if (uri == null) {
        return;
      }

      // 守卫失败时不清空页面栈。
      if (!await _checkGuards(
        to: RouteInformation(uri: uri),
        toPageType: page.runtimeType,
      )) {
        return;
      }

      _clearPageStack();
      await _pushEntry(
          page: page,
          name: routeName,
          arguments: arguments,
          restorationId: restorationId);
    });
  }

  /// 跳转到指定页面，并清空之前的所有页面
  Future<void> pushNamedAndRemoveAll(
      {required String name,
      Object? arguments,
      Widget? emptyPage,
      String? restorationId}) {
    return _serializeNavigation(() async {
      final prepared =
          await _prepareNamedNavigation(name: name, emptyPage: emptyPage);
      if (prepared == null) {
        return;
      }

      _clearPageStack();
      await _pushEntry(
          page: prepared.page,
          name: prepared.location,
          arguments: arguments,
          restorationId: restorationId);
    });
  }

  /// 将页面置于栈顶（如果已存在则先移除）
  ///
  /// @deprecated 使用 push(page: xxx, launchMode: LaunchMode.singleInstance) 代替
  ///
  /// 示例：
  /// ```dart
  /// // 旧方式
  /// router.pushStackTop(page: HomePage());
  ///
  /// // 新方式（推荐）
  /// router.push(page: HomePage(), launchMode: LaunchMode.singleInstance);
  /// ```
  @Deprecated(
      'Use push(page: xxx, launchMode: LaunchMode.singleInstance) instead')
  Future<void> pushStackTop({required Widget page}) {
    return push(page: page, launchMode: LaunchMode.singleInstance);
  }

  List<MaterialPage<Object?>> get pages => _materialPages;

  String? getLocation() {
    return _location;
  }

  set location(String value) {
    unawaited(popAndPushNamed(name: value));
  }

  void notify() {
    if (_disposed) return;
    notifyListeners();
  }

  /// 释放路由实例持有的页面栈、上下文和静态引用。
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    _drawerContext = null;
    _mainScaffoldKey = null;
    _autoMainScaffoldState = null;
    _pages.clear();
    _result.clear();
    _pendingPopResults.clear();

    if (identical(_mainInstance, this)) {
      _mainInstance = null;
    }
    _drawerInstances.removeWhere(
      (stackId, instance) => identical(instance, this),
    );

    super.dispose();
  }

  /// 重置页面栈，仅供测试使用。
  @visibleForTesting
  void resetForTesting() {
    _pages.clear();
    _result.clear();
    _pendingPopResults.clear();
    _location = null;

    final rootPage = pageMap['/'];
    if (rootPage != null) {
      _pages.add(_createPageEntry(page: rootPage, name: '/'));
      _location = '/';
    }
    notify();
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
}
