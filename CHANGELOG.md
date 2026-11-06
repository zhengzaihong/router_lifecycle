## 0.2.2 

### 修复

- 命名路由与 `MaterialApp.router` 共享同一个 `RouteInformationParser`：`pushNamed` / `setNewRoutePath` 会把解析后的 `state`（路径参数、查询参数、匹配模式）传给路由回调，`pageMap` 改用 URI path 查找
- 所有导航操作在修改页面栈前先执行路由守卫与页面类型守卫；`replace`、`popAndPushNamed`、`pushAndRemoveAll`、`pushNamedAndRemoveAll` 被拦截时不再丢失页面
- `pushNamed` 不再提前改写 `_location`，路由守卫只执行一次
- 每个页面生成唯一 `Key`，修正 `standard` / `singleTop` / `singleInstance` 的页面匹配与重建语义
- `setNewRoutePath` 改为按页面栈定位，浏览器前进/后退不再丢页或重复入栈
- 页面栈为空时回退到 404 页面，`getCurrentPage` / `getCurrentMaterialPage` 不再抛 `RangeError`
- 最低 SDK 约束修正为 Dart 3.4 / Flutter 3.24，与 `onDidRemovePage`、`onPopInvokedWithResult` 等 API 保持一致

### 优化

- 路由模板中的正则元字符（如 `.`、`+`、`*`）现在按字面量转义，避免越权匹配与 ReDoS
- `EnhancedParser` 的别名与默认路由解析失败时不再抛异常；`RouteParams.fromState` 兼容动态 Map
- `getArguments<T>()` 类型不匹配时返回 null，不再抛 `TypeError`
- 新增 `normalizeRoutePath()`；守卫示例改用 `uri.path` + 规范化匹配，避免 query、尾斜杠绕过
- 导航操作通过串行队列执行，守卫 `await` 期间页面栈不再被交错修改
- `LifeCycle` dispose 时清理 `VisibilityDetector` 缓存；`visibilityThreshold = 0.0` 不再在 0% 可见时触发 `onResume`
- `RouterProxy.dispose()` 释放页面栈、抽屉上下文和静态引用；`DrawerStackController.dispose()` 支持 `disposeRouter`
- `VisibilityDetector` 回调处理改为快照 + 防重入，回调中调用 `notifyNow` / `forget` 不再抛 `ConcurrentModificationError`
- `VisibilityDetector` 在图层链异常或 Sliver geometry 为空时安全降级
- 新增 `RouterProxy.debugLogging` / `DrawerStackController.debugLogging` 日志开关，release 默认关闭路由日志
- `DrawerNavigator` 支持 `controller` 变更时切换监听

### 工程质量

- analyzer 开启 `strict-casts` / `strict-inference` / `strict-raw-types`，`flutter_lints` 升级到 4.x
- 新增 GitHub Actions CI：格式检查、静态分析、测试与覆盖率产物
- 新增 `.pubignore`，排除学习笔记与平台工程目录；不再忽略 `example/test/`
- 补齐 pub 发布元数据（`repository` / `issue_tracker` / `topics`），`uses-material-design` 改为 `true`
- `ResultCallback` / `PopInvokedWithResultCallback` 去掉无意义的 `dynamic`；`push` / `pop` 移除未使用的泛型参数
- `RouterProxy` 的顶层辅助类拆分到 `router_proxy_internal.dart`
- 示例修复：`LifeCycle` 回调中的 `setState` 增加 `mounted` 保护，可见性计数与曝光统计改用集合去重
- README 中英双版功能编号统一为 Feature 1-5 / 功能一至功能五

---

## 0.2.1

### 修复

- 主路由栈抽屉控制方法现在会自动绑定当前页面的 `Scaffold`，并保留 `bindMainScaffoldKey(...)` 作为显式绑定入口
- 替换已废弃的 `Navigator.onPopPage` 用法，改为当前推荐的页面移除回调
- 更新 `VisibilityDetector` 的裁剪区域计算，适配当前 Flutter 渲染 API
- 修正示例中的页面返回 API 使用和静态检查问题

### 维护

- 清理库内过时的作者/时间模板注释，改为面向 API 的说明
- 移除无用的 plugin 模板配置和未使用依赖
- 调整最低 SDK 约束到 Dart 3.4 / Flutter 3.24，以匹配当前代码实际依赖的 API

---

## 0.2.0

### 🎉 新增功能

- **路由启动模式**: 支持三种启动模式（Standard、SingleTop、SingleInstance），类似Android Activity启动模式
- **路由导航守卫**: 支持路由拦截，可用于权限验证、登录检查等场景
- **命名路由值回传**: 支持通过命名路由跳转并接收返回值
- **404错误页面**: 支持自定义未找到路由的错误页面
- **生命周期可见性阈值**: LifeCycle组件支持自定义可见比例阈值（visibilityThreshold）
- **生命周期调试模式**: LifeCycle组件支持调试标签（debugLabel），输出详细日志
- **VisibilityInfo便捷属性**: 新增 `isVisible`、`isInvisible`、`isFullyVisible`、`isPartiallyVisible` 属性
- **完善文档**: 新增完整的使用示例和场景说明，包括可见性检测示例

### 🔧 改进

- 优化路由栈管理逻辑
- 增强 `push()` 和 `pushNamed()` 方法，支持 `launchMode` 参数
- 改进路由跳转前的守卫检查机制
- 优化 LifeCycle 组件的可见性检测逻辑
- 改进生命周期回调的触发时机
- 优化 VisibilityDetector 代码，移除冗余的 null 检查
- 改进 VisibilityInfo 的 toString 方法，显示更多信息
- 添加 hashCode 和 == 操作符实现

### 📝 API 变更

**RouterProxy:**
- `RouterProxy.getInstance()` 新增 `notFoundPage` 参数
- `push()` 方法新增 `launchMode` 参数
- `pushNamed()` 方法新增 `launchMode` 参数
- 新增 `addRouteGuard()` 方法
- 新增 `removeRouteGuard()` 方法
- 新增 `clearRouteGuards()` 方法

**新增类:**
- `EnhancedParser` - 增强的路由解析器
- `RoutePattern` - 路由模式匹配类
- `RouteParams` - 路由参数辅助类


**LifeCycle:**
- 新增 `visibilityThreshold` 参数（默认1.0）
- 新增 `debugLabel` 参数
- 改进可见性检测逻辑，支持自定义阈值

**VisibilityInfo:**
- 新增 `isVisible` getter
- 新增 `isInvisible` getter
- 新增 `isFullyVisible` getter
- 新增 `isPartiallyVisible` getter
- 改进 `toString()` 方法
- 新增 `hashCode` 和 `==` 操作符

### ⚠️ 破坏性变更

无。此版本完全向后兼容 0.1.x 版本。

---

## 0.1.1

### Features

- 路由代理功能
- 生命周期感知
- 无需Context的弹窗支持

---

## 0.0.1

initial release.

