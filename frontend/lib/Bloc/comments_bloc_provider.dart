// TODO Implement this library.
import 'package:flutter/material.dart';
import './comments_bloc.dart';
export './comments_bloc.dart';

class CommentsBlocProvider extends InheritedWidget {
  final CommentsBloc _bloc;
  CommentsBlocProvider({required Key key, required Widget child})
      : _bloc = CommentsBloc(),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static CommentsBloc of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<CommentsBlocProvider>()
      as CommentsBlocProvider)
          ._bloc;
  static CommentsBloc withKeyOf(BuildContext context, Key key) =>
      (context.dependOnInheritedWidgetOfExactType<CommentsBlocProvider>(aspect: key) as CommentsBlocProvider)._bloc;
}