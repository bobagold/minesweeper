import 'package:flutter/material.dart';
import '../models/bloc.dart';

/// State provider
@immutable
class BlocProvider<T extends Bloc> extends StatefulWidget {
  /// build child with access to state
  final WidgetBuilder builder;

  /// create state
  final T Function() create;

  /// constructor
  const BlocProvider({
    super.key,
    required this.builder,
    required this.create,
  });

  @override
  State<StatefulWidget> createState() {
    return _BlocProviderState<T>();
  }

  /// provider state instance
  static T of<T extends Bloc>(BuildContext context) =>
      context.findAncestorStateOfType<_BlocProviderState<T>>()!.bloc;
}

class _BlocProviderState<T extends Bloc> extends State<BlocProvider<T>> {
  late T bloc;

  @override
  void initState() {
    bloc = widget.create();
    super.initState();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Builder(builder: widget.builder);
}
