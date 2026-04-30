
/// author:郑再红
/// email:1096877329@qq.com
/// date:2026-04-30 10:00
/// describe: 抽屉路由配置
/// 用于配置抽屉路由栈的行为
///
class DrawerConfig {
  /// 是否自动打开抽屉（首次 push 时）
  final bool autoOpen;
  
  /// 是否自动关闭抽屉（栈为空时）
  final bool autoClose;
  
  /// 是否为右侧抽屉（endDrawer）
  /// true: 右侧抽屉（endDrawer）
  /// false: 左侧抽屉（drawer）
  final bool isEndDrawer;
  
  /// 抽屉宽度（可选）
  final double? width;
  
  /// 抽屉背景色（可选）
  final dynamic backgroundColor;

  const DrawerConfig({
    this.autoOpen = true,
    this.autoClose = true,
    this.isEndDrawer = true,
    this.width,
    this.backgroundColor,
  });

  /// 复制并修改配置
  DrawerConfig copyWith({
    bool? autoOpen,
    bool? autoClose,
    bool? isEndDrawer,
    double? width,
    dynamic backgroundColor,
  }) {
    return DrawerConfig(
      autoOpen: autoOpen ?? this.autoOpen,
      autoClose: autoClose ?? this.autoClose,
      isEndDrawer: isEndDrawer ?? this.isEndDrawer,
      width: width ?? this.width,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  String toString() {
    return 'DrawerConfig(autoOpen: $autoOpen, autoClose: $autoClose, '
        'isEndDrawer: $isEndDrawer, width: $width)';
  }
}
