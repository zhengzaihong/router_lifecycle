import 'package:flutter/material.dart';
import 'router_proxy.dart';
import 'drawer_config.dart';

///
/// author: 郑再红
/// email: 1096877329@qq.com
/// date: 2024-12-05
/// DrawerStackController - 抽屉路由栈控制器
///
/// 使用 GlobalKey 管理抽屉状态，解决 context 依赖和时序问题
///
/// 示例：
/// ```dart
/// final scaffoldKey = GlobalKey<ScaffoldState>();
/// final controller = DrawerStackController(
///   scaffoldKey: scaffoldKey,
///   routerProxy: RouterProxy.getDrawerInstance(
///     stackId: 'main-drawer',
///     pageMap: {'/': HomePage()},
///   ),
///   config: DrawerConfig(autoOpen: true, autoClose: true),
/// );
///
/// Scaffold(
///   key: scaffoldKey,
///   endDrawer: DrawerNavigator(controller: controller),
///   body: ElevatedButton(
///     onPressed: () => controller.push(page: SettingsPage()),
///   ),
/// )
/// ```
/// Coordinates a drawer-specific [RouterProxy] with a [ScaffoldState].
class DrawerStackController {
  /// Scaffold 的 GlobalKey，用于访问 ScaffoldState
  /// The scaffold key used to access the host [ScaffoldState].
  final GlobalKey<ScaffoldState> scaffoldKey;
  /// 底层的 RouterProxy 实例，管理页面栈
  /// The router instance that owns the drawer page stack.
  final RouterProxy routerProxy;
  /// 抽屉配置
  /// Drawer behavior settings.
  final DrawerConfig config;

  DrawerStackController({
    required this.scaffoldKey,
    required this.routerProxy,
    required this.config,
  }) {
    routerProxy.addListener(_onRouteChanged);
  }

  void _onRouteChanged() {
    if (config.autoOpen && routerProxy.pages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openDrawer();
      });
    }

    if (config.autoClose && routerProxy.pages.length <= 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _closeDrawer();
      });
    }
  }

  void _openDrawer() {
    final state = scaffoldKey.currentState;
    if (state == null) {
      debugPrint('[DrawerStackController] ScaffoldState not available');
      return;
    }

    try {
      if (config.isEndDrawer) {
        if (!state.isEndDrawerOpen) {
          state.openEndDrawer();
        }
      } else {
        if (!state.isDrawerOpen) {
          state.openDrawer();
        }
      }
    } catch (e) {
      debugPrint('[DrawerStackController] Error opening drawer: $e');
    }
  }

  void _closeDrawer() {
    final state = scaffoldKey.currentState;
    if (state == null) {
      debugPrint('[DrawerStackController] ScaffoldState not available');
      return;
    }

    try {
      if (config.isEndDrawer) {
        if (state.isEndDrawerOpen) {
          state.closeEndDrawer();
        }
      } else {
        if (state.isDrawerOpen) {
          state.closeDrawer();
        }
      }
    } catch (e) {
      debugPrint('[DrawerStackController] Error closing drawer: $e');
    }
  }
  /// 手动打开抽屉
  /// Opens the drawer manually.
  void openDrawer() {
    _openDrawer();
  }
  /// 手动关闭抽屉
  /// Closes the drawer manually.
  void closeDrawer() {
    _closeDrawer();
  }
  /// 检查抽屉是否打开
  /// Returns whether the configured drawer is currently open.
  bool get isDrawerOpen {
    final state = scaffoldKey.currentState;
    if (state == null) return false;

    try {
      if (config.isEndDrawer) {
        return state.isEndDrawerOpen;
      } else {
        return state.isDrawerOpen;
      }
    } catch (e) {
      return false;
    }
  }
  // ========== 代理 RouterProxy 的方法 ==========

  /// 推入新页面
  /// Pushes a page onto the drawer stack.
  Future<void> push({
    required Widget page,
    String? name,
    Object? arguments,
    ResultCallback? onResult,
  }) {
    debugPrint('[DrawerStackController] push called: ${page.runtimeType}');
    return routerProxy.push(
      page: page,
      name: name,
      arguments: arguments,
      onResult: onResult,
    );
  }
  /// 根据名称推入新页面
  /// Pushes a named page onto the drawer stack.
  Future<void> pushNamed({
    required String name,
    Object? arguments,
    ResultCallback? onResult,
  }) {
    debugPrint('[DrawerStackController] pushNamed called: $name');
    return routerProxy.pushNamed(
      name: name,
      arguments: arguments,
      onResult: onResult,
    );
  }
  /// 弹出当前页面
  /// Pops the current page from the drawer stack.
  void pop<T>([T? result]) {
    debugPrint('[DrawerStackController] pop called');
    routerProxy.pop(result);
  }
  /// 获取当前页面栈
  /// Exposes the current drawer page stack.
  List<MaterialPage> get pages => routerProxy.pages;

  /// Builds the drawer navigator widget tree.
  Widget build(BuildContext context) {
    return routerProxy.build(context);
  }
  /// 清理资源
  /// Removes internal listeners.
  void dispose() {
    routerProxy.removeListener(_onRouteChanged);
  }
}
