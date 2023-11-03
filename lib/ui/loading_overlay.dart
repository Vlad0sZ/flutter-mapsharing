import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FutureLoadingWidget<T> extends StatefulWidget {
  final Future<T> future;
  final Widget child;
  final Widget Function(BuildContext context)? loadingWidgetBuilder;
  final Widget Function(BuildContext context)? errorWidgetBuilder;
  final Function(dynamic)? onError;
  final Function(T)? onCompleted;

  const FutureLoadingWidget({
    super.key,
    required this.future,
    required this.child,
    this.loadingWidgetBuilder,
    this.errorWidgetBuilder,
    this.onError,
    this.onCompleted,
  });

  @override
  State<FutureLoadingWidget> createState() => _FutureLoadingWidgetState();
}

class _FutureLoadingWidgetState<T> extends State<FutureLoadingWidget> {

    late bool _loading;
  late bool _hasError;
  T? _value;
  dynamic _error;

  @override
  void initState() {
    print('init state!');
    _loading = true;
    _hasError = false;
    _error = null;
    widget.future
        .then((value) => _onFinished(value))
        .catchError((error) => _onError(error));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.loadingWidgetBuilder?.call(context) ??
          const SizedBox.shrink();
    } else if (_hasError) {
      return widget.errorWidgetBuilder?.call(context) ??
          const SizedBox.shrink();
    } else {
      return widget.child;
    }
  }

  void _onFinished(T value) {
    print('on then $value');
    setState(() {
      _loading = false;
      _hasError = false;
      _value = value;
    });

    widget.onCompleted?.call(_value);
  }

  void _onError(dynamic error) {
    print('on error $_error');
    setState(() {
      _loading = false;
      _hasError = true;
      _error = error;
    });

    widget.onError?.call(_error);
  }
}
