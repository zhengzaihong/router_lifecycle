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

