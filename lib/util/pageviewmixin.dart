import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PageViewMixin extends StatefulWidget {
  Widget child;
  PageViewMixin({Key? key, required this.child}) : super(key: key);

  @override
  _PageViewMixinState createState() => _PageViewMixinState();
}

class _PageViewMixinState extends State<PageViewMixin>
    with AutomaticKeepAliveClientMixin<PageViewMixin> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
