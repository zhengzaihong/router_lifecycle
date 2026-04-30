import 'package:flutter/widgets.dart';
import 'package:router_pro/wrapper/visibility_detector.dart';


///
/// author:郑再红
/// email:1096877329@qq.com
/// date: 2023/12/22
/// time: 14:17
/// describe: 监听组件焦点，提供类似Android Activity的生命周期回调
///
class LifeCycle extends StatefulWidget {
  const LifeCycle({
    required this.child,
    this.onCreate,
    this.onStart,
    this.onResume,
    this.onPause,
    this.onDestroy,
    this.visibilityThreshold = 1.0,
    this.debugLabel,
    Key? key,
  })  : assert(visibilityThreshold >= 0.0 && visibilityThreshold <= 1.0,
            'visibilityThreshold must be between 0.0 and 1.0'),
        super(key: key);

  /// 子组件
  final Widget child;

  /// 开始创建widget时回调方法，可能还不可见
  final VoidCallback? onCreate;

  /// 创建widget完成时回调方法
  final VoidCallback? onStart;

  /// 得到焦点可见状态
  final VoidCallback? onResume;

  /// 失去焦点
  final VoidCallback? onPause;

  /// 销毁
  final VoidCallback? onDestroy;

  /// 可见性阈值，默认1.0表示完全可见时才触发onResume
  /// 设置为0.5表示50%可见时就触发onResume
  /// 范围：0.0 - 1.0
  final double visibilityThreshold;

  /// 调试标签，用于日志输出
  final String? debugLabel;

  @override
  State<LifeCycle> createState() => _LifeCycleState();
}

class _LifeCycleState extends State<LifeCycle> with WidgetsBindingObserver {
  bool _isExit = false;
  late final UniqueKey _visibilityDetectorKey;

  /// 当前组件在app里可见
  bool _isWidgetVisible = false;

  /// app是否处于前台
  bool _isAppInForeground = true;

  /// 当前可见比例
  double _currentVisibleFraction = 0.0;

  @override
  void initState() {
    super.initState();
    _visibilityDetectorKey = UniqueKey();
    WidgetsBinding.instance.addObserver(this);
    
    _debugLog('onCreate');
    widget.onCreate?.call();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _debugLog('onStart');
      widget.onStart?.call();
    });
  }

  @override
  void didUpdateWidget(LifeCycle oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 如果可见性阈值改变，重新评估可见状态
    if (oldWidget.visibilityThreshold != widget.visibilityThreshold) {
      _notifyVisibilityStatusChange(_currentVisibleFraction);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _debugLog('App lifecycle changed: $state');
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
      _debugLog('onResume (app resumed)');
      widget.onResume?.call();
      return;
    }

    final isAppPaused = state == AppLifecycleState.paused;
    if (isAppPaused && wasResumed) {
      _isAppInForeground = false;
      _debugLog('onPause (app paused)');
      widget.onPause?.call();
    }
  }

  @override
  Widget build(BuildContext context) => VisibilityDetector(
        key: _visibilityDetectorKey,
        onVisibilityChanged: (visibilityInfo) {
          final visibleFraction = visibilityInfo.visibleFraction;
          _currentVisibleFraction = visibleFraction;
          _debugLog('Visibility changed: $visibleFraction');
          _notifyVisibilityStatusChange(visibleFraction);
        },
        child: widget.child,
      );

  void _notifyVisibilityStatusChange(double newVisibleFraction) {
    if (!_isAppInForeground) {
      return;
    }

    final wasFullyVisible = _isWidgetVisible;
    final isFullyVisible = newVisibleFraction >= widget.visibilityThreshold;
    
    if (!wasFullyVisible && isFullyVisible) {
      _isWidgetVisible = true;
      _debugLog('onResume (widget visible: ${(newVisibleFraction * 100).toStringAsFixed(1)}%)');
      widget.onResume?.call();
    }

    final isFullyInvisible = newVisibleFraction < widget.visibilityThreshold;
    if (wasFullyVisible && isFullyInvisible && !_isExit) {
      _isWidgetVisible = false;
      _debugLog('onPause (widget invisible: ${(newVisibleFraction * 100).toStringAsFixed(1)}%)');
      widget.onPause?.call();
    }
  }

  void _debugLog(String message) {
    if (widget.debugLabel != null) {
      debugPrint('[LifeCycle:${widget.debugLabel}] $message');
    }
  }

  @override
  void dispose() {
    if (_isWidgetVisible) {
      _isExit = true;
      _debugLog('onPause (disposing)');
      widget.onPause?.call();
    }
    _debugLog('onDestroy');
    widget.onDestroy?.call();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
