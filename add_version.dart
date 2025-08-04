import 'dart:io';

void main() async {
  final version = DateTime.now().millisecondsSinceEpoch.toString();
  final indexFile = File('build/web/index.html');
  final bootstrapFile = File('build/web/flutter_bootstrap.js');

  // 1. 修改 index.html
  if (await indexFile.exists()) {
    String content = await indexFile.readAsString();

    content = content.replaceFirst(
      'flutter_bootstrap.js',
      'flutter_bootstrap.js?v=$version',
    );

    await indexFile.writeAsString(content);
    print('✅ index.html 加版本号完成: $version');
  } else {
    print('❌ index.html 文件不存在！');
  }

  // 2. 修改 flutter_bootstrap.js
  if (await bootstrapFile.exists()) {
    String content = await bootstrapFile.readAsString();

    content = content.replaceAll(
      '"main.dart.js"',
      '"main.dart.js?v=$version"',
    );

    await bootstrapFile.writeAsString(content);
    print('✅ flutter_bootstrap.js 加版本号完成: $version');
  } else {
    print('❌ flutter_bootstrap.js 文件不存在！');
  }
}
