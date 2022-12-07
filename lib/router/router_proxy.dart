import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';

///
/// create_user: zhengzaihong
/// Email:1096877329@qq.com
/// create_date: 2022-12-05
/// create_time: 09:12
/// describe 提供给跳转界面的路由，要监听生命周期的 务必使用该路由跳转、关闭页面
///
///
typedef RoutePathCallBack = Widget Function(
    String? routePath, Listenable listenable);

class RouterProxy extends RouterDelegate<List<RouteSettings>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<RouteSettings>> {


  CustomParser defaultParser(){
    return  const CustomParser();
  }


  ///请不要将多个需要监听的导航列表设置相同的key
  final Map<Object, TabPageInfo> _navPages = HashMap();

  final List<Page> _pages = [];
  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  List<Page> get currentConfiguration => List.of(_pages);

  Widget? oldPage;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: popRoute,
        child: Navigator(
          key: navigatorKey,
          pages: List.of(_pages),
          onPopPage: _onPopPage,
        ));
  }

  ///需要手动调用此方法，需同步 IndexedStack 或者 xxController.index下的page
  void setTabChange(Widget page, {Object? uniqueId}) {
    if (page == oldPage) {
      return;
    }
    if (null != uniqueId) {
      TabPageInfo? info = _navPages[uniqueId];
      _findGoTopPage(uniqueId, page, info);
      return;
    }
    _navPages.forEach((key, value) {
      TabPageInfo? info = _navPages[key];
      _findGoTopPage(key, page, info);
    });
  }

  bool _findGoTopPage(Object? uniqueId, Widget targetPage, TabPageInfo? info) {
    // _pageOnPause(oldPage);

    int index = 0;
    for (var page in info?.pages ?? []) {
      if (page.hashCode == targetPage.hashCode) {
        PageType pageType = _checkLifeCyclePage(page);
        if (pageType != PageType.notLifeCycle) {
          _pageOnPause(info!.pages[info.checkPageIndex]);

          info.checkPageIndex = index;
          _pageOnResume(page);
        }
        break;
      }
      index++;
    }
    oldPage = targetPage;
    return false;
  }

  ///关闭页面，需要监听生命周期的务必使用此方法关闭
  void pop(BuildContext context) {
    String widgetId = context.widget.hashCode.toString();
    Page? materialPage = _findPage(widgetId);
    if (materialPage != null) {
      _pages.remove(materialPage);
      _pageOnPause((materialPage as MaterialPage).child);
    }

    if (_pages.isNotEmpty) {
      oldPage = (_pages.last as MaterialPage).child;
    }
    TabPageInfo? tabPageInfo = _isTabPage(oldPage);
    if (tabPageInfo != null) {
      ///如果是导航菜单，则检查最后一次点击子页面，让子页面走得到焦点
      TabPageInfo? info = _navPages[tabPageInfo.uniqueId];
      if (info != null) {
        Widget tempPage = info.pages[info.checkPageIndex];
        _pageOnResume(tempPage);
      }
    } else {
      _pageOnResume(oldPage);
    }
    notifyListeners();
  }

  Page? _findPage(String widgetId) {
    Page? materialPage;
    for (var page in _pages) {
      if (page.restorationId == widgetId) {
        materialPage = page;
        break;
      }
    }
    return materialPage;
  }

  @override
  Future<void> setNewRoutePath(List<RouteSettings> configuration) {
    // print('setNewRoutePath ${configuration.last.name}');
    return Future.value(null);
  }

  @override
  Future<bool> popRoute() {
    if (canPop()) {
      Page page = _pages.removeLast();
      Widget tempPage = (page as MaterialPage).child;

      if (_pages.isNotEmpty) {
        oldPage = (_pages.last as MaterialPage).child;
      } else {
        oldPage = null;
      }

      // print("监听到物理返回键");
      TabPageInfo? tabPageInfo = _isTabPage(oldPage);
      if (tabPageInfo != null) {
        ///如果是导航菜单，则检查最后一次点击子页面，让子页面走得到焦点
        TabPageInfo? info = _navPages[tabPageInfo.uniqueId];
        if (info != null) {
          Widget tempPage = info.pages[info.checkPageIndex];
          _pageOnResume(tempPage);
        }
      } else {
        _pageOnResume(oldPage);
      }

      _pageOnPause(tempPage);
      notifyListeners();
      return Future.value(true);
    }
    return _confirmExit();
  }

  bool canPop() {
    return _pages.length > 1;
  }

  bool _onPopPage(Route route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }
    if (canPop()) {
      Page page = _pages.removeLast();

      TabPageInfo? tabPageInfo = _isTabPage((page as MaterialPage).child);
      if (tabPageInfo != null) {
        ///如果是导航菜单，则检查最后一次点击子页面，让子页面走得到焦点
        TabPageInfo? info = _navPages[tabPageInfo.uniqueId];
        if (info != null) {
          Widget tempPage = info.pages[info.checkPageIndex];
          _pageOnPause(tempPage);
        }
      } else {
        _pageOnPause(oldPage);
      }

      if (_pages.isNotEmpty) {
        Widget page = (_pages.last as MaterialPage).child;
        TabPageInfo? tabPageInfo = _isTabPage(page);
        if (tabPageInfo != null) {
          ///如果是导航菜单，则检查最后一次点击子页面，让子页面走得到焦点
          TabPageInfo? info = _navPages[tabPageInfo.uniqueId];
          if (info != null) {
            Widget tempPage = info.pages[info.checkPageIndex];
            _pageOnResume(tempPage);
          }
        } else {
          _pageOnResume(page);
        }
      }
      return true;
    }
    return false;
  }

  void push(
      {required Widget page,
      String? name,
      Object? arguments,
      Duration duration = const Duration(milliseconds: 300)}) {
    ///旧界面先失去焦点
    if (oldPage != page && oldPage != null) {
      TabPageInfo? tabPageInfo = _isTabPage(oldPage);
      if (tabPageInfo != null) {
        ///如果是导航菜单，则检查最后一次点击子页面，让子页面走得到焦点
        TabPageInfo? info = _navPages[tabPageInfo.uniqueId];
        if (info != null) {
          Widget tempPage = info.pages[info.checkPageIndex];
          _pageOnPause(tempPage);
        }
      } else {
        _pageOnPause(oldPage);
      }
    }

    var routeSettings = RouteSettings(
        name: name ?? page.runtimeType.toString(), arguments: arguments);

    if (_pages.isNotEmpty) {
      oldPage = (_pages.last as MaterialPage).child;
    }

    ///展示新界面
    _pages.add(MaterialPage(
        child: page,
        name: routeSettings.name,
        arguments: routeSettings.arguments,
        restorationId: page.hashCode.toString()));

    notifyListeners();

    ///让新界面得到焦点回调
    Future.delayed(duration, () {
      _addTabPage(page);
      _pageOnResume(page);
    });
  }

  void _addTabPage(Widget page) {
    TabPageInfo? info = _isTabPage(page);
    if (info?.pageType == PageType.tabPage) {
      if (null != info) {
        _navPages[info.uniqueId] = info;

        if (info.checkPageIndex < info.pages.length) {
          Widget page = info.pages[info.checkPageIndex];
          oldPage = page;
          _pageOnResume(page);
        } else {
          print("检查初始化需要得到焦点的界面下标是否正确");
        }
      }
      return;
    }
  }

  TabPageInfo? _isTabPageChild(Widget? page) {
    if (page == null) {
      return null;
    }
    for (var value in _navPages.values) {
      if (value.pages.contains(page)) {
        return value;
      }
    }
    return null;
  }

  TabPageInfo? _isTabPage(Widget? page) {
    if (page == null) {
      return null;
    }

    ///StatefulWidget
    if (page is StatefulLifeCycle) {
      State? state = page.statefulState.getState();
      if (state is TabPageObserve) {
        TabPageInfo? info = (state as TabPageObserve).onCreateTabPage();
        info?.pageType = PageType.tabPage;
        return info;
      }
      return null;
    }

    ///StatelessWidget
    if (page is TabPageObserve) {
      TabPageInfo? info = (page as TabPageObserve).onCreateTabPage();
      info?.pageType = PageType.tabPage;
      return null;
    }

    return null;
  }

  void _pageOnResume(Widget? page) {
    if (page == null) {
      return;
    }
    PageType pageType = _checkLifeCyclePage(page);
    if (pageType == PageType.statefulLifeCycle) {
      var state = (page as StatefulLifeCycle).statefulState.getState();
      (state as LifeCycle).onResume();
      return;
    }

    if (pageType == PageType.statelessLifeCycle) {
      (page as LifeCycle).onResume();
      return;
    }
  }

  void _pageOnPause(Widget? page) {
    if (page == null) {
      return;
    }
    PageType pageType = _checkLifeCyclePage(page);
    if (pageType == PageType.statefulLifeCycle) {
      var state = (page as StatefulLifeCycle).statefulState.getState();
      (state as LifeCycle).onPause();
      return;
    }

    if (pageType == PageType.statelessLifeCycle) {
      (page as LifeCycle).onPause();
      return;
    }
  }

  PageType _checkLifeCyclePage(Widget page) {
    ///StatefulWidget
    if (page is StatefulLifeCycle) {
      State? state = page.statefulState.getState();
      if (state is LifeCycle) {
        return PageType.statefulLifeCycle;
      }
      return PageType.notLifeCycle;
    }

    ///StatelessWidget
    if (page is LifeCycle) {
      return PageType.statelessLifeCycle;
    }

    ///没有监听生命周期的页面
    return PageType.notLifeCycle;
  }

  void replace({required Widget page, String? name, Object? arguments}) {
    if (_pages.isNotEmpty) {
      Page page = _pages.removeLast();
      _pageOnPause((page as MaterialPage).child);
    }
    push(page: page, name: name, arguments: arguments);
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
        context: navigatorKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            content: const Text('确定要退出App吗?'),
            actions: [
              TextButton(
                child: const Text('取消'),
                onPressed: () => Navigator.pop(context, true),
              ),
              TextButton(
                child: const Text('确定'),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          );
        });
    return result ?? true;
  }
}

enum PageType {
  ///没有实现监听的页面
  notLifeCycle,

  ///监听StatefulWidget
  statefulLifeCycle,

  ///监听StatelessWidget
  statelessLifeCycle,
  tabPage,
}

///设置tab菜单类导航界面
///uniqueId 标记该导航界面的id
///pages 该组导航界面列表
///checkPageIndex 初始化首次得到焦点回调的界面index
///通常用于 IndexedStack 或 PageView, TabBarView 中
class TabPageInfo {
  Object uniqueId;
  int checkPageIndex;
  List<Widget> pages;
  PageType? pageType;

  TabPageInfo(
      {required this.uniqueId,
      required this.pages,
      required this.checkPageIndex,
      this.pageType});
}
