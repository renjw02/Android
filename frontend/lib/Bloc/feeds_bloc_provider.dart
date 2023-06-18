// TODO Implement this library.
import 'package:flutter/material.dart';
import 'feeds_bloc.dart';
export 'feeds_bloc.dart';

class FeedsBlocProvider extends InheritedWidget {
  final FeedsBloc bloc;

  FeedsBlocProvider({required Key key, required Widget child})
      : bloc = FeedsBloc(),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static FeedsBloc of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<FeedsBlocProvider>() as FeedsBlocProvider).bloc;

  static FeedsBloc withKeyOf(BuildContext context, Key key) =>
      (context.dependOnInheritedWidgetOfExactType<FeedsBlocProvider>(aspect: key) as FeedsBlocProvider).bloc;
}