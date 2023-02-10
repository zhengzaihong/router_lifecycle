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
typedef RoutePathCallBack = Future<void> Function(List<RouteSettings> configuration,List<Page> pages);

typedef ExitStyleCallBack =  Future<bool> Function(BuildContext context);

class RouterProxy extends RouterDelegate<List<RouteSettings>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<RouteSettings>> {

  RoutePathCallBack? routePathCallBack;
  ExitStyleCallBack? styleCallBack;

  RouterProxy({this.styleCallBack,this.routePathCallBack}):super();

  CustomParser defaultParser(){
    return const CustomParser();
  }

  ///请不要将多个需要监听的导航列表设置相同的key
  final Map<Object, TabPageInfo> _navPages = HashMap();

  final List<Page> _pages = [];

  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  List<Page> get currentConfiguration => List.of(_pages);

  Widget? prePage;

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

  ///需要手动调用此方法，需同步 IndexedStack 或者 TabBarView下 controller.index下的page
  ///带有导航菜单类容器界面请使用 StatefulWidget 方便手动回收 removeTabs 界面。
  void setTabChange(Widget page, {Object? uniqueId}) {
    if (page == prePage) {
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
    // _pageOnPause(prePage);

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
    prePage = targetPage;
    return false;
  }

  ///关闭页面，需要监听生命周期的务必使用此方法关闭
  void pop(BuildContext context) {

    String id = context.widget.hashCode.toString();
    Page? materialPage = _findPage(id);
    if (materialPage != null) {
      _pages.remove(materialPage);
      _pageOnPause((materialPage as MaterialPage).child,destroy: true);
    }

    if (_pages.isNotEmpty) {
      prePage = (_pages.last as MaterialPage).child;
    }
    TabPageInfo? tabPageInfo = _isTabPage(prePage);
    if (tabPageInfo != null) {
      ///如果是导航菜单，则检查最后一次点击子页面，让子页面走得到焦点
      TabPageInfo? info = _navPages[tabPageInfo.uniqueId];
      if (info != null) {
        Widget tempPage = info.pages[info.checkPageIndex];
        _pageOnResume(tempPage);
      }
    } else {
      _pageOnResume(prePage);
    }
    notifyListeners();
  }

  Page? _findPage(String id) {
    Page? materialPage;
    for (var page in _pages) {
      if (page.restorationId == id) {
        materialPage = page;
        break;
      }
    }
    return materialPage;
  }

  @override
  Future<void> setNewRoutePath(List<RouteSettings> configuration) {
    return routePathCallBack==null?Future.value(null): routePathCallBack!.call(configuration,_pages);
  }

  @override
  Future<bool> popRoute() {
    if (canPop()) {
      Page page = _pages.removeLast();
      Widget tempPage = (page as MaterialPage).child;

      if (_pages.isNotEmpty) {
        prePage = (_pages.last as MaterialPage).child;
      } else {
        prePage = null;
      }

      // print("监听到物理返回键");
      TabPageInfo? tabPageInfo = _isTabPage(prePage);
      if (tabPageInfo != null) {
        ///如果是导航菜单，则检查最后一次点击子页面，让子页面走得到焦点
        TabPageInfo? info = _navPages[tabPageInfo.uniqueId];
        if (info != null) {
           Widget tabPage = info.pages[info.checkPageIndex];
          _pageOnResume(tabPage);
        }
      } else {
        _pageOnResume(prePage);
      }

      _pageOnPause(tempPage,destroy: true);
      notifyListeners();
      return Future.value(true);
    }

    ///外部可仿照传入 styleCallBack定制推出样式
    return styleCallBack ==null?Future.value(false):styleCallBack!.call(navigatorKey.currentContext!);
  }

  /// 例子：
  ///   Future<bool> _confirmExit(BuildContext context) async {
  ///     final result = await showDialog<bool>(
  ///         context: context,
  ///         builder: (context) {
  ///           return AlertDialog(
  ///             content: const Text('确定要退出App吗?'),
  ///             actions: [
  ///               TextButton(
  ///                 child: const Text('取消'),
  ///                 onPressed: () => Navigator.pop(context, true),
  ///               ),
  ///               TextButton(
  ///                 child: const Text('确定'),
  ///                 onPressed: () => Navigator.pop(context, false),
  ///               ),
  ///             ],
  ///           );
  ///         });
  ///     return result ?? true;
  ///   }

  bool canPop() => _pages.length > 1;

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
          _pageOnPause(tempPage,destroy: true);
        }
      } else {
        _pageOnPause(prePage,destroy: true);
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


    if (_pages.isNotEmpty) {
      prePage = (_pages.last as MaterialPage).child;
    }

    ///旧界面先失去焦点
    if (prePage != page && prePage != null) {
      TabPageInfo? tabPageInfo = _isTabPage(prePage);

      if (tabPageInfo != null) {
        ///如果是导航菜单，则检查最后一次点击子页面，让子页面走得到焦点
        TabPageInfo? info = _navPages[tabPageInfo.uniqueId];
        if (info != null) {
          Widget tempPage = info.pages[info.checkPageIndex];
          _pageOnPause(tempPage);
        }
      } else {
        _pageOnPause(prePage);
      }
    }

    var routeSettings = RouteSettings(
        name: name ?? page.runtimeType.toString(),
        arguments: arguments);

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
          prePage = page;
          _pageOnResume(page);
        } else {
          print("初始化页面下标越界");
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

  Widget? _isWrapperPage(Widget? page) {
    if (page == null) {
      return null;
    }
    ///StatefulWidget
    if (page is StatefulLifeCycle) {
      State? state = page.statefulState.getState();
      if (state is WrapperPage) {
        Widget? wrapper= (state as WrapperPage).getChild();
        return wrapper;
      }
      return null;
    }

    ///StatelessWidget
    if (page is WrapperPage) {
      Widget? wrapper= (page as WrapperPage).getChild();
      return wrapper;
    }
    return null;
  }



  void _pageOnResume(Widget? page) {
    if (page == null) {
      return;
    }
    var tempPage = _isWrapperPage(page);
    if(null!=tempPage){
      _pageOnResume(tempPage);
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

  void _pageOnPause(Widget? page,{bool destroy = false}) {
    if (page == null) {
      return;
    }
    var tempPage = _isWrapperPage(page);
    if(null!=tempPage){
      _pageOnPause(tempPage);
    }

    PageType pageType = _checkLifeCyclePage(page);
    if (pageType == PageType.statefulLifeCycle) {
      var state = (page as StatefulLifeCycle).statefulState.getState();
      (state as LifeCycle).onPause();
      if(destroy){
        (state as LifeCycle).onDestroy();
      }
      return;
    }

    if (pageType == PageType.statelessLifeCycle) {
      (page as LifeCycle).onPause();
      if(destroy){
        (page as LifeCycle).onDestroy();
      }
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
      _pageOnPause((page as MaterialPage).child,destroy: true);

    }
    push(page: page, name: name, arguments: arguments);
  }


  ///当退出容器tab 界面时回收内存
   TabPageInfo? removeTabs(Object? uniqueId){
    return _navPages.remove(uniqueId);
  }
}

enum PageType {

  ///没有实现监听的页面
  notLifeCycle,

  ///监听StatefulWidget
  statefulLifeCycle,

  ///监听StatelessWidget
  statelessLifeCycle,

  ///页面类型的页面监听生命周期
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
