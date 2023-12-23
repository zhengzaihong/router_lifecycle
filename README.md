# 让widget具有生命周期

###前言：
 在Flutter开发中很多时候需要你的页面像安卓中的Activity/Fragment具备生命周期的特性做懒加载来提升部分性能和体验，然而在
 flutter中StatelessWidget、StatefulWidget中并不具备检测页面是否运行在前台、后台、和销毁。尽管StatefulWidget中
 有销毁时的 dispose() 回调，但对于检查前后台，和StatelessWidget做页面时将变得力不从心....

 此工具库可快速让StatelessWidget、StatefulWidget具备Android中Activity/Fragment的 onResume、onPause、onDestroy的生命周期。

# pubspec.yaml 依赖
    dependencies:
      flutter_router_forzzh: ^0.0.3

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
#####2.2 StatelessWidget页面：

	class Login extends StatelessWidget {
    const Login({Key? key}) : super(key: key);
    @override
    Widget build(BuildContext context) {
      return LifeCyclePage(
        onCreate: (){
          print("--------Login onCreate");
        },
        onStart: (){
          print("--------Login onStart");
        },
        onResume: (){
          print("--------Login onResume");
        },
        onPause: (){
          print("--------Login onPause");
        },
        onDestroy: (){
          print("--------Login onDestroy");
        },
          child: Scaffold(
          body: Stack(
            children: [
              Container(
                constraints: const BoxConstraints.expand(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
  
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(
                          width: 16,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                          onPressed: () {},
                          child: const Text(
                            '注册',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            side: const BorderSide(color: Colors.black),
                          ),
                          onPressed: () {
                            router.push(page: NavPage());
                          },
                          child: const Text('登录', style: TextStyle(color: Colors.black),),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
      ));
    }
}


##### 需要监听生命周期的子页面都需要同步骤2中 实现LifeCycle该接口
  
  1 页面的跳转使用 router.push(xxWidget);

  2 页面的关闭使用 router.pop(context);


#####5.当跳转的页面是包裹页面，而子页面才是真正需要监听的时是 需要用WrapperPage接口包裹下，且为直接子类



其他：

 1.styleCallBack可自定义推出程序提示框

 2.web端需要支持浏览器直接跳转访问某页面需要自定义routeInformationParser并继承 RouteParser类做解析器


 


效果如下：

![](https://github.com/zhengzaihong/router_lifecycle/blob/master/images/GIF.gif)