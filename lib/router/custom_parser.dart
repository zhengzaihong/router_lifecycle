
import 'package:flutter/material.dart';
import 'package:router_pro/router/route_parser.dart';

///
/// author:郑再红
/// email:1096877329@qq.com
/// date: 2022/12/7
/// time: 13:51
/// describe: 没做解析，外部需要自定义RouteParser
///
class CustomParser extends RouteParser {

  const CustomParser() : super();

  @override
  Future<RouteInformation> parseRouteInformation(RouteInformation routeInformation) async {
    return routeInformation;
  }

  @override
  RouteInformation restoreRouteInformation(RouteInformation routeInformation) {
    return routeInformation;
  }
}
