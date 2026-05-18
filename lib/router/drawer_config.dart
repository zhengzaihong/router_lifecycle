
/// author:郑再红
/// email:1096877329@qq.com
/// date:2026-04-30 10:00
/// describe: 抽屉路由配置
/// 用于配置抽屉路由栈的行为（不包含样式配置）
/// Configures drawer stack behavior.
///
class DrawerConfig {
  /// 是否自动打开抽屉（首次 push 时）
  /// Whether to open the drawer automatically when the stack becomes active.
  final bool autoOpen;
  /// 是否自动关闭抽屉（栈为空时）
  /// Whether to close the drawer automatically when only the root page remains.
  final bool autoClose;
  /// 是否为右侧抽屉（endDrawer）
  /// true: 右侧抽屉（endDrawer）
  /// false: 左侧抽屉（drawer）
  /// Whether this controller manages `Scaffold.endDrawer` instead of `drawer`.
  final bool isEndDrawer;

  const DrawerConfig({
    this.autoOpen = true,
    this.autoClose = true,
    this.isEndDrawer = true,
  });

  /// 复制并修改配置
  /// Creates a copy with the provided fields replaced.
  DrawerConfig copyWith({
    bool? autoOpen,
    bool? autoClose,
    bool? isEndDrawer,
  }) {
    return DrawerConfig(
      autoOpen: autoOpen ?? this.autoOpen,
      autoClose: autoClose ?? this.autoClose,
      isEndDrawer: isEndDrawer ?? this.isEndDrawer,
    );
  }

  @override
  String toString() {
    return 'DrawerConfig(autoOpen: $autoOpen, autoClose: $autoClose, '
        'isEndDrawer: $isEndDrawer)';
  }
}
