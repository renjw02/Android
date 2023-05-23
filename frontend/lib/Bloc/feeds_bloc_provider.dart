// TODO Implement this library.
import 'package:flutter/material.dart';
import '../utils/global_variable.dart';
import 'feeds_bloc.dart';
export 'feeds_bloc.dart';

class FeedsBlocProvider extends InheritedWidget {
  final FeedsBloc bloc;

  FeedsBlocProvider({required Key key, required Widget child,required FeedsFilter filter})
      : bloc = FeedsBloc(filter),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static FeedsBloc of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<FeedsBlocProvider>() as FeedsBlocProvider).bloc;

  static FeedsBloc withKeyOf(BuildContext context, Key key) =>
      (context.dependOnInheritedWidgetOfExactType<FeedsBlocProvider>(aspect: key) as FeedsBlocProvider).bloc;
}