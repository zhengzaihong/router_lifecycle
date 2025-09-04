# 路由工具和感知Widget声明周期

Language: [English](README.md) | 简体中文


###前言：
 在Flutter开发中很多时候需要你的页面像安卓中的Activity/Fragment具备生命周期的特性做懒加载来提升部分性能和体验，然而在
 flutter中StatelessWidget、StatefulWidget中并不具备检测页面是否运行在前台、后台、和销毁。尽管StatefulWidget中
 有销毁时的 dispose() 回调，但对于检查前后台，StatelessWidget做页面时将变得力不从心....

 此工具库可快速让StatelessWidget、StatefulWidget具备Android中Activity/Fragment的 onResume、onPause、onDestroy的生命周期。
 此库已将原来页面跳转工具和生命周期功能独立拆开，不再耦合。可分别使用。

# pubspec.yaml 依赖
    dependencies:
      router_plus: ^0.1.0 // 原flutter_router_forzzh：0.0.6（最后版本依赖地址，停止更新）

#### 导包 import 'package:router_plus/router_lib.dart';

# 功能1：

#### 1.路由功能实现界面跳转。

##### 顶层定义router方便全局使用。

      RouterProxy router = RouterProxy.getInstance(
          // routePathCallBack: (routeInformation) {
          //   print('routeInformation.location:${routeInformation.uri}');
          //   //自定义的动态路由 跳转
          //   if (routeInformation.uri.toString() == 'TaoBaoPageDetail1') {
          //     return JdPageDetail();
          //   }
          // },
          // navigateToTargetCallBack: (context,page){
          //   router.currentTargetPage.value = page;
          // },
          pageMap: {'/': const Login()},
          exitWindowStyle:_confirmExit
      );
      
      Future<bool> _confirmExit(BuildContext context) async {
        final result = await showDialog<bool>(
            context: context,
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


##### 2.MaterialApp.router 注册RouterProxy

    void main() {
   	  runApp(MyApp());
   	}
   	
   	class MyApp extends StatelessWidget {
   	  MyApp({Key? key}) : super(key: key)
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


    1 页面的跳转使用 router.push(); router.pushNamed()等
    
    2 页面的关闭使用 router.pop();



# 功能2：

#### 2.对需要监听生命周期的页面做任务。

#####2.1 StatefulWidget页面：

#####2.2 StatelessWidget页面：

	class Login extends StatelessWidget {
    const Login({Key? key}) : super(key: key);
    @override
    Widget build(BuildContext context) {
      return LifeCycle(
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
    }}


其他：

 1.exitWindowStyle:可自定义退出程序提示框

 2.web端需要支持浏览器直接跳转访问某页面需要自定义routeInformationParser并继承 RouteParser类做解析器


效果如下：

![](https://github.com/zhengzaihong/router_lifecycle/blob/master/images/GIF.gif)