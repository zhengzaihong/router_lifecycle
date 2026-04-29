import 'package:flutter/material.dart';
import 'route_parser.dart';
import 'route_pattern.dart';


/// author:郑再红
/// email:1096877329@qq.com
/// date:2026-04-29 17:20
/// describe: 增强的路由解析器

/// 增强的路由解析器，支持：
/// - 路径参数解析（/user/:id）
/// - 查询参数解析（?key=value）
/// - 路由别名（/home -> /）
/// - 路由验证
/// 
/// 使用示例：
/// ```dart
/// final parser = EnhancedParser(
///   enablePathParams: true,
///   enableQueryParams: true,
///   routeAliases: {'/home': '/'},
///   patterns: [
///     RoutePattern('/user/:id'),
///     RoutePattern('/product/:category/:id'),
///   ],
/// );
/// 
/// MaterialApp.router(
///   routerDelegate: router,
///   routeInformationParser: parser,
/// );
/// ```
class EnhancedParser extends RouteParser {
  /// 是否启用路径参数解析
  final bool enablePathParams;
  
  /// 是否启用查询参数解析
  final bool enableQueryParams;
  
  /// 是否启用路由验证
  final bool enableValidation;
  
  /// 路由别名映射
  /// 例如：{'/home': '/', '/profile': '/user/profile'}
  final Map<String, String>? routeAliases;
  
  /// 路由模式列表
  /// 用于匹配和解析路径参数
  final List<RoutePattern>? patterns;
  
  /// 默认路由（当路由不存在时跳转）
  final String? defaultRoute;

  const EnhancedParser({
    this.enablePathParams = true,
    this.enableQueryParams = true,
    this.enableValidation = false,
    this.routeAliases,
    this.patterns,
    this.defaultRoute,
  });

  @override
  Future<RouteInformation> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    var uri = routeInformation.uri;
    var path = uri.path;
    
    // 1. 处理路由别名
    if (routeAliases != null && routeAliases!.containsKey(path)) {
      final aliasPath = routeAliases![path]!;
      uri = Uri.parse(aliasPath).replace(
        queryParameters: uri.queryParameters.isNotEmpty 
            ? uri.queryParameters 
            : null,
      );
      path = uri.path;
    }
    
    // 2. 解析路径参数
    Map<String, String>? pathParams;
    String? matchedPattern;
    if (enablePathParams && patterns != null) {
      for (var pattern in patterns!) {
        pathParams = pattern.match(path);
        if (pathParams != null) {
          matchedPattern = pattern.pattern;
          break;
        }
      }
    }
    
    // 3. 解析查询参数
    Map<String, String>? queryParams;
    if (enableQueryParams && uri.hasQuery) {
      queryParams = Map<String, String>.from(uri.queryParameters);
    }
    
    // 4. 验证路由
    if (enableValidation) {
      final isValid = _validateRoute(uri, pathParams, queryParams);
      if (!isValid && defaultRoute != null) {
        uri = Uri.parse(defaultRoute!);
        path = uri.path;
        pathParams = null;
        queryParams = null;
      }
    }
    
    // 5. 构建新的 RouteInformation，将解析结果存储在 state 中
    return RouteInformation(
      uri: uri,
      state: {
        'path': path,
        'pathParams': pathParams,
        'queryParams': queryParams,
        'matchedPattern': matchedPattern,
        'originalUri': routeInformation.uri.toString(),
      },
    );
  }

  @override
  RouteInformation? restoreRouteInformation(RouteInformation configuration) {
    return configuration;
  }

  /// 验证路由是否有效
  bool _validateRoute(
    Uri uri,
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
  ) {
    // 基本验证：路径不能为空
    if (uri.path.isEmpty) {
      return false;
    }
    
    // 如果定义了模式，检查是否匹配任何模式
    if (patterns != null && patterns!.isNotEmpty) {
      // 如果没有匹配到任何模式，可能是无效路由
      // 但这里我们允许未定义模式的路由通过
      // 可以根据需求调整
    }
    
    return true;
  }
}

/// 路由参数辅助类
/// 用于从 RouteInformation 的 state 中提取参数
class RouteParams {
  final String path;
  final Map<String, String>? pathParams;
  final Map<String, String>? queryParams;
  final String? matchedPattern;
  final String? originalUri;

  const RouteParams({
    required this.path,
    this.pathParams,
    this.queryParams,
    this.matchedPattern,
    this.originalUri,
  });

  /// 从 RouteInformation 的 state 中提取参数
  static RouteParams? fromState(Object? state) {
    if (state is! Map) return null;
    
    return RouteParams(
      path: state['path'] as String? ?? '/',
      pathParams: state['pathParams'] as Map<String, String>?,
      queryParams: state['queryParams'] as Map<String, String>?,
      matchedPattern: state['matchedPattern'] as String?,
      originalUri: state['originalUri'] as String?,
    );
  }

  /// 获取路径参数
  String? getPathParam(String key) => pathParams?[key];

  /// 获取查询参数
  String? getQueryParam(String key) => queryParams?[key];

  /// 获取所有参数（路径参数 + 查询参数）
  Map<String, String> getAllParams() {
    return {
      ...?pathParams,
      ...?queryParams,
    };
  }

  @override
  String toString() {
    return 'RouteParams(path: $path, pathParams: $pathParams, queryParams: $queryParams)';
  }
}
