/// author:郑再红
/// email:1096877329@qq.com
/// date:2026-04-29 17:20
/// describe: 路由模式匹配

/// 路由模式类，用于匹配和解析路径参数
/// 
/// 支持格式：
/// - /user/:id - 匹配 /user/123，提取 {id: '123'}
/// - /product/:category/:id - 匹配 /product/electronics/123
/// - /posts/:year/:month/:day - 匹配 /posts/2024/01/15
class RoutePattern {
  /// 原始模式字符串
  final String pattern;
  
  /// 编译后的正则表达式
  final RegExp regex;
  
  /// 参数名称列表
  final List<String> paramNames;

  RoutePattern(this.pattern)
      : paramNames = _extractParamNames(pattern),
        regex = _buildRegex(pattern);

  /// 从模式中提取参数名称
  /// 例如：/user/:id/:name -> ['id', 'name']
  static List<String> _extractParamNames(String pattern) {
    final regex = RegExp(r':(\w+)');
    return regex
        .allMatches(pattern)
        .map((match) => match.group(1)!)
        .toList();
  }

  /// 构建正则表达式
  /// 将 /user/:id 转换为 ^/user/([^/]+)$
  static RegExp _buildRegex(String pattern) {
    var regexPattern = pattern.replaceAllMapped(
      RegExp(r':(\w+)'),
      (match) => r'([^/]+)',
    );
    // 转义特殊字符
    regexPattern = regexPattern.replaceAll('/', r'\/');
    return RegExp('^$regexPattern\$');
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
