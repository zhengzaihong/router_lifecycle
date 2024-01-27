import 'package:flutter/widgets.dart';

import 'VisibilityDetector.dart';

///
/// create_user: zhengzaihong
/// email:1096877329@qq.com
/// create_date: 2023/12/22
/// create_time: 14:17
/// describe: 监听组件焦点
///
class LifeCycle extends StatefulWidget {
  const LifeCycle({
    required this.child,
    this.onCreate,
    this.onStart,
    this.onResume,
    this.onPause,
    this.onDestroy,
    Key? key,
  }) : super(key: key);

  /// 子组件
  final Widget child;

  /// 开始创建widget时回调方法
  final VoidCallback? onCreate;

  /// 创建widget完成时回调方法，可能还不可见
  final VoidCallback? onStart;

  /// 得到焦点可见状态
  final VoidCallback? onResume;

  /// 失去焦点
  final VoidCallback? onPause;

  /// 不可见状态
  // final VoidCallback? onStop;

  /// 销毁
  final VoidCallback? onDestroy;

  @override
  _LifeCycleState createState() => _LifeCycleState();
}

class _LifeCycleState extends State<LifeCycle>
    with WidgetsBindingObserver {
  final _visibilityDetectorKey = UniqueKey();

  /// 当前组件在app 里可见
  bool _isWidgetVisible = false;

  /// app 是否处于前台
  bool _isAppInForeground = true;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
    widget.onCreate?.call();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.onStart?.call();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _notifyPlaneTransition(state);
  }

  void _notifyPlaneTransition(AppLifecycleState state) {
    if (!_isWidgetVisible) {
      return;
    }

    final isAppResumed = state == AppLifecycleState.resumed;
    final wasResumed = _isAppInForeground;
    if (isAppResumed && !wasResumed) {
      _isAppInForeground = true;
      widget.onResume?.call();
      return;
    }

    final isAppPaused = state == AppLifecycleState.paused;
    if (isAppPaused && wasResumed) {
      _isAppInForeground = false;
      widget.onPause?.call();
    }
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
        key: _visibilityDetectorKey,
        onVisibilityChanged: (visibilityInfo) {
          final visibleFraction = visibilityInfo.visibleFraction;
          _notifyVisibilityStatusChange(visibleFraction);
        },
        child: widget.child,
      );

  void _notifyVisibilityStatusChange(double newVisibleFraction) {
    if (!_isAppInForeground) {
      return;
    }

    final wasFullyVisible = _isWidgetVisible;
    final isFullyVisible = newVisibleFraction == 1;
    if (!wasFullyVisible && isFullyVisible) {
      _isWidgetVisible = true;
      widget.onResume?.call();
    }

    final isFullyInvisible = newVisibleFraction == 0;
    if (wasFullyVisible && isFullyInvisible) {
      _isWidgetVisible = false;
      widget.onPause?.call();
      if(!mounted){
        widget.onDestroy?.call();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}
