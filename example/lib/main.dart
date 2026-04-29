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

// 模拟登录状态
bool _isLoggedIn = false;

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

  // 添加命名路由守卫 - 用于 pushNamed 方式
  router.addRouteGuard((from, to) async {
    final protectedRoutes = ['/profile'];
    
    if (protectedRoutes.contains(to.uri.toString()) && !_isLoggedIn) {
      debugPrint('路由守卫: 拦截命名路由 ${to.uri}，需要登录');
      router.pushNamed(name: '/login');
      return false;
    }
    return true;
  });

  // 添加页面类型守卫 - 用于 push(page: xxx) 方式
  router.addPageTypeGuard((fromPageType, toPageType) async {
    final protectedPageTypes = [
      VideoPlayerDemoPage,
      ProfileDetailPage,
    ];
    
    if (protectedPageTypes.contains(toPageType) && !_isLoggedIn) {
      debugPrint('页面类型守卫: 拦截页面类型 $toPageType，需要登录');
      // 这里不能直接 push LoginPage，因为会触发循环，所以用 pushNamed
      router.pushNamed(name: '/login');
      return false;
    }
    return true;
  });
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

// 切换登录状态的辅助函数
void toggleLoginStatus() {
  _isLoggedIn = !_isLoggedIn;
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
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          actions: [
            // 登录状态切换按钮
            IconButton(
              icon: Icon(_isLoggedIn ? Icons.logout : Icons.login),
              tooltip: _isLoggedIn ? '退出登录' : '登录',
              onPressed: () {
                setState(() {
                  toggleLoginStatus();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isLoggedIn ? '已登录' : '已退出登录'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 登录状态显示
            Card(
              color: _isLoggedIn ? Colors.green.shade50 : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isLoggedIn ? Icons.check_circle : Icons.info,
                      color: _isLoggedIn ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isLoggedIn ? '当前状态：已登录' : '当前状态：未登录',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildSectionTitle('🚀 路由功能'),
            _buildFeatureCard(
              icon: Icons.layers,
              title: '路由启动模式',
              description: '演示 Standard、SingleTop、SingleInstance 三种模式',
              onTap: () => _showLaunchModeDemo(context),
            ),
            _buildFeatureCard(
              icon: Icons.security,
              title: '路由守卫（命名路由）',
              description: '演示命名路由拦截和权限验证',
              onTap: () => router.pushNamed(name: '/profile'),
            ),
            _buildFeatureCard(
              icon: Icons.shield,
              title: '页面类型守卫',
              description: '演示 push(page: xxx) 方式的路由守卫',
              onTap: () => router.push(page: const ProfileDetailPage()),
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
              description: '演示视频播放的生命周期管理（需要登录）',
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
              subtitle: const Text('栈顶已存在则更新参数（类似Android onNewIntent）'),
              onTap: () {
                Navigator.pop(context);
                router.push(
                  page: DetailPage(title: '栈顶复用 - ${DateTime.now().second}秒'),
                  launchMode: LaunchMode.singleTop,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.filter_1),
              title: const Text('SingleInstance 单例模式'),
              subtitle: const Text('全栈唯一实例，清除上层页面'),
              onTap: () {
                Navigator.pop(context);
                router.push(
                  page: SingleInstanceDemoPage(timestamp: DateTime.now().toString()),
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
        router.showAppSnackBar(message:value);
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

// ============ 个人详情页（用于演示页面类型守卫）============
class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人详情'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              '个人详情页面',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            const Text(
              '此页面通过页面类型守卫保护',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              '使用 router.push(page: ProfileDetailPage()) 跳转',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ SingleInstance 演示页 ============
class SingleInstanceDemoPage extends StatelessWidget {
  final String timestamp;
  
  const SingleInstanceDemoPage({
    Key? key,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SingleInstance 演示'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.filter_1,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'SingleInstance 模式',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '创建时间: $timestamp',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(
                '特点：',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '• 全局唯一实例\n'
                '• 已存在时更新参数\n'
                '• 清除该页面上面的所有页面\n'
                '• 适用于购物车、首页等场景',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  router.push(page: const IntermediatePage());
                },
                icon: const Icon(Icons.add),
                label: const Text('添加中间页面'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  router.push(
                    page: SingleInstanceDemoPage(
                      timestamp: DateTime.now().toString(),
                    ),
                    launchMode: LaunchMode.singleInstance,
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('再次启动（会清除中间页面）'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ 中间页面（用于演示 SingleInstance 清除效果）============
class IntermediatePage extends StatelessWidget {
  const IntermediatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('中间页面'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.layers, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              '这是一个中间页面',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              '当再次启动 SingleInstance 页面时\n这个页面会被清除',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                router.push(page: const IntermediatePage());
              },
              child: const Text('再添加一个中间页面'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                router.push(
                  page: SingleInstanceDemoPage(
                    timestamp: DateTime.now().toString(),
                  ),
                  launchMode: LaunchMode.singleInstance,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('返回 SingleInstance 页面'),
            ),
          ],
        ),
      ),
    );
  }
}
