## 0.2.1

### 修复

- 主路由栈抽屉控制方法现在会自动绑定当前页面的 `Scaffold`，并保留 `bindMainScaffoldKey(...)` 作为显式绑定入口
- 替换已废弃的 `Navigator.onPopPage` 用法，改为当前推荐的页面移除回调
- 更新 `VisibilityDetector` 的裁剪区域计算，适配当前 Flutter 渲染 API
- 修正示例中的页面返回 API 使用和静态检查问题

### 维护

- 清理库内过时的作者/时间模板注释，改为面向 API 的说明
- 移除无用的 plugin 模板配置和未使用依赖
- 调整最低 SDK 约束到 Dart 3.4 / Flutter 3.22，以匹配当前代码实际依赖的 API

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

