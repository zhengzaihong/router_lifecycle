import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'drawer_router.dart';

///
/// author:郑再红
/// email:1096877329@qq.com
/// date: 2025/2/7
/// time: 14:53
/// 
/// ⚠️ 废弃警告：此类将在未来版本中删除
/// 
/// 请使用新的抽屉路由栈实现方式：
/// 
/// ```dart
/// // 旧方式（将被删除）
/// DrawerRouterStack(
///   router: drawerRouter,
///   bind: (context) => drawerRouter.bindDrawerNavigatorContext(context),
///   builder: (context, child) => Container(...),
/// )
/// 
/// // 新方式（推荐）
/// SimpleDrawerWidget(
///   router: drawerRouter,
///   width: 300,
/// )
/// ```
/// 查看完整文档：DRAWER_ROUTER_USAGE.md

@Deprecated('Use SimpleDrawerWidget, StyledDrawerWidget, or DrawerRouterWidget instead. This class will be removed in future versions.')
class DrawerRouterStack extends BaseStackWidget {

  const DrawerRouterStack({
    Key? key,
    required this.router,
    required this.builder,
    this.child,
  }) : super(key: key, listenable: router);

  @override
  Listenable get listenable => router;

  final DrawerRouter router;
  final TransitionBuilder builder;

  final Widget? child;

  @override
  Widget build(BuildContext context) => builder(context, child);

}

/// 监听listenable动态切换页面
abstract class BaseStackWidget extends StatefulWidget {

  const BaseStackWidget({
    Key? key,
    required this.listenable,

  }) : super(key: key);

  final Listenable listenable;

  @protected
  Widget build(BuildContext context);

  @override
  State<BaseStackWidget> createState() => _BaseStackWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Listenable>('animation', listenable));
  }
}

class _BaseStackWidgetState extends State<BaseStackWidget> {

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(BaseStackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listenable != oldWidget.listenable) {
      oldWidget.listenable.removeListener(_handleChange);
      widget.listenable.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) => widget.build(context);
}