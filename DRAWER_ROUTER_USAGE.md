# 抽屉路由使用指南

## 概述

RouterProxy 现在支持多路由栈架构，可以创建独立的抽屉路由栈。每个抽屉路由栈都拥有完整的路由功能，包括路由守卫、启动模式、值回传等。

**重要特性：**
- ✅ **不需要 DrawerRouterStack**：直接使用封装 Widget 即可
- ✅ **自动刷新**：push 新页面时自动刷新抽屉显示最新页面
- ✅ **自动绑定**：无需手动调用 `bindDrawerContext()`
- ✅ **完整功能**：支持路由守卫、启动模式、值回传等所有路由功能

## 抽屉控制方法对比

RouterProxy 提供了两套抽屉控制方法，分别用于主路由栈和抽屉路由栈：

| 功能 | 主路由栈方法 | 抽屉路由栈方法 | 说明 |
|------|------------|--------------|------|
| 打开抽屉 | `openMainDrawer(isEndDrawer: true/false)` | `openDrawerStack()` | 主路由栈需要指定左右侧，抽屉栈根据配置自动判断 |
| 关闭抽屉 | `closeMainDrawer(isEndDrawer: true/false)` | `closeDrawerStack()` | 主路由栈需要指定左右侧，抽屉栈根据配置自动判断 |
| 检查状态 | `isMainDrawerOpen(isEndDrawer: true/false)` | `isDrawerStackOpen` | 主路由栈需要指定左右侧，抽屉栈根据配置自动判断 |
| 使用场景 | 控制主页面的 Scaffold 抽屉 | 控制抽屉路由栈自身的显示/隐藏 |

## 抽屉 Widget 对比

为了简化使用，提供了三种封装 Widget，自动处理 context 绑定：

| Widget | 使用场景 | 自定义程度 | 推荐度 |
|--------|---------|-----------|--------|
| **SimpleDrawerWidget** | 基本使用，只需设置宽度和背景色 | 低 | ⭐⭐⭐⭐⭐ |
| **StyledDrawerWidget** | 需要自定义样式（圆角、阴影、渐变等） | 中 | ⭐⭐⭐⭐ |
| **DrawerRouterWidget** | 需要完全自定义子组件 | 高 | ⭐⭐⭐ |
| **手动绑定** | 特殊需求，需要完全控制 | 最高 | ⭐⭐ |

### 使用对比

```dart
// 1. SimpleDrawerWidget（最简单，推荐）
endDrawer: SimpleDrawerWidget(
  router: drawerRouter,
  width: 300,
),

// 2. StyledDrawerWidget（自定义样式）
endDrawer: StyledDrawerWidget(
  router: drawerRouter,
  width: 300,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [BoxShadow(...)],
),

// 3. DrawerRouterWidget（自定义内容）
endDrawer: DrawerRouterWidget(
  router: drawerRouter,
  width: 300,
  child: CustomContent(),
),

// 4. 手动绑定（不推荐，容易遗漏）
endDrawer: Builder(
  builder: (context) {
    drawerRouter.bindDrawerContext(context);  // 容易忘记！
    return Container(
      width: 300,
      child: drawerRouter.build(context),
    );
  },
),
```

### 主路由栈方法示例

```dart
final router = RouterProxy.getInstance();

// 打开右侧抽屉
router.openMainDrawer(isEndDrawer: true);

// 打开左侧抽屉
router.openMainDrawer(isEndDrawer: false);

// 检查右侧抽屉是否打开
if (router.isMainDrawerOpen(isEndDrawer: true)) {
  print('右侧抽屉已打开');
}
```

### 抽屉路由栈方法示例

```dart
final drawerRouter = RouterProxy.getDrawerInstance(
  stackId: 'main-drawer',
  drawerConfig: DrawerConfig(isEndDrawer: true),
);

// 打开抽屉（根据 drawerConfig.isEndDrawer 自动判断左右侧）
drawerRouter.openDrawerStack();

// 关闭抽屉
drawerRouter.closeDrawerStack();

// 检查抽屉是否打开
if (drawerRouter.isDrawerStackOpen) {
  print('抽屉已打开');
}
```

## API 说明

### 1. 获取主路由实例（单例）

```dart
final router = RouterProxy.getInstance(
  pageMap: {'/': HomePage()},
  exitWindowStyle: _confirmExit,
);
```

### 2. 获取抽屉路由实例（多实例）

```dart
final drawerRouter = RouterProxy.getDrawerInstance(
  stackId: 'main-drawer',  // 必需：路由栈标识
  pageMap: {'/': DrawerHomePage()},
  drawerConfig: DrawerConfig(
    autoOpen: true,      // 首次 push 时自动打开抽屉
    autoClose: true,     // 栈为空时自动关闭抽屉
    isEndDrawer: true,   // 是否为右侧抽屉
  ),
);
```

### 3. 移除抽屉路由实例

```dart
RouterProxy.removeDrawerInstance('main-drawer');
```

## 完整使用示例

### 示例1：基本使用（推荐方式）

使用 `SimpleDrawerWidget` 自动处理 context 绑定：

```dart
import 'package:flutter/material.dart';
import 'package:router_pro/router_lib.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 创建抽屉路由实例
  late final RouterProxy drawerRouter;

  @override
  void initState() {
    super.initState();
    
    drawerRouter = RouterProxy.getDrawerInstance(
      stackId: 'main-drawer',
      pageMap: {
        '/': DrawerHomePage(),
        '/settings': DrawerSettingsPage(),
      },
      drawerConfig: DrawerConfig(
        autoOpen: true,
        autoClose: true,
        isEndDrawer: true,
      ),
    );
  }

  @override
  void dispose() {
    // 清理资源
    RouterProxy.removeDrawerInstance('main-drawer');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('主页')),
      // 使用 SimpleDrawerWidget，自动绑定 context
      endDrawer: SimpleDrawerWidget(
        router: drawerRouter,
        width: 300,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 打开抽屉并跳转到设置页
            drawerRouter.pushNamed(name: '/settings');
          },
          child: Text('打开抽屉设置'),
        ),
      ),
    );
  }
}

// 抽屉首页
class DrawerHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    
    return Column(
      children: [
        AppBar(
          title: Text('抽屉菜单'),
          automaticallyImplyLeading: false,
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('设置'),
          onTap: () {
            drawerRouter.push(page: DrawerSettingsPage());
          },
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text('关于'),
          onTap: () {
            drawerRouter.push(page: DrawerAboutPage());
          },
        ),
      ],
    );
  }
}

// 抽屉设置页
class DrawerSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    
    return Column(
      children: [
        AppBar(
          title: Text('设置'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => drawerRouter.pop(),
          ),
        ),
        ListTile(
          title: Text('通用设置'),
          onTap: () {
            drawerRouter.push(page: GeneralSettingsPage());
          },
        ),
        ListTile(
          title: Text('隐私设置'),
          onTap: () {
            drawerRouter.push(page: PrivacySettingsPage());
          },
        ),
      ],
    );
  }
}
```

### 示例1-B：手动绑定方式（不推荐）

如果你需要更多控制，也可以手动绑定：

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('主页')),
    endDrawer: Builder(
      builder: (context) {
        // 手动绑定 context
        drawerRouter.bindDrawerContext(context);
        return Container(
          width: 300,
          color: Colors.white,
          child: drawerRouter.build(context),
        );
      },
    ),
    body: MainContent(),
  );
}
```

### 示例2：自定义样式的抽屉

使用 `StyledDrawerWidget` 自定义抽屉样式：

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    endDrawer: StyledDrawerWidget(
      router: drawerRouter,
      width: 320,
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10,
          offset: Offset(-2, 0),
        ),
      ],
    ),
    body: MainContent(),
  );
}
```

### 示例3：使用路由守卫

```dart
// 创建抽屉路由并添加守卫
final drawerRouter = RouterProxy.getDrawerInstance(
  stackId: 'main-drawer',
  pageMap: {'/': DrawerHomePage()},
);

// 添加路由守卫
drawerRouter.addRouteGuard((from, to) async {
  // 某些页面需要权限
  if (to.uri.path == '/admin') {
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('权限不足'),
          content: Text('您没有访问此页面的权限'),
        ),
      );
      return false;
    }
  }
  return true;
});

// 使用
drawerRouter.pushNamed(name: '/admin');
```

### 示例4：使用启动模式

```dart
// SingleTop 模式：栈顶复用
drawerRouter.push(
  page: SettingsPage(theme: 'dark'),
  launchMode: LaunchMode.singleTop,
);

// SingleInstance 模式：全局唯一
drawerRouter.push(
  page: ProfilePage(),
  launchMode: LaunchMode.singleInstance,
);
```

### 示例5：值回传

```dart
// 跳转并接收返回值
drawerRouter.pushNamed(
  name: '/select-theme',
  onResult: (theme) {
    print('用户选择的主题: $theme');
    updateTheme(theme);
  },
);

// 在目标页面返回值
drawerRouter.pop('dark');
```

### 示例6：多个抽屉路由栈

```dart
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late final RouterProxy leftDrawer;
  late final RouterProxy rightDrawer;

  @override
  void initState() {
    super.initState();
    
    // 左侧抽屉
    leftDrawer = RouterProxy.getDrawerInstance(
      stackId: 'left-drawer',
      pageMap: {'/': LeftDrawerHome()},
      drawerConfig: DrawerConfig(
        isEndDrawer: false,  // 左侧抽屉
      ),
    );
    
    // 右侧抽屉
    rightDrawer = RouterProxy.getDrawerInstance(
      stackId: 'right-drawer',
      pageMap: {'/': RightDrawerHome()},
      drawerConfig: DrawerConfig(
        isEndDrawer: true,  // 右侧抽屉
      ),
    );
  }

  @override
  void dispose() {
    RouterProxy.removeDrawerInstance('left-drawer');
    RouterProxy.removeDrawerInstance('right-drawer');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 左侧抽屉
      drawer: SimpleDrawerWidget(
        router: leftDrawer,
        width: 250,
      ),
      // 右侧抽屉
      endDrawer: SimpleDrawerWidget(
        router: rightDrawer,
        width: 300,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => leftDrawer.openDrawerStack(),
              child: Text('打开左侧抽屉'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () => rightDrawer.openDrawerStack(),
              child: Text('打开右侧抽屉'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 示例7：手动控制抽屉

```dart
// 禁用自动打开/关闭
final drawerRouter = RouterProxy.getDrawerInstance(
  stackId: 'manual-drawer',
  drawerConfig: DrawerConfig(
    autoOpen: false,   // 禁用自动打开
    autoClose: false,  // 禁用自动关闭
  ),
);

// 手动打开抽屉
drawerRouter.openDrawerStack();

// 手动关闭抽屉
drawerRouter.closeDrawerStack();

// 检查抽屉状态
if (drawerRouter.isDrawerStackOpen) {
  print('抽屉已打开');
}

// 运行时修改配置
drawerRouter.configureDrawer(DrawerConfig(
  autoOpen: true,
  autoClose: true,
));
```

### 示例8：主路由栈控制抽屉

主路由栈也可以控制 Scaffold 的抽屉：

```dart
final router = RouterProxy.getInstance();

// 打开右侧抽屉
router.openMainDrawer(isEndDrawer: true);

// 打开左侧抽屉
router.openMainDrawer(isEndDrawer: false);

// 关闭右侧抽屉
router.closeMainDrawer(isEndDrawer: true);

// 关闭左侧抽屉
router.closeMainDrawer(isEndDrawer: false);

// 检查右侧抽屉是否打开
if (router.isMainDrawerOpen(isEndDrawer: true)) {
  print('右侧抽屉已打开');
}

// 检查左侧抽屉是否打开
if (router.isMainDrawerOpen(isEndDrawer: false)) {
  print('左侧抽屉已打开');
}
```

## 重要注意事项

### 1. 推荐使用封装 Widget

为了避免忘记绑定 context，强烈推荐使用以下封装 Widget：

#### SimpleDrawerWidget（推荐）

最简单的使用方式，自动处理 context 绑定：

```dart
endDrawer: SimpleDrawerWidget(
  router: drawerRouter,
  width: 300,
  backgroundColor: Colors.white,  // 可选
  padding: EdgeInsets.all(8),     // 可选
),
```

#### StyledDrawerWidget（自定义样式）

需要自定义样式时使用：

```dart
endDrawer: StyledDrawerWidget(
  router: drawerRouter,
  width: 320,
  backgroundColor: Colors.white,
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(16),
    bottomLeft: Radius.circular(16),
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 10,
      offset: Offset(-2, 0),
    ),
  ],
  gradient: LinearGradient(
    colors: [Colors.blue.shade50, Colors.white],
  ),
),
```

#### DrawerRouterWidget（完全自定义）

需要完全控制子组件时使用：

```dart
endDrawer: DrawerRouterWidget(
  router: drawerRouter,
  width: 300,
  child: CustomDrawerContent(),  // 自定义内容
),
```

### 2. Context 绑定（手动方式）

**必须**使用 `Builder` 包裹抽屉内容，并在 builder 中绑定 context（仅在不使用封装 Widget 时需要）：

```dart
// ✅ 正确（使用封装 Widget，推荐）
endDrawer: SimpleDrawerWidget(
  router: drawerRouter,
  width: 300,
),

// ✅ 正确（手动绑定）
endDrawer: Builder(
  builder: (context) {
    drawerRouter.bindDrawerContext(context);
    return Container(
      width: 300,
      child: drawerRouter.build(context),
    );
  },
),

// ❌ 错误：使用了根 context
endDrawer: Container(
  width: 300,
  child: drawerRouter.build(context),  // 这个 context 是错误的
),
```

### 3. 资源清理

在页面销毁时，记得移除抽屉路由实例：

```dart
@override
void dispose() {
  RouterProxy.removeDrawerInstance('main-drawer');
  super.dispose();
}
```

### 4. 获取抽屉路由实例

在抽屉内的页面中，可以通过 stackId 获取抽屉路由实例：

```dart
class DrawerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 获取抽屉路由实例
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => drawerRouter.push(page: NextPage()),
          child: Text('下一页'),
        ),
        ElevatedButton(
          onPressed: () => drawerRouter.pop(),
          child: Text('返回'),
        ),
      ],
    );
  }
}
```

### 5. 抽屉配置

`DrawerConfig` 的所有参数都是可选的：

```dart
DrawerConfig(
  autoOpen: true,       // 默认 true：首次 push 时自动打开抽屉
  autoClose: true,      // 默认 true：栈为空时自动关闭抽屉
  isEndDrawer: true,    // 默认 true：右侧抽屉
  width: 300,           // 可选：抽屉宽度
  backgroundColor: Colors.white,  // 可选：背景色
)
```

## 与 DrawerRouter 的对比

| 特性 | DrawerRouter（旧） | RouterProxy.getDrawerInstance（新） |
|------|-------------------|-------------------------------------|
| 路由守卫 | ❌ | ✅ |
| 启动模式 | ❌ | ✅ |
| 值回传 | ❌ | ✅ |
| 路由解析器 | ❌ | ✅ |
| 多实例支持 | ✅ | ✅ |
| 抽屉控制 | ✅ | ✅ |
| API 一致性 | ❌ | ✅ |

## 迁移指南

### 从 DrawerRouter 迁移

**旧代码：**
```dart
final drawerRouter = DrawerRouter.getInstance();

Scaffold(
  endDrawer: DrawerRouterStack(
    router: drawerRouter,
    bind: (context) => drawerRouter.bindDrawerNavigatorContext(context),
    builder: (context, child) {
      return Container(
        width: 300,
        child: drawerRouter.getCurrentPage(),
      );
    },
  ),
);

drawerRouter.push(page: SettingsPage());
```

**新代码：**
```dart
final drawerRouter = RouterProxy.getDrawerInstance(
  stackId: 'main-drawer',
);

Scaffold(
  endDrawer: Builder(
    builder: (context) {
      drawerRouter.bindDrawerContext(context);
      return Container(
        width: 300,
        child: drawerRouter.build(context),
      );
    },
  ),
);

drawerRouter.push(page: SettingsPage());
```

## 常见问题

### Q1: 还需要使用 DrawerRouterStack 吗？

A: **不需要！** 现在直接使用封装 Widget（`SimpleDrawerWidget`、`StyledDrawerWidget`、`DrawerRouterWidget`）即可，它们已经内置了所有必要的功能。

### Q2: push 新页面会自动刷新抽屉吗？

A: **会！** 所有封装 Widget 都会自动监听路由栈变化，当你调用 `drawerRouter.push()` 时，抽屉会自动刷新显示最新的页面。

```dart
// 示例：自动刷新
drawerRouter.push(page: SettingsPage());  // 抽屉自动显示 SettingsPage
drawerRouter.push(page: ProfilePage());   // 抽屉自动显示 ProfilePage
drawerRouter.pop();                       // 抽屉自动返回 SettingsPage
```

### Q3: 为什么必须使用 Builder 包裹？

A: **使用封装 Widget 时不需要！** 封装 Widget 内部已经自动处理了 context 绑定。只有在手动绑定时才需要使用 Builder。

### Q4: 可以在抽屉路由中使用路由守卫吗？

A: 可以！抽屉路由拥有完整的路由功能，包括路由守卫、启动模式等。

### Q5: 如何在抽屉内的页面中获取抽屉路由实例？

A: 使用 `RouterProxy.getDrawerInstance(stackId: 'your-stack-id')` 获取。

### Q6: 抽屉路由栈和主路由栈有什么区别？

A: 主要区别是：
- 主路由栈是单例，抽屉路由栈是多实例
- 抽屉路由栈有自动打开/关闭抽屉的功能
- 抽屉路由栈需要绑定 Scaffold 的 context

### Q7: 可以创建多个抽屉路由栈吗？

A: 可以！只需使用不同的 stackId 即可创建多个独立的抽屉路由栈。

## 总结

新的抽屉路由方案提供了：

1. ✅ 统一的 API（与主路由一致）
2. ✅ 完整的路由功能（守卫、启动模式、值回传等）
3. ✅ 多实例支持（可创建多个独立的抽屉路由栈）
4. ✅ 灵活的配置（自动打开/关闭、左右侧抽屉等）
5. ✅ 更好的资源管理（可手动移除实例）
6. ✅ **自动刷新**（push/pop 时自动更新抽屉显示）
7. ✅ **自动绑定**（无需手动调用 bindDrawerContext）
8. ✅ **无需 DrawerRouterStack**（直接使用封装 Widget）

### 自动刷新机制

所有封装 Widget（`SimpleDrawerWidget`、`StyledDrawerWidget`、`DrawerRouterWidget`）都实现了自动刷新机制：

```dart
// 创建抽屉路由
final drawerRouter = RouterProxy.getDrawerInstance(
  stackId: 'main-drawer',
  pageMap: {'/': HomePage()},
);

// 使用封装 Widget
Scaffold(
  endDrawer: SimpleDrawerWidget(
    router: drawerRouter,
    width: 300,
  ),
);

// 路由操作会自动刷新抽屉显示
drawerRouter.push(page: Page1());  // ✅ 抽屉自动显示 Page1
drawerRouter.push(page: Page2());  // ✅ 抽屉自动显示 Page2
drawerRouter.pop();                // ✅ 抽屉自动返回 Page1
```

**工作原理：**
1. 封装 Widget 在 `initState` 时监听 `RouterProxy` 的变化
2. 当调用 `push()`、`pop()` 等方法时，`RouterProxy` 会触发 `notifyListeners()`
3. 封装 Widget 收到通知后自动调用 `setState()` 刷新界面
4. 抽屉显示最新的页面栈顶页面

推荐使用新的封装 Widget 来创建抽屉路由栈！
