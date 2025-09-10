# 🚀 Router Pro · 路由 & 生命周期感知工具

[![pub package](https://img.shields.io/pub/v/router_pro.svg)](https://pub.dev/packages/router_pro)
[![GitHub stars](https://img.shields.io/github/stars/zhengzaihong/router_lifecycle.svg?style=social)](https://github.com/zhengzaihong/router_lifecycle)
[![license](https://img.shields.io/github/license/zhengzaihong/router_lifecycle)](LICENSE)

[English](README.md) | 简体中文

---

## ✨ 为什么选择 Router Pro?

在 Flutter 开发中，页面往往需要像 Android 的 **Activity/Fragment** 一样具备生命周期能力（`onResume`、`onPause`、`onDestroy`），用于懒加载或提升性能体验。  
但 Flutter 的 **StatelessWidget/StatefulWidget** 并不原生支持这些特性。

**Router Pro 提供了解决方案：**

- 🔗 **路由代理**：更轻松的页面跳转与回退  
- ⏱ **生命周期感知**：Stateless/StatefulWidget 秒变 Activity/Fragment  
- 🪶 **解耦设计**：路由与生命周期独立使用  
- 🌍 **跨平台支持**：App & Web

---

## 🌟 特点总结

- ✅ Flutter 页面也能享受 **原生生命周期感知**
- ✅ 提供更优雅的 **路由跳转/关闭 API**
- ✅ **解耦设计**：路由和生命周期可单独使用
- ✅ 支持 **跨平台（App & Web）**

## 📦 安装

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  router_pro: ^0.1.1 //原flutter_router_forzzh：0.0.6（最后版本依赖地址，停止更新）
```

导入：

```dart
import 'package:router_pro/router_lib.dart';
```

---

## ⚡ 功能一：路由代理（RouterProxy）

### 全局注册

```dart
RouterProxy router = RouterProxy.getInstance(
  pageMap: {'/': const Login()},
  exitWindowStyle: _confirmExit,
);
```

```dart
MaterialApp.router(
  routerDelegate: router,
  routeInformationParser: router.defaultParser(),
);
```

### 页面跳转

```dart
router.push();  //跳转页面 widget方式
router.pushNamed(); //跳转页面 路由path方式
router.replace(); //替换当前页面
router.popAndPushNamed(); //pop当前页面，然后push一个新页面
router.pushAndRemoveAll();//清空页面栈并push新页面
router.pushNamedAndRemoveAll();// 跳转到指定页面，并清空之前的所有页面
router.pushStackTop();//将页面置于栈顶（如果已存在则先移除）

//举例：
router.push(
  page:const TaoBaoPageDetail(),
  onResult: (value){ //可选
    setState((){
      title = "淘宝页面$value";
    });
  });
router.pushNamed(
  name: '/TaoBaoPageDetail',
  onResult: (value){ //可选
    setState((){
      title = "淘宝页面$value";
    });
  });
```
### 页面关闭 & 回传

```dart
router.pop(); //关闭当前页面
router.popWithResult(); //关闭当前页面,主要用于（dailog,BottomSheet..）

举例：
router.popWithResult("返回值：hello"); //返回值可选
router.pop("返回值：hello"); //返回值可选
```

### 无需 context 的弹窗

```dart
router.showAppBottomSheet()
router.showAppDialog()
router.showAppSnackBar()

举例：
router.showAppBottomSheet(builder: (context){
     return  Container(
       height: 400,
       width: MediaQuery.of(context).size.width,
       color: Colors.red,
       child: GestureDetector(
         onTap: (){
           router.popWithResult("这是返回结果");
         },
         child: const Text('点击我获取BottomSheet返回值'),
       ),
     );
   }).then((value){
       debugPrint("showAppBottomSheet value:${value}");
});
```
---

## ⚡ 功能二：生命周期感知

让 **StatelessWidget / StatefulWidget** 具备 `onResume / onPause / onDestroy` 能力：

```dart
class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LifeCycle(
      onCreate: () => print("Login onCreate"),
      onStart: () => print("Login onStart"),
      onResume: () => print("Login onResume"),
      onPause: () => print("Login onPause"),
      onDestroy: () => print("Login onDestroy"),
      child: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => router.push(page: NavPage()),
            child: const Text("登录"),
          ),
        ),
      ),
    );
  }
}
```



---

## 🛠 其他说明

- `ExitWindowStyle`：可自定义退出程序提示框
- Web 端：支持浏览器直达，需要自定义 `RouteParser`



---

## 🎬 效果演示

![](https://github.com/zhengzaihong/router_lifecycle/blob/master/images/GIF.gif)


MIT License © [zhengzaihong](https://github.com/zhengzaihong)
