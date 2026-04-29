import 'package:flutter/material.dart';
import 'package:router_pro/router_lib.dart';
import 'visibility_example.dart';

/// Router Pro 完整示例
/// 包含所有功能演示：
/// 1. 路由启动模式
/// 2. 路由守卫
/// 3. 命名路由值回传
/// 4. 404错误页面
/// 5. 生命周期感知
/// 6. 可见性检测

void main() {
  // 初始化路由
  initRouter();
  runApp(const MyApp());
}

// 全局路由实例
late RouterProxy router;

void initRouter() {
  router = RouterProxy.getInstance(
    pageMap: {
      '/': const HomePage(),
      '/login': const LoginPage(),
      '/profile': const ProfilePage(),
      '/settings': const SettingsPage(),
      '/visibility': const VisibilityExamplePage(),
      '/lazy-image': const LazyImageExample(),
      '/auto-video': const AutoPlayVideoExample(),
      '/exposure': const ExposureTrackingExample(),
    },
    notFoundPage: const NotFoundPage(),
    exitWindowStyle: _confirmExit,
  );

  // 添加路由守卫 - 需要登录才能访问某些页面
  router.addRouteGuard((from, to) async {
    final protectedRoutes = ['/profile',];
    final isLoggedIn = await _checkLoginStatus();

    if (protectedRoutes.contains(to.uri.toString()) && !isLoggedIn) {
      // 拦截跳转，跳转到登录页
      router.pushNamed(name: '/login');
      return false;
    }
    return true;
  });
}

Future<bool> _checkLoginStatus() async {
  // 模拟检查登录状态
  return false; // 返回false表示未登录
}

Future<bool> _confirmExit(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('退出确认'),
      content: const Text('确定要退出应用吗？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('确定'),
        ),
      ],
    ),
  );
  return result ?? true;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Router Pro - 完整示例',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerDelegate: router,
      routeInformationParser: router.defaultParser(),
    );
  }
}

// ============ 首页 ============
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LifeCycle(
      debugLabel: 'HomePage',
      onCreate: () => debugPrint('HomePage onCreate'),
      onResume: () => debugPrint('HomePage onResume'),
      onPause: () => debugPrint('HomePage onPause'),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Router Pro 完整示例'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('🚀 路由功能'),
            _buildFeatureCard(
              icon: Icons.layers,
              title: '路由启动模式',
              description: '演示 Standard、SingleTop、SingleInstance 三种模式',
              onTap: () => _showLaunchModeDemo(context),
            ),
            _buildFeatureCard(
              icon: Icons.security,
              title: '路由守卫',
              description: '演示路由拦截和权限验证',
              onTap: () => router.pushNamed(name: '/profile'),
            ),
            _buildFeatureCard(
              icon: Icons.swap_calls,
              title: '命名路由值回传',
              description: '演示通过命名路由传递和接收数据',
              onTap: () => _showValueReturnDemo(context),
            ),
            _buildFeatureCard(
              icon: Icons.error_outline,
              title: '404错误页面',
              description: '访问不存在的路由',
              onTap: () => router.pushNamed(name: '/not-exist'),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('⏱ 生命周期功能'),
            _buildFeatureCard(
              icon: Icons.video_library,
              title: '视频播放生命周期',
              description: '演示视频播放的生命周期管理',
              onTap: () => _showVideoLifecycleDemo(context),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('👁 可见性检测'),
            _buildFeatureCard(
              icon: Icons.visibility,
              title: '可见性检测示例',
              description: '演示列表项可见性监控',
              onTap: () => router.pushNamed(name: '/visibility'),
            ),
            _buildFeatureCard(
              icon: Icons.image,
              title: '懒加载图片',
              description: '演示图片懒加载',
              onTap: () => router.pushNamed(name: '/lazy-image'),
            ),
            _buildFeatureCard(
              icon: Icons.play_circle,
              title: '视频自动播放',
              description: '演示视频自动播放/暂停',
              onTap: () => router.pushNamed(name: '/auto-video'),
            ),
            _buildFeatureCard(
              icon: Icons.analytics,
              title: '曝光统计',
              description: '演示商品曝光统计',
              onTap: () => router.pushNamed(name: '/exposure'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showLaunchModeDemo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '选择启动模式',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.layers),
              title: const Text('Standard 标准模式'),
              subtitle: const Text('可创建多个实例'),
              onTap: () {
                Navigator.pop(context);
                router.push(
                  page: const DetailPage(title: '标准模式'),
                  launchMode: LaunchMode.standard,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.vertical_align_top),
              title: const Text('SingleTop 栈顶复用'),
              subtitle: const Text('栈顶已存在则不创建'),
              onTap: () {
                Navigator.pop(context);
                router.push(
                  page: const DetailPage(title: '栈顶复用'),
                  launchMode: LaunchMode.singleTop,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.filter_1),
              title: const Text('SingleInstance 单例模式'),
              subtitle: const Text('全栈唯一实例'),
              onTap: () {
                Navigator.pop(context);
                router.push(
                  page: const DetailPage(title: '单例模式'),
                  launchMode: LaunchMode.singleInstance,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showValueReturnDemo(BuildContext context) {
    router.pushNamed(
      name: '/settings',
      onResult: (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('收到返回值: $value')),
        );
      },
    );
  }

  void _showVideoLifecycleDemo(BuildContext context) {
    router.push(page: const VideoPlayerDemoPage());
  }
}

// ============ 详情页 ============
class DetailPage extends StatelessWidget {
  final String title;

  const DetailPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                router.push(
                  page: DetailPage(title: '$title - 子页面'),
                );
              },
              child: const Text('继续跳转'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ 登录页 ============
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              '请先登录',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // 模拟登录成功
                router.pop();
              },
              icon: const Icon(Icons.login),
              label: const Text('登录'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ 个人中心 ============
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: const Center(
        child: Text('个人中心页面'),
      ),
    );
  }
}

// ============ 设置页 ============
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 返回时携带数据
            router.pop('设置已保存');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('设置页面'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                router.pop('用户点击了保存按钮');
              },
              child: const Text('保存并返回'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ 404页面 ============
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('抱歉，您访问的页面不存在'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => router.goRootPage(),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ 视频播放演示页 ============
class VideoPlayerDemoPage extends StatefulWidget {
  const VideoPlayerDemoPage({Key? key}) : super(key: key);

  @override
  State<VideoPlayerDemoPage> createState() => _VideoPlayerDemoPageState();
}

class _VideoPlayerDemoPageState extends State<VideoPlayerDemoPage> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return LifeCycle(
      visibilityThreshold: 0.8,
      debugLabel: 'VideoPlayer',
      onResume: () {
        setState(() => _isPlaying = true);
        debugPrint('视频开始播放');
      },
      onPause: () {
        setState(() => _isPlaying = false);
        debugPrint('视频暂停');
      },
      onDestroy: () {
        debugPrint('视频资源释放');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('视频播放生命周期'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => router.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _isPlaying ? Icons.play_circle_filled : Icons.pause_circle_filled,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isPlaying ? '播放中...' : '已暂停',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                '页面80%可见时自动播放\n页面不可见时自动暂停',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
