import 'package:flutter/material.dart';
import 'router_proxy.dart';

///
/// author: 郑再红
/// email: 1096877329@qq.com
/// date: 2024-12-05
/// 抽屉路由 Widget 封装
/// 自动处理 context 绑定，避免手动绑定遗漏
///

/// 抽屉路由栈 Widget
/// 
/// 自动绑定抽屉上下文，无需手动调用 bindDrawerContext
/// 自动监听路由栈变化并刷新页面
/// 
/// 示例：
/// ```dart
/// Scaffold(
///   endDrawer: DrawerRouterWidget(
///     router: drawerRouter,
///     width: 300,
///     child: CustomDrawerContent(),
///   ),
/// );
/// ```
class DrawerRouterWidget extends StatefulWidget {
  /// 抽屉路由实例
  final RouterProxy router;
  
  /// 抽屉宽度
  final double? width;
  
  /// 抽屉高度（通常不需要设置）
  final double? height;
  
  /// 背景色
  final Color? backgroundColor;
  
  /// 子组件（自定义内容）
  final Widget child;
  
  /// 边距
  final EdgeInsetsGeometry? padding;
  
  /// 圆角
  final BorderRadiusGeometry? borderRadius;
  
  /// 阴影
  final List<BoxShadow>? boxShadow;

  const DrawerRouterWidget({
    Key? key,
    required this.router,
    required this.child,
    this.width,
    this.height,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  State<DrawerRouterWidget> createState() => _DrawerRouterWidgetState();
}

class _DrawerRouterWidgetState extends State<DrawerRouterWidget> {
  @override
  void initState() {
    super.initState();
    // 监听路由栈变化
    widget.router.addListener(_onRouterChanged);
  }

  @override
  void dispose() {
    // 移除监听
    widget.router.removeListener(_onRouterChanged);
    super.dispose();
  }

  void _onRouterChanged() {
    // 路由栈变化时刷新页面
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // 自动绑定抽屉上下文
    widget.router.bindDrawerContext(context);
    
    return Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).drawerTheme.backgroundColor,
        borderRadius: widget.borderRadius,
        boxShadow: widget.boxShadow,
      ),
      child: widget.child,
    );
  }
}

/// 简化版抽屉路由栈 Widget
/// 
/// 更简洁的使用方式，直接传入 router 即可
/// 自动监听路由栈变化并刷新页面
/// 
/// 示例：
/// ```dart
/// Scaffold(
///   endDrawer: SimpleDrawerWidget(
///     router: drawerRouter,
///     width: 300,
///   ),
/// );
/// ```
class SimpleDrawerWidget extends StatefulWidget {
  /// 抽屉路由实例
  final RouterProxy router;
  
  /// 抽屉宽度
  final double width;
  
  /// 背景色
  final Color? backgroundColor;
  
  /// 边距
  final EdgeInsetsGeometry? padding;

  const SimpleDrawerWidget({
    Key? key,
    required this.router,
    this.width = 300,
    this.backgroundColor,
    this.padding,
  }) : super(key: key);

  @override
  State<SimpleDrawerWidget> createState() => _SimpleDrawerWidgetState();
}

class _SimpleDrawerWidgetState extends State<SimpleDrawerWidget> {
  @override
  void initState() {
    super.initState();
    // 监听路由栈变化
    widget.router.addListener(_onRouterChanged);
  }

  @override
  void dispose() {
    // 移除监听
    widget.router.removeListener(_onRouterChanged);
    super.dispose();
  }

  void _onRouterChanged() {
    // 路由栈变化时刷新页面
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // 自动绑定抽屉上下文
    widget.router.bindDrawerContext(context);
    
    return Container(
      width: widget.width,
      padding: widget.padding,
      color: widget.backgroundColor ?? Theme.of(context).drawerTheme.backgroundColor,
      child: widget.router.build(context),
    );
  }
}

/// 自定义样式的抽屉路由栈 Widget
/// 
/// 支持更多自定义选项
/// 自动监听路由栈变化并刷新页面
/// 
/// 示例：
/// ```dart
/// Scaffold(
///   endDrawer: StyledDrawerWidget(
///     router: drawerRouter,
///     width: 300,
///     backgroundColor: Colors.white,
///     borderRadius: BorderRadius.only(
///       topLeft: Radius.circular(16),
///       bottomLeft: Radius.circular(16),
///     ),
///     boxShadow: [
///       BoxShadow(
///         color: Colors.black26,
///         blurRadius: 10,
///         offset: Offset(-2, 0),
///       ),
///     ],
///   ),
/// );
/// ```
class StyledDrawerWidget extends StatefulWidget {
  /// 抽屉路由实例
  final RouterProxy router;
  
  /// 抽屉宽度
  final double width;
  
  /// 背景色
  final Color? backgroundColor;
  
  /// 边距
  final EdgeInsetsGeometry? padding;
  
  /// 圆角
  final BorderRadiusGeometry? borderRadius;
  
  /// 阴影
  final List<BoxShadow>? boxShadow;
  
  /// 渐变背景
  final Gradient? gradient;
  
  /// 边框
  final BoxBorder? border;

  const StyledDrawerWidget({
    Key? key,
    required this.router,
    this.width = 300,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.border,
  }) : super(key: key);

  @override
  State<StyledDrawerWidget> createState() => _StyledDrawerWidgetState();
}

class _StyledDrawerWidgetState extends State<StyledDrawerWidget> {
  @override
  void initState() {
    super.initState();
    // 监听路由栈变化
    widget.router.addListener(_onRouterChanged);
  }

  @override
  void dispose() {
    // 移除监听
    widget.router.removeListener(_onRouterChanged);
    super.dispose();
  }

  void _onRouterChanged() {
    // 路由栈变化时刷新页面
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // 自动绑定抽屉上下文
    widget.router.bindDrawerContext(context);
    
    return Container(
      width: widget.width,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).drawerTheme.backgroundColor,
        gradient: widget.gradient,
        borderRadius: widget.borderRadius,
        boxShadow: widget.boxShadow,
        border: widget.border,
      ),
      child: widget.router.build(context),
    );
  }
}
