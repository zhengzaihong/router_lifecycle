part of 'router_proxy.dart';

class _RouterPageEntry {
  const _RouterPageEntry({
    required this.id,
    required this.page,
    required this.materialPage,
  });

  final int id;
  final Widget page;
  final MaterialPage<Object?> materialPage;
}

/// 已完成解析和守卫校验、可以直接写入页面栈的导航结果。
class _PreparedNavigation {
  const _PreparedNavigation({
    required this.page,
    required this.location,
  });

  final Widget page;
  final String location;
}

class _MainStackPageBinding extends StatefulWidget {
  const _MainStackPageBinding({
    required this.router,
    required this.child,
  });

  final RouterProxy router;
  final Widget child;

  @override
  State<_MainStackPageBinding> createState() => _MainStackPageBindingState();
}

class _MainStackPageBindingState extends State<_MainStackPageBinding> {
  bool _syncScheduled = false;
  ScaffoldState? _lastBoundState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleSync();
  }

  @override
  void didUpdateWidget(covariant _MainStackPageBinding oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.router, widget.router) &&
        _lastBoundState != null) {
      oldWidget.router._unbindAutoMainScaffoldState(_lastBoundState!);
      _lastBoundState = null;
    }
    _scheduleSync();
  }

  void _scheduleSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) return;

      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) {
        if (_lastBoundState != null) {
          widget.router._unbindAutoMainScaffoldState(_lastBoundState!);
          _lastBoundState = null;
        }
        return;
      }

      final scaffoldState = _findDescendantScaffoldState(context as Element);
      if (!identical(_lastBoundState, scaffoldState) &&
          _lastBoundState != null) {
        widget.router._unbindAutoMainScaffoldState(_lastBoundState!);
      }

      _lastBoundState = scaffoldState;
      widget.router._bindAutoMainScaffoldState(scaffoldState);
    });
  }

  ScaffoldState? _findDescendantScaffoldState(Element element) {
    ScaffoldState? scaffoldState;

    void visitor(Element child) {
      if (scaffoldState != null) return;
      if (child is StatefulElement && child.state is ScaffoldState) {
        scaffoldState = child.state as ScaffoldState;
        return;
      }
      child.visitChildElements(visitor);
    }

    element.visitChildElements(visitor);
    return scaffoldState;
  }

  @override
  void dispose() {
    if (_lastBoundState != null) {
      widget.router._unbindAutoMainScaffoldState(_lastBoundState!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleSync();
    return widget.child;
  }
}
