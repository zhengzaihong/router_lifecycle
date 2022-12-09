# 让widget具有生命周期

###前言：
 在flutter开发中很多时候需要你的页面像安卓中的Activity/Fragment具备生命周期的特性做懒加载来提升部分性能和体验，然而在
 flutter中StatelessWidget、StatefulWidget中并不具备检测页面是否运行在前台、后台、和销毁。尽管StatefulWidget中
 有销毁时的 dispose() 回调，但对于检查前后台，和StatelessWidget做页面时将变得力不从心....

 此工具库可快速让StatelessWidget、StatefulWidget具备Android中Activity/Fragment的 onResume、onPause、onDestroy的生命周期。

# pubspec.yaml 依赖
    dependencies:
      flutter_router_forzzh: ^0.0.1

#导包
      import 'package:flutter_router_forzzh/router_lib.dart';

####1.第一步 MaterialApp.router 注册RouterProxy

    RouterProxy  router = RouterProxy();

    void main() {
   	  runApp(MyApp());
   	}
   	
   	class MyApp extends StatelessWidget {
   	  MyApp({Key? key}) : super(key: key) {
   		router.push(page:  Login()); //第一个页面 
   	  }
   	
   	  @override
   	  Widget build(BuildContext context) {
   		return MaterialApp.router(
   		  title: 'router_lifecycle',
   		  debugShowCheckedModeBanner: false,
   		  routerDelegate: router, //绑定路由跳转工具
   		  routeInformationParser: router.defaultParser(),//路由解析器,可自定义传入
   		);
   	  }
   	}

####2.第二步对需要监听生命周期的页面实现接口

#####2.1 StatefulWidget页面：

   1.将原来的StatefulWidget页面修改为继承StatefulLifeCycle,并实现 getState()方法(将StatefulWidget中 createState()替换成 getState()即可 )
   
   2.state类中继承 LifeCycle类

   如下：

	class Login extends StatefulLifeCycle {

	  Login({Key? key}) : super(key: key);

	  @override
	  State<StatefulWidget> getState() => _LoginState();
	}

	class _LoginState extends State<Login> with LifeCycle{


	  @override
	  void onResume() {
		super.onResume();
		print("--------Login onResume");
	  }
	  @override
	  void onPause() {
		super.onPause();
		print("--------Login onPause");
	  }

	  @override
	  void onDestroy() {
		super.onDestroy();
		print("--------Login onDestroy");
	  }

	  @override
	  Widget build(BuildContext context) {
		return SizedBox();
	  }
	}

#####2.2 StatelessWidget页面：

	class TaoBaoPage extends StatelessWidget with LifeCycle {  //同样实现 LifeCycle接口
	  
	  TaoBaoPage({Key? key}) : super(key: key);
	  @override
	  Widget build(BuildContext context) {
		return Scaffold(
		  body: Column(
			children: [
			  Expanded(
				child: Center(
				  child: GestureDetector(
					onTap: () {
					  var page = TaoBaoPageDetail();
					  router.push(page: page);
					},
					child: const Text("淘宝页面"),
				  ),
				),
			  )
			],
		  ),
		);
	  }

	  @override
	  void onResume() {
		super.onResume();
		print("--------TaoBaoPage onResume");
	  }

	  @override
	  void onPause() {
		super.onPause();
		print("--------TaoBaoPage onPause");
	  }

	  @override
	  void onDestroy() {
		super.onDestroy();
		print("--------TaoBaoPage onDestroy");
	  }
	}

####3.容器导航类页面需实现子页面的监听
 
 1.实现TabPageObserve该接口，并覆写  onCreateTabPage()回调方法。

 2.在页面变化时 TabBarView、PageView、IndexedStack等容器页面中需要手动 router.setTabChange()通知子页面发生变化。
 
 例如：

	class NavPage extends StatefulLifeCycle {
	  NavPage({Key? key}) : super(key: key);

	  @override
	  State<StatefulWidget> getState() => _NavPageState();
	}

	class _NavPageState extends State<NavPage> with TabPageObserve {
	  final List<HomeBottomMenuBean> _bottomNavList = [
		HomeBottomMenuBean("淘宝", "taobao_icon_1.png", "taobao_icon_2.png", 0),
		HomeBottomMenuBean("京东", "jd_icon_1.png", "jd_icon_2.png", 1),
	  ];

	  int currentIndex = 0;
	  final List<Widget> pageList = [
		TaoBaoPage(),
		JdPage(),
	  ];

	  ///导航容器 必须实现该回调。
	  @override
	  TabPageInfo onCreateTabPage() {
		return TabPageInfo(
			uniqueId: pageList.hashCode, pages: pageList, checkPageIndex: 0);
	  }

	  @override
	  void dispose() {
		super.dispose();
		router.removeTabs(pageList.hashCode); //推出容器类型页面时 注意回收子页面
	  }

	  @override
	  Widget build(BuildContext context) {
		return Scaffold(
		  appBar: AppBar(),
		  body: IndexedStack(
			index: currentIndex,
			children: pageList,
		  ),
		  bottomNavigationBar: BottomNavigationBar(
			//配置选中的索引值
			currentIndex: currentIndex,
			onTap: (index) {
			  setState(() {
				currentIndex = index;

				///通知路由 子页面生命周期发生变化
				router.setTabChange(pageList[index], uniqueId: pageList.hashCode);
			  });
			},
			selectedFontSize: 22,
			unselectedFontSize: 16,
			unselectedItemColor: Colors.grey,
			fixedColor: Colors.red,
			showUnselectedLabels: true,
			type: BottomNavigationBarType.fixed,
			// BottomNavigationBarItem 包装的底部按钮
			items: [..._buildBottomMenus()],
		  ),
		);
	  }

	  List<BottomNavigationBarItem> _buildBottomMenus() {
		List<BottomNavigationBarItem> list = [];
		for (int i = 0; i < _bottomNavList.length; i++) {
		  BottomNavigationBarItem item = BottomNavigationBarItem(
			  label: _bottomNavList[i].name,
			  icon: currentIndex == i
				  ? _bottomIcon(homeImage(_bottomNavList[i].checkedIcon))
				  : _bottomIcon(homeImage(_bottomNavList[i].unCheckIcon)));

		  list.add(item);
		}
		return list;
	  }

	  Widget _bottomIcon(path) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 4),
			child: Image.asset(
			  path,
			  width: 26,
			  height: 26,
			  repeat: ImageRepeat.noRepeat,
			  fit: BoxFit.contain,
			  alignment: Alignment.center,
			));
	  }
	}

	String homeImage(String name) {
	  return "assets/images/home/$name";
	}

#####4.需要监听生命周期的子页面都需要同步骤2中 实现LifeCycle该接口
  
  4.1 页面的跳转使用 router.push(xxWidget);

  4.2 页面的关闭使用 router.pop(context);
  
其他：

 1.styleCallBack可自定义推出程序提示框

 2.web端需要支持浏览器直接跳转访问某页面需要自定义routeInformationParser并继承 RouteParser类做解析器


 


效果如下：

![](https://github.com/zhengzaihong/router_lifecycle/blob/master/images/GIF.gif)