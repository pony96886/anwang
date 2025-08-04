// ignore_for_file: must_call_super

import 'package:flutter/material.dart';

class PageCacheMixin extends StatefulWidget {
  const PageCacheMixin({Key? key, this.child}) : super(key: key);
  final Widget? child;

  @override
  State<PageCacheMixin> createState() => _PageCacheMixinState();
}

class _PageCacheMixinState extends State<PageCacheMixin>
    with AutomaticKeepAliveClientMixin<PageCacheMixin> {
  @override
  Widget build(BuildContext context) {
    return widget.child ?? Container();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
