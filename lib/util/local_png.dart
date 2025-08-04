import 'package:flutter/material.dart';

//加载本地图片
class LocalPNG extends StatefulWidget {
  LocalPNG({
    Key? key,
    required this.name,
    this.width = double.infinity,
    this.height = double.infinity,
    this.fit = BoxFit.cover,
    this.scale = 1.0,
    this.color,
    this.ext = ".png",
  }) : super(key: key);

  final String name;
  final double width;
  final double height;
  final BoxFit fit;
  final double scale;
  Color? color;
  final String ext;

  @override
  State<LocalPNG> createState() => _LocalPNGState();
}

class _LocalPNGState extends State<LocalPNG> {
  Widget _child = Container();

  @override
  void initState() {
    super.initState();
  }

  _loadImage() {
    //开发先取消，后面统一处理
    _child = Image.asset(
      "assets/images/${widget.name}${widget.ext}",
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      scale: widget.scale,
      color: widget.color,
    );
    setState(() {});
    return;
    // if (_cacheJSON.length == 0 || widget.name == null) return;
    // ByteData data =
    //     await rootBundle.load("assets/images/${_cacheJSON[widget.name]}");
    // List<int> bytes =
    //     data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // List<int> dbytes =
    //     base64Decode(PlatformAwareCrypto.decry(utf8.decode(bytes)));
    // if (dbytes != null || dbytes.length > 0) {
    //   _child = Image.memory(dbytes,
    //       fit: widget.fit,
    //       height: widget.height,
    //       width: widget.width,
    //       color: widget.color);
    //   setState(() {});
    // }
  }

  @override
  Widget build(BuildContext context) {
    _loadImage();
    return _child;
  }
}
