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
/// A route parser with support for aliases, path params, and query params.
class EnhancedParser extends RouteParser {
  /// 是否启用路径参数解析
  /// Whether to parse path parameters such as `/user/:id`.
  final bool enablePathParams;
  /// 是否启用查询参数解析
  /// Whether to parse query parameters.
  final bool enableQueryParams;

  /// Whether to validate resolved routes.
  final bool enableValidation;
  /// 路由别名映射
  /// 例如：{'/home': '/', '/profile': '/user/profile'}
  /// Route alias mappings such as `{'/home': '/'}`.
  final Map<String, String>? routeAliases;
  /// 路由模式列表
  /// 用于匹配和解析路径参数
  /// Route patterns used to match and extract path parameters.
  final List<RoutePattern>? patterns;
  /// 默认路由（当路由不存在时跳转）
  /// Fallback route used when validation fails.
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
    // 1. Resolve route aliases.
    if (routeAliases != null && routeAliases!.containsKey(path)) {
      final aliasPath = routeAliases![path]!;
      uri = Uri.parse(aliasPath).replace(
        queryParameters:
            uri.queryParameters.isNotEmpty ? uri.queryParameters : null,
      );
      path = uri.path;
    }
    // 2. 解析路径参数
    // 2. Resolve path parameters.
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
    // 3. Resolve query parameters.
    Map<String, String>? queryParams;
    if (enableQueryParams && uri.hasQuery) {
      queryParams = Map<String, String>.from(uri.queryParameters);
    }
    // 4. 验证路由
    // 4. Validate the resolved route when enabled.
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
    // 5. Attach parsed metadata to RouteInformation.state.
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
  /// Returns whether the parsed route should be treated as valid.
  bool _validateRoute(
    Uri uri,
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
  ) {
    if (uri.path.isEmpty) {
      return false;
    }

    return true;
  }
}
/// 路由参数辅助类
/// 用于从 RouteInformation 的 state 中提取参数
/// Parsed route metadata stored in [RouteInformation.state].
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
  /// Creates an instance from `RouteInformation.state`.
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
  /// Returns a path parameter by key.
  String? getPathParam(String key) => pathParams?[key];

  /// 获取查询参数
  /// Returns a query parameter by key.
  String? getQueryParam(String key) => queryParams?[key];

  /// 获取所有参数（路径参数 + 查询参数）
  /// Returns both path and query parameters in a single map.
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
