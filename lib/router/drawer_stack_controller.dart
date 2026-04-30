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
class DrawerStackController {
  /// Scaffold 的 GlobalKey，用于访问 ScaffoldState
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  /// 底层的 RouterProxy 实例，管理页面栈
  final RouterProxy routerProxy;
  
  /// 抽屉配置
  final DrawerConfig config;

  DrawerStackController({
    required this.scaffoldKey,
    required this.routerProxy,
    required this.config,
  }) {
    // 监听路由栈变化
    routerProxy.addListener(_onRouteChanged);
  }

  /// 路由栈变化时的回调
  void _onRouteChanged() {
    // 自动打开抽屉
    if (config.autoOpen && routerProxy.pages.isNotEmpty) {
      // 使用 post frame callback 确保 Scaffold 已经 build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openDrawer();
      });
    }
    
    // 自动关闭抽屉
    if (config.autoClose && routerProxy.pages.length <= 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _closeDrawer();
      });
    }
  }

  /// 打开抽屉
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

  /// 关闭抽屉
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
  void openDrawer() {
    _openDrawer();
  }

  /// 手动关闭抽屉
  void closeDrawer() {
    _closeDrawer();
  }

  /// 检查抽屉是否打开
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
  Future<void> push({
    required Widget page,
    String? name,
    Object? arguments,
    ResultCallBack? onResult,
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
  Future<void> pushNamed({
    required String name,
    Object? arguments,
    ResultCallBack? onResult,
  }) {
    debugPrint('[DrawerStackController] pushNamed called: $name');
    return routerProxy.pushNamed(
      name: name,
      arguments: arguments,
      onResult: onResult,
    );
  }

  /// 弹出当前页面
  void pop<T>([T? result]) {
    debugPrint('[DrawerStackController] pop called');
    routerProxy.pop(result);
  }

  /// 获取当前页面栈
  List<MaterialPage> get pages => routerProxy.pages;

  /// 构建 Navigator Widget
  Widget build(BuildContext context) {
    return routerProxy.build(context);
  }

  /// 清理资源
  void dispose() {
    routerProxy.removeListener(_onRouteChanged);
  }
}
