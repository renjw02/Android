import 'dart:js_interop';

import 'package:flutter/material.dart';
class CustomRoute<T> extends MaterialPageRoute<T> {
  // CustomRoute({WidgetBuilder builder, RouteSettings settings})
  //     : super(builder: builder, settings: settings);
  CustomRoute({required WidgetBuilder builder, required RouteSettings settings})
      : super(builder: builder, settings: settings);
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    //settings.isDefinedAndNotNull的值为true时，表示当前路由为根路由，不需要执行动画
    if (settings.isDefinedAndNotNull){
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}