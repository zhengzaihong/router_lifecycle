// author:郑再红
// email:1096877329@qq.com
// date:2026-04-29 17:20
// describe: 路由模式匹配

/// 路由模式类，用于匹配和解析路径参数
///
/// 支持格式：
/// - /user/:id - 匹配 /user/123，提取 {id: '123'}
/// - /product/:category/:id - 匹配 /product/electronics/123
/// - /posts/:year/:month/:day - 匹配 /posts/2024/01/15
/// Matches route templates like `/user/:id` and extracts path parameters.
///
class RoutePattern {
  /// 原始模式字符串
  /// The original template string.
  final String pattern;

  /// 编译后的正则表达式
  /// The compiled regular expression for [pattern].
  final RegExp regex;

  /// 参数名称列表
  /// Ordered parameter names captured from [pattern].
  final List<String> paramNames;

  RoutePattern(this.pattern)
      : paramNames = _extractParamNames(pattern),
        regex = _buildRegex(pattern);

  /// 从模式中提取参数名称
  /// 例如：/user/:id/:name -> ['id', 'name']
  /// Extracts parameter names from a template such as `/user/:id/:name`.
  static List<String> _extractParamNames(String pattern) {
    final regex = RegExp(r':(\w+)');
    return regex.allMatches(pattern).map((match) => match.group(1)!).toList();
  }

  /// 构建正则表达式
  /// 将 /user/:id 转换为 ^/user/([^/]+)$
  /// 非参数部分会按字面量转义，避免模板中的 `.`、`+`、`*` 等
  /// 被当作正则元字符。
  /// Builds a regular expression from a route template.
  static RegExp _buildRegex(String pattern) {
    final buffer = StringBuffer('^');
    var lastIndex = 0;

    for (final match in RegExp(r':(\w+)').allMatches(pattern)) {
      buffer.write(RegExp.escape(pattern.substring(lastIndex, match.start)));
      buffer.write(r'([^/]+)');
      lastIndex = match.end;
    }

    buffer.write(RegExp.escape(pattern.substring(lastIndex)));
    buffer.write(r'$');
    return RegExp(buffer.toString());
  }

  /// 匹配路径并提取参数
  ///
  /// 返回参数映射，如果不匹配则返回 null
  ///
  /// 示例：
  /// ```dart
  /// final pattern = RoutePattern('/user/:id');
  /// final params = pattern.match('/user/123');
  /// // params: {id: '123'}
  /// ```
  /// Matches [path] and returns extracted parameters, or `null` if it fails.
  Map<String, String>? match(String path) {
    final match = regex.firstMatch(path);
    if (match == null) return null;

    final params = <String, String>{};
    for (var i = 0; i < paramNames.length; i++) {
      params[paramNames[i]] = match.group(i + 1)!;
    }
    return params;
  }

  @override
  String toString() => 'RoutePattern($pattern)';
}

/// 规范化路由 path，供守卫等基于路径的匹配使用。
///
/// - 合并重复的 `/`
/// - 去除除根路径外的尾部 `/`
/// - 空路径归一为 `/`
///
/// 调用方应传入 `uri.path` 而不是 `uri.toString()`，以忽略 query 和 fragment。
///
/// Normalizes a route path for guard matching.
String normalizeRoutePath(String path) {
  if (path.isEmpty) {
    return '/';
  }

  var normalized = path.replaceAll(RegExp(r'/+'), '/');
  if (normalized.length > 1 && normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}
