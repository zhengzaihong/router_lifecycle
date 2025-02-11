import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'drawer_router.dart';

///
/// create_user: zhengzaihong
/// email:1096877329@qq.com
/// create_date: 2025/2/7
/// create_time: 14:53
/// describe: 用于抽屉含有多个层级页面跳转，
/// 实现抽屉页面栈 需配合 DrawerRouter 路由使用
///
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