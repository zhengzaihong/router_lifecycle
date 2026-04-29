# 🚀 Router Pro · Routing & Lifecycle Awareness Tools

[![pub package](https://img.shields.io/pub/v/router_pro.svg)](https://pub.dev/packages/router_pro)
[![GitHub stars](https://img.shields.io/github/stars/zhengzaihong/router_lifecycle.svg?style=social)](https://github.com/zhengzaihong/router_lifecycle)
[![license](https://img.shields.io/github/license/zhengzaihong/router_lifecycle)](LICENSE)

[English](README.md) | 简体中文

---

## ✨ 为什么选择 Router Pro?

在 Flutter 开发中，页面往往需要像 Android 的 **Activity/Fragment** 一样具备生命周期能力（`onResume`、`onPause`、`onDestroy`），用于懒加载或提升性能体验。  
但 Flutter 的 **StatelessWidget/StatefulWidget** 并不原生支持这些特性。

**Router Pro 提供了完整的解决方案：**

- 🔗 **路由代理**：更轻松的页面跳转与回退  
- ⏱ **生命周期感知**：Stateless/StatefulWidget 秒变 Activity/Fragment  
- 🚀 **路由启动模式**：支持标准、栈顶复用、单例三种模式
- 🛡️ **路由守卫**：支持路由拦截，实现权限验证
- 🎯 **命名路由值回传**：支持通过命名路由传递和接收数据
- 🪶 **解耦设计**：路由与生命周期独立使用  
- 🌍 **跨平台支持**：App & Web

---

## 🌟 特点总结

- ✅ Flutter 页面也能享受 **原生生命周期感知**
- ✅ 提供更优雅的 **路由跳转/关闭 API**
- ✅ **解耦设计**：路由和生命周期可单独使用
- ✅ 支持 **跨平台（App & Web）**
- ✅ 支持 **路由启动模式**（标准、栈顶复用、单例）
- ✅ 支持 **命名路由值回传**
- ✅ 支持 **路由导航守卫**（拦截器）
- ✅ 支持 **404错误页面**自定义
- ✅ 无需 BuildContext 即可使用路由功能

## 📦 安装

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  router_pro: ^0.2.0
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
  notFoundPage: const NotFoundPage(), // 可选：自定义404页面
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
  launchMode: LaunchMode.standard, // 可选：启动模式
  onResult: (value){ //可选
    setState((){
      title = "淘宝页面$value";
    });
  });
router.pushNamed(
  name: '/TaoBaoPageDetail',
  launchMode: LaunchMode.singleTop, // 可选：启动模式
  onResult: (value){ //可选：支持命名路由值回传
    setState((){
      title = "淘宝页面$value";
    });
  });
```

### 路由启动模式

支持三种启动模式，类似Android的Activity启动模式：

```dart
// 1. 标准模式（默认）- 允许同一页面多个实例存在
router.push(
  page: const DetailPage(),
  launchMode: LaunchMode.standard,
);

// 2. 栈顶复用 - 如果目标页面已在栈顶，则不创建新实例
router.push(
  page: const DetailPage(),
  launchMode: LaunchMode.singleTop,
);

// 3. 单例模式 - 整个栈中只保留一个实例，如果已存在则移到栈顶
router.push(
  page: const DetailPage(),
  launchMode: LaunchMode.singleInstance,
);
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

### 路由导航守卫

支持路由拦截，可用于权限验证、登录检查等场景：

```dart
// 添加路由守卫
router.addRouteGuard((from, to) async {
  // 需要登录才能访问的页面
  final protectedRoutes = ['/profile', '/settings'];
  final isLoggedIn = await checkLoginStatus();
  
  if (protectedRoutes.contains(to.uri.toString()) && !isLoggedIn) {
    // 拦截跳转，跳转到登录页
    router.pushNamed(name: '/login');
    return false; // 返回false拦截跳转
  }
  return true; // 返回true允许跳转
});

// 移除路由守卫
router.removeRouteGuard(guard);

// 清空所有路由守卫
router.clearRouteGuards();
```

### 404错误页面

支持自定义未找到路由的错误页面：

```dart
RouterProxy router = RouterProxy.getInstance(
  pageMap: {'/': const HomePage()},
  notFoundPage: const Custom404Page(), // 自定义404页面
);

// 访问不存在的路由时会显示404页面
router.pushNamed(name: '/not-exist');
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

### 高级特性

**可见性阈值**：自定义触发 onResume 的可见比例

```dart
LifeCycle(
  visibilityThreshold: 0.5, // 50%可见时就触发onResume，默认1.0（完全可见）
  onResume: () => print('页面50%可见'),
  child: YourWidget(),
)
```

**调试模式**：输出生命周期日志

```dart
LifeCycle(
  debugLabel: 'HomePage', // 启用调试日志
  onCreate: () => print('创建'),
  onResume: () => print('可见'),
  child: YourWidget(),
)
// 输出: [LifeCycle:HomePage] onCreate
// 输出: [LifeCycle:HomePage] onResume (widget visible: 100.0%)
```

---

## ⚡ 功能三：可见性检测（VisibilityDetector）

底层可见性检测组件，支持精确的可见性监控。

### 基本用法

```dart
VisibilityDetector(
  key: Key('my-widget'),
  onVisibilityChanged: (info) {
    print('可见比例: ${info.visibleFraction}');
    
    // 使用便捷属性
    if (info.isFullyVisible) {
      print('完全可见');
    } else if (info.isPartiallyVisible) {
      print('部分可见');
    } else if (info.isInvisible) {
      print('不可见');
    }
  },
  child: YourWidget(),
)
```

### 应用场景

**1. 懒加载图片**

```dart
VisibilityDetector(
  key: Key('image-$index'),
  onVisibilityChanged: (info) {
    if (info.visibleFraction >= 0.5 && !imageLoaded) {
      loadImage(); // 50%可见时加载图片
    }
  },
  child: Image.network(imageUrl),
)
```

**2. 视频自动播放**

```dart
VisibilityDetector(
  key: Key('video-$index'),
  onVisibilityChanged: (info) {
    if (info.visibleFraction >= 0.8) {
      videoController.play(); // 80%可见时播放
    } else if (info.isInvisible) {
      videoController.pause(); // 不可见时暂停
    }
  },
  child: VideoPlayer(videoController),
)
```

**3. 曝光统计**

```dart
VisibilityDetector(
  key: Key('item-$index'),
  onVisibilityChanged: (info) {
    if (info.isFullyVisible) {
      trackExposure(itemId); // 完全可见时统计曝光
    }
  },
  child: ProductCard(product),
)
```

**4. 列表项可见性监控**

```dart
ListView.builder(
  itemBuilder: (context, index) {
    return VisibilityDetector(
      key: Key('list-item-$index'),
      onVisibilityChanged: (info) {
        print('Item $index: ${(info.visibleFraction * 100).toInt()}% 可见');
      },
      child: ListTile(title: Text('Item $index')),
    );
  },
)
```

### VisibilityInfo 属性

- `visibleFraction`: 可见比例 (0.0 - 1.0)
- `isVisible`: 是否可见 (> 0%)
- `isInvisible`: 是否不可见 (0%)
- `isFullyVisible`: 是否完全可见 (100%)
- `isPartiallyVisible`: 是否部分可见 (0% - 100%)
- `size`: 组件大小
- `visibleBounds`: 可见区域边界

### 控制器配置

```dart
// 设置更新间隔
VisibilityDetectorController.instance.updateInterval = Duration(milliseconds: 300);

// 立即触发所有回调
VisibilityDetectorController.instance.notifyNow();

// 清除特定组件的回调
VisibilityDetectorController.instance.forget(Key('my-widget'));

// 获取组件边界
final bounds = VisibilityDetectorController.instance.widgetBoundsFor(Key('my-widget'));
```



---

##  使用场景示例

### 场景1：登录验证守卫

```dart
void initRouter() {
  final router = RouterProxy.getInstance(
    pageMap: {'/': HomePage(), '/login': LoginPage(), '/profile': ProfilePage()},
  );

  // 添加登录验证守卫
  router.addRouteGuard((from, to) async {
    final protectedRoutes = ['/profile', '/settings', '/orders'];
    if (protectedRoutes.contains(to.uri.toString())) {
      final isLoggedIn = await checkLoginStatus();
      if (!isLoggedIn) {
        router.pushNamed(name: '/login');
        return false;
      }
    }
    return true;
  });
}
```

### 场景2：视频播放页面生命周期

```dart
class VideoPlayerPage extends StatefulWidget {
  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network('video_url');
  }

  @override
  Widget build(BuildContext context) {
    return LifeCycle(
      visibilityThreshold: 0.8,            // 80%可见时播放
      debugLabel: 'VideoPlayer',           // 调试日志
      onResume: () => _controller.play(),  // 页面可见时播放
      onPause: () => _controller.pause(),  // 页面不可见时暂停
      onDestroy: () => _controller.dispose(), // 页面销毁时释放资源
      child: Scaffold(
        body: VideoPlayer(_controller),
      ),
    );
  }
}
```

### 场景3：购物车单例模式

```dart
// 购物车页面在整个应用中只保留一个实例
router.push(
  page: const ShoppingCartPage(),
  launchMode: LaunchMode.singleInstance,
);
```

### 场景4：自定义404页面

```dart
class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('页面未找到')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text('404', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            Text('抱歉，您访问的页面不存在'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => router.goRootPage(),
              child: Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎬 效果演示

![](https://github.com/zhengzaihong/router_lifecycle/blob/master/images/GIF.gif)

---

## 📋 快速参考

### 路由跳转
```dart
router.push(page: MyPage());                                    // Widget跳转
router.pushNamed(name: '/page');                                // 命名路由跳转
router.push(page: MyPage(), launchMode: LaunchMode.singleTop);  // 栈顶复用
router.push(page: MyPage(), launchMode: LaunchMode.singleInstance); // 单例模式
```

### 路由关闭
```dart
router.pop();                      // 关闭当前页
router.pop('返回数据');             // 关闭并返回数据
router.popWithResult('返回数据');   // 用于Dialog/BottomSheet
```

### 路由守卫
```dart
router.addRouteGuard((from, to) async {
  // 返回 true 允许跳转，false 拦截
  return true;
});
```

### 弹窗
```dart
router.showAppDialog(builder: (ctx) => AlertDialog(...));
router.showAppBottomSheet(builder: (ctx) => Container(...));
router.showAppSnackBar(message: '提示信息');
```

### 生命周期
```dart
// 基础用法
LifeCycle(
  onResume: () => print('页面可见'),
  onPause: () => print('页面不可见'),
  onDestroy: () => print('页面销毁'),
  child: YourWidget(),
)

// 高级用法
LifeCycle(
  visibilityThreshold: 0.5,  // 50%可见时触发
  debugLabel: 'MyPage',      // 调试日志
  onResume: () => print('可见'),
  child: YourWidget(),
)
```

---

## 🔄 版本迁移

### 从 0.1.x 升级到 0.2.0

版本 0.2.0 **完全向后兼容**，所有现有代码无需修改即可正常工作。

**新增功能（可选使用）：**
- 路由启动模式（`launchMode` 参数）
- 路由导航守卫（`addRouteGuard` 方法）
- 命名路由值回传（`pushNamed` 的 `onResult` 参数）
- 自定义404页面（`notFoundPage` 参数）

**升级步骤：**
```yaml
# 更新 pubspec.yaml
dependencies:
  router_pro: ^0.2.0
```

```bash
flutter pub get
```

---

## 📝 完整示例

查看 [example/lib/main.dart](example/lib/main.dart) 获取完整的示例代码，包含：
- ✅ 所有路由启动模式的演示
- ✅ 命名路由值回传
- ✅ 路由守卫拦截
- ✅ 404错误页面
- ✅ 生命周期感知
- ✅ 可见性检测应用场景

运行示例：
```bash
cd example
flutter run
```

---

## 🛠 其他说明

- `ExitWindowStyle`：可自定义退出程序提示框
- Web 端：支持浏览器直达，需要自定义 `RouteParser`
- 完整 API 文档：查看源码注释

---

## 📄 更新日志

### v0.2.0
- ✅ 新增路由启动模式（Standard、SingleTop、SingleInstance）
- ✅ 新增路由导航守卫功能
- ✅ 新增命名路由值回传支持
- ✅ 新增404错误页面自定义
- ✅ 优化路由栈管理

### v0.1.1
- 路由代理功能
- 生命周期感知
- 无需Context的弹窗支持

---

MIT License © [zhengzaihong](https://github.com/zhengzaihong)
