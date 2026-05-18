import 'package:flutter/material.dart';
import 'drawer_stack_controller.dart';

///
/// author: 郑再红
/// email: 1096877329@qq.com
/// date: 2024-12-05
/// DrawerNavigator - 抽屉导航 Widget
///
/// 简化的抽屉导航 Widget，配合 DrawerStackController 使用
/// 只负责渲染路由内容，样式由开发者自定义
///
/// 示例：
/// ```dart
/// final scaffoldKey = GlobalKey<ScaffoldState>();
/// final controller = DrawerStackController(
///   scaffoldKey: scaffoldKey,
///   routerProxy: RouterProxy.getDrawerInstance(stackId: 'drawer'),
///   config: DrawerConfig(autoOpen: true),
/// );
///
/// Scaffold(
///   key: scaffoldKey,
///   endDrawer: Container(
///     width: 300,
///     color: Colors.white,
///     child: DrawerNavigator(controller: controller),
///   ),
/// )
/// ```
/// Renders the page stack managed by a [DrawerStackController].
class DrawerNavigator extends StatefulWidget {
  /// Drawer controller used to render and control the stack.
  final DrawerStackController controller;

  const DrawerNavigator({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<DrawerNavigator> createState() => _DrawerNavigatorState();
}

class _DrawerNavigatorState extends State<DrawerNavigator> {
  @override
  void initState() {
    super.initState();
    widget.controller.routerProxy.addListener(_onRouterChanged);
  }

  @override
  void dispose() {
    widget.controller.routerProxy.removeListener(_onRouterChanged);
    super.dispose();
  }

  void _onRouterChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return InheritedDrawerStackController(
      controller: widget.controller,
      child: widget.controller.build(context),
    );
  }
}


/// InheritedWidget 用于在抽屉内传递 DrawerStackController
///
/// 抽屉内的页面可以通过以下方式访问 DrawerStackController：
/// ```dart
/// final controller = InheritedDrawerStackController.of(context);
/// controller?.push(page: NextPage());
/// ```
/// Provides a [DrawerStackController] to drawer descendants.
class InheritedDrawerStackController extends InheritedWidget {
  final DrawerStackController controller;

  const InheritedDrawerStackController({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  /// 从 context 中获取 DrawerStackController
  /// Reads the nearest [DrawerStackController] from [context].
  static DrawerStackController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedDrawerStackController>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(InheritedDrawerStackController oldWidget) {
    return controller != oldWidget.controller;
  }
}
