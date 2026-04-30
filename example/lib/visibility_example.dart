import 'package:flutter/material.dart';
import 'package:router_pro/wrapper/visibility_detector.dart';

/// VisibilityDetector 高级用法示例
/// 演示可见性检测的各种应用场景

class VisibilityExamplePage extends StatefulWidget {
  const VisibilityExamplePage({Key? key}) : super(key: key);

  @override
  State<VisibilityExamplePage> createState() => _VisibilityExamplePageState();
}

class _VisibilityExamplePageState extends State<VisibilityExamplePage> {
  final List<String> _visibilityLogs = [];
  int _visibleItemCount = 0;

  void _addLog(String message) {
    setState(() {
      _visibilityLogs.insert(0, '${DateTime.now().toString().substring(11, 19)} - $message');
      if (_visibilityLogs.length > 10) {
        _visibilityLogs.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('可见性检测示例'),
      ),
      body: Column(
        children: [
          // 日志显示区域
          Container(
            height: 200,
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '可见性日志 (当前可见: $_visibleItemCount 个)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _visibilityLogs.length,
                    itemBuilder: (context, index) {
                      return Text(
                        _visibilityLogs[index],
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 可滚动列表
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return _buildVisibilityItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityItem(int index) {
    final key = Key('item-$index');
    
    return VisibilityDetector(
      key: key,
      onVisibilityChanged: (info) {
        // 使用新增的便捷属性
        if (info.isFullyVisible) {
          _addLog('Item $index 完全可见');
          setState(() => _visibleItemCount++);
        } else if (info.isPartiallyVisible) {
          _addLog('Item $index 部分可见 (${(info.visibleFraction * 100).toStringAsFixed(0)}%)');
        } else if (info.isInvisible) {
          _addLog('Item $index 不可见');
          setState(() => _visibleItemCount--);
        }
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getColorForIndex(index),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Item $index',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}

/// 懒加载图片示例
class LazyImageExample extends StatefulWidget {
  const LazyImageExample({Key? key}) : super(key: key);

  @override
  State<LazyImageExample> createState() => _LazyImageExampleState();
}

class _LazyImageExampleState extends State<LazyImageExample> {
  final Map<int, bool> _loadedImages = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('懒加载图片')),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          return VisibilityDetector(
            key: Key('image-$index'),
            onVisibilityChanged: (info) {
              // 当图片50%可见时开始加载
              if (info.visibleFraction >= 0.5 && !(_loadedImages[index] ?? false)) {
                setState(() {
                  _loadedImages[index] = true;
                });
              }
            },
            child: Container(
              height: 200,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _loadedImages[index] == true
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image, size: 64, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text('图片 $index 已加载'),
                        ],
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// 视频自动播放示例
class AutoPlayVideoExample extends StatefulWidget {
  const AutoPlayVideoExample({Key? key}) : super(key: key);

  @override
  State<AutoPlayVideoExample> createState() => _AutoPlayVideoExampleState();
}

class _AutoPlayVideoExampleState extends State<AutoPlayVideoExample> {
  final Map<int, bool> _playingVideos = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('视频自动播放')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return VisibilityDetector(
            key: Key('video-$index'),
            onVisibilityChanged: (info) {
              // 80%可见时播放，不可见时暂停
              if (info.visibleFraction >= 0.8) {
                setState(() {
                  _playingVideos[index] = true;
                });
              } else if (info.isInvisible) {
                setState(() {
                  _playingVideos[index] = false;
                });
              }
            },
            child: Container(
              height: 300,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _playingVideos[index] == true
                          ? Icons.play_circle_filled
                          : Icons.pause_circle_filled,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _playingVideos[index] == true ? '播放中...' : '已暂停',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '视频 $index',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 曝光统计示例
class ExposureTrackingExample extends StatefulWidget {
  const ExposureTrackingExample({Key? key}) : super(key: key);

  @override
  State<ExposureTrackingExample> createState() => _ExposureTrackingExampleState();
}

class _ExposureTrackingExampleState extends State<ExposureTrackingExample> {
  final Map<int, int> _exposureCounts = {};
  final Map<int, DateTime?> _lastExposureTime = {};

  void _trackExposure(int index) {
    setState(() {
      _exposureCounts[index] = (_exposureCounts[index] ?? 0) + 1;
      _lastExposureTime[index] = DateTime.now();
    });
    
    // 这里可以发送曝光数据到服务器
    debugPrint('Item $index 曝光次数: ${_exposureCounts[index]}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('曝光统计')),
      body: ListView.builder(
        itemCount: 30,
        itemBuilder: (context, index) {
          return VisibilityDetector(
            key: Key('exposure-$index'),
            onVisibilityChanged: (info) {
              // 完全可见时记录曝光
              if (info.isFullyVisible) {
                _trackExposure(index);
              }
            },
            child: Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('$index'),
                ),
                title: Text('商品 $index'),
                subtitle: Text(
                  '曝光次数: ${_exposureCounts[index] ?? 0}',
                ),
                trailing: _lastExposureTime[index] != null
                    ? Text(
                        '最后曝光:\n${_lastExposureTime[index]!.toString().substring(11, 19)}',
                        style: const TextStyle(fontSize: 10),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
