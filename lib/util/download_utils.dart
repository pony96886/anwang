import 'dart:convert';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:deepseek/util/app_global.dart';
import 'package:deepseek/util/encdecrypt.dart';
import 'package:deepseek/util/eventbus_class.dart';
import 'package:deepseek/util/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

Dio dio = Dio();

//视频下载
class DownloadUtils {
  static List downloadTasks = []; // 下载任务队列
  static bool downloading = false; // 是否存在下载任务
  static int finishCount = 0; // 当前下载完成的分片数量
  static bool creating = false; // 防止连点
  static bool currentRemove = false; // 当前下载任务是否被删除

  static removeTask(String deteleId) {
    if (downloadTasks.isEmpty) {
      return;
    }
    bool haveCurrent = deteleId == downloadTasks[0]["taskInfo"]["id"];
    downloadTasks.removeWhere((e) => e["taskInfo"]["id"] == deteleId);
    if (haveCurrent) {
      downloading = false;
      currentRemove = true;
      startNext();
    }
  }

  // 获取地址
  static Future<String> getPath(String folderName) async {
    var documents;
    if (Platform.isAndroid) {
      documents = await getExternalStorageDirectory();
    } else {
      documents = await getApplicationDocumentsDirectory();
    }
    String _getApplicationDocumentsDirectory = documents.path;
    String _cachePath = '$_getApplicationDocumentsDirectory/$folderName/';
    Directory directory = Directory(_cachePath);
    bool isExists = await directory.exists();
    if (!isExists) {
      await directory.create(recursive: true);
    }
    return _cachePath;
  }

  // 获取地址
  static Future<String> getEnvironmentPath(String folderName) async {
    String _getApplicationDocumentsDirectory;
    if (Platform.isAndroid) {
      Directory? osp = await getExternalStorageDirectory();
      if (osp == null) return '';
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _getApplicationDocumentsDirectory =
          osp.path.replaceAll("/${packageInfo.packageName}/files", "");
    } else {
      Directory osp = await getApplicationDocumentsDirectory();
      _getApplicationDocumentsDirectory = osp.path;
    }

    String _cachePath = '$_getApplicationDocumentsDirectory/$folderName/';
    Directory directory = Directory(_getApplicationDocumentsDirectory);
    bool isExists = await directory.exists();
    if (!isExists) {
      await directory.create(recursive: true);
    }
    return _cachePath;
  }

  static String _checkIV(String data) {
    if (data.contains("IV=") == false) {
      String ivData = data.replaceAll(
          "#EXT-X-KEY:METHOD=AES-128,", "#EXT-X-KEY:METHOD=AES-128,IV=0x0,");
      return ivData;
    }
    return data;
  }

  // 视频解密，返回ts队列
  static Future<Map> getTsList(String urlPath) async {
    // 视频地址解密
    String decrypted;
    var res = await Dio().get(urlPath);
    if (AppGlobal.m3u8_encrypt == '1') {
      decrypted = EncDecrypt.decryptM3U8(res.data);
    } else {
      decrypted = res.data;
    }
    decrypted = _checkIV(decrypted);
    String localM3u8 = decrypted;
    // 整理key和ts链接
    List<String> lists = decrypted.split("#EXTINF:");
    List<String> tsLists = [];
    for (var el in lists) {
      var regSrcExp = RegExp(
          r'(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?');
      String matchfix = regSrcExp.stringMatch(el) ?? "";
      if (matchfix.contains(".key")) {
        localM3u8 = localM3u8.replaceAll(
            matchfix,
            matchfix.substring(
                matchfix.lastIndexOf("/") + 1, matchfix.indexOf(".key") + 4));
      }
      if (matchfix.contains(".ts")) {
        localM3u8 = localM3u8.replaceAll(
            matchfix,
            matchfix.substring(
                matchfix.lastIndexOf("/") + 1, matchfix.indexOf(".ts") + 3));
      }
      tsLists.add(matchfix);
    }
    return {"localM3u8": localM3u8, "tsLists": tsLists};
  }

  // 初始化下载状态
  static initStatus(int finishNum) {
    downloading = true;
    currentRemove = false;
    finishCount = finishNum;
  }

  // 开始下个任务
  static startNext() async {
    if (downloadTasks.isNotEmpty) {
      Box box = await Hive.openBox('deepseek_video_box');
      List tasks = box.get('download_video_tasks') ?? [];
      downloadTasks[0]["taskInfo"]["downloading"] = true;
      int taskNum = tasks
          .indexWhere((e) => e["id"] == downloadTasks[0]["taskInfo"]["id"]);
      // LogUtil.d("${tasks[taskNum]["title"]}");
      tasks[taskNum]["downloading"] = true;
      tasks[taskNum]["isWaiting"] = false;
      box.put("download_video_tasks", tasks);
      downloadContent(tasks[taskNum], box);
    } else {
      downloading = false;
    }
  }

  // 请求权限
  static Future<bool> getPermission() async {
    PermissionStatus storageStatus = await Permission.storage.status;
    if (storageStatus == PermissionStatus.denied) {
      storageStatus = await Permission.storage.request();
      if (storageStatus == PermissionStatus.denied ||
          storageStatus == PermissionStatus.permanentlyDenied) {
        return false;
      }
      return true;
    } else if (storageStatus == PermissionStatus.permanentlyDenied) {
      return false;
    }
    return true;
  }

  // 创建下载任务
  /*
   * taskInfo数据结构:
   * id              视频id
   * urlPath         下载地址（需解密）
   * title           视频标题
   * cover_thumb      视频封面
   * downloading     视频下载状态 bool
   * isWaiting       是否在下载队列中 bool
   * url             视频m3u8储存地址
   * tsLists         视频ts链接队列
   * localM3u8       本地m3u8文件 string
   * tsListsFinished 已下载完成的ts队列
   * progress        视频下载进度
   */
  static createDownloadTask(Map taskInfo) async {
    if (creating) {
      Utils.showText(Utils.txt('dtk'));
      return;
    }
    bool havePermission = await getPermission();
    if (havePermission) {
      creating = true;
    } else {
      Utils.showText(Utils.txt('qdkqx'));
      return;
    }
    try {
      Box box = await Hive.openBox('deepseek_video_box');
      List tasks = box.get('download_video_tasks') ?? [];
      int existTaskIndex = tasks.indexWhere((e) => e["id"] == taskInfo["id"]);
      int existDownloadTaskIndex = downloadTasks
          .indexWhere((e) => e["taskInfo"]["id"] == taskInfo["id"]);
      // 存在下载任务
      if (tasks.isNotEmpty && existTaskIndex != -1) {
        if (tasks[existTaskIndex]["downloading"] ||
            tasks[existTaskIndex]["progress"] == 1 ||
            existDownloadTaskIndex != -1) {
          Utils.showText(Utils.txt('dqrwcz'));
        } else if (downloading) {
          Utils.showText(Utils.txt('ztjdl'));
          downloadTasks.add({"taskInfo": tasks[existTaskIndex]});
          tasks[existTaskIndex]["isWaiting"] = true;
          box.put("download_video_tasks", tasks);
        } else {
          Utils.showText(Utils.txt('jxxz'));
          downloadTasks.add({"taskInfo": tasks[existTaskIndex]});
          downloadContent(tasks[existTaskIndex], box);
          tasks[existTaskIndex]["downloading"] = true;
          tasks[existTaskIndex]["isWaiting"] = false;
          box.put("download_video_tasks", tasks);
        }
        creating = false;
        return;
      }
      Utils.showText(Utils.txt('ytjzwck'));
      // 生成本地m3u8和ts下载列表
      Map tsData = await getTsList(taskInfo["urlPath"]);
      String localM3u8 = tsData["localM3u8"];
      List<String> tsLists = tsData["tsLists"];
      taskInfo["tsLists"] = tsLists;
      taskInfo["localM3u8"] = localM3u8;
      taskInfo["tsListsFinished"] = [];
      // 添加下载队列
      downloadTasks.add({"taskInfo": taskInfo});
      // 获取储存地址
      String saveDirectory =
          await getPath('${DateTime.now().millisecondsSinceEpoch}');
      // 存储本地m3u8文件
      String m3u8Name = taskInfo["urlPath"].substring(
          taskInfo["urlPath"].lastIndexOf("/") + 1,
          taskInfo["urlPath"].indexOf("m3u8") + 4);
      await File("$saveDirectory$m3u8Name").writeAsString(localM3u8);
      taskInfo["url"] = "$saveDirectory$m3u8Name";
      Utils.log(taskInfo);
      if (!downloading) {
        taskInfo["downloading"] = true;
        taskInfo["isWaiting"] = false;
        downloadContent(taskInfo, box);
      }
      // 储存下载任务信息
      taskInfo["progress"] = 0;
      tasks.insert(0, taskInfo);
      box.put("download_video_tasks", tasks);
      creating = false;
    } catch (e) {
      Utils.showText(Utils.txt('xzcjsb'));
      creating = false;
    }
  }

  static Future<void> downloadContent(Map taskInfo, Box box) async {
    List tsListsFinished = taskInfo["tsListsFinished"];
    initStatus(tsListsFinished.length);
    List<String> tsLists = [];
    tsLists.addAll(taskInfo["tsLists"]);
    String saveDirectory =
        taskInfo["url"].substring(0, taskInfo["url"].lastIndexOf("/"));
    // 提取未完成的下载任务队列
    // LogUtil.d("下载任务id---------${taskInfo["id"]}");
    if (tsListsFinished.isNotEmpty) {
      tsLists.removeWhere((e) {
        for (var i = 0; i < tsListsFinished.length; i++) {
          if (tsListsFinished[i] == e) {
            return true;
          }
        }
        return false;
      });
    }
    // // 建立下载任务列表
    // List<Future> taskList() {
    //   return tsLists.asMap().entries.map((e) {
    //     int index = e.key;
    //     String value = e.value;
    //     String savePath = saveDirectory +
    //         "/" +
    //         value.substring(
    //             value.lastIndexOf("/") + 1,
    //             value.indexOf(".ts") != -1
    //                 ? (value.indexOf(".ts") + 3)
    //                 : (value.indexOf(".key") + 4));
    //     return downloadItem(value, savePath, index, taskInfo["id"],
    //         taskInfo["tsLists"].length, box);
    //   }).toList();
    // }

    // // 开始批量下载
    // int taskNum;
    // List tasks;
    // Future.wait(taskList())
    //     .then((value) => {
    //           // 存储完成后的下载任务信息
    //           tasks = box.get('download_video_tasks') ?? [],
    //           taskNum = tasks.indexWhere((e) => e["id"] == taskInfo["id"]),
    //           tasks[taskNum]["progress"] = 1,
    //           tasks[taskNum]["downloading"] = false,
    //           box.put("download_video_tasks", tasks),
    //           // 下载完成，开始下一个任务
    //           downloadTasks.removeAt(0),
    //           startNext()
    //         })
    //     .catchError((err) {
    //   // 下载失败，开始下个任务
    //   tasks = box.get('download_video_tasks') ?? [];
    //   taskNum = tasks.indexWhere((e) => e["id"] == taskInfo["id"]);
    //   tasks[taskNum]["downloading"] = false;
    //   box.put("download_video_tasks", tasks);
    //   downloadTasks.removeAt(0);
    //   startNext();
    //   EventBus().emit('DOWNLOADVIDEO_PROGRESS',
    //       {"id": taskInfo["id"], "downloading": false, "downloadError": true});
    // });

    int _index = 0;
    int taskNum;
    List tasks;
    Future start() async {
      // 删除任务中断下载
      if (currentRemove) {
        return;
      }
      try {
        String savePath = saveDirectory +
            "/" +
            tsLists[_index].substring(
                tsLists[_index].lastIndexOf("/") + 1,
                tsLists[_index].contains(".ts")
                    ? (tsLists[_index].indexOf(".ts") + 3)
                    : (tsLists[_index].indexOf(".key") + 4));
        _index = await downloadItem(tsLists[_index], savePath, _index,
            taskInfo["id"], taskInfo["tsLists"].length, box);
        if (currentRemove) {
          return;
        }
        if (_index >= tsLists.length - 1) {
          // 完成
          // 存储完成后的下载任务信息
          tasks = box.get('download_video_tasks') ?? [];
          taskNum = tasks.indexWhere((e) => e["id"] == taskInfo["id"]);
          tasks[taskNum]["progress"] = 1;
          tasks[taskNum]["downloading"] = false;
          box.put("download_video_tasks", tasks);
          // 下载完成，开始下一个任务
          downloadTasks.removeAt(0);
          startNext();
        } else {
          _index++;
          start();
        }
      } catch (e) {
        // 下载失败，开始下个任务
        tasks = box.get('download_video_tasks') ?? [];
        taskNum = tasks.indexWhere((e) => e["id"] == taskInfo["id"]);
        tasks[taskNum]["downloading"] = false;
        box.put("download_video_tasks", tasks);
        downloadTasks.removeAt(0);
        startNext();
        UtilEventbus().fire(EventbusClass({
          "name": "DOWNLOADVIDEO_PROGRESS_${taskInfo["id"]}",
          "data": {
            "id": taskInfo["id"],
            "downloading": false,
            "downloadError": true
          }
        }));
      }
    }

    start();
  }

  //单个下载方法
  static Future<int> downloadItem(String urlPath, String savePath, int index,
      String id, int tsTotal, Box box) async {
    Future<int> start() async {
      if (currentRemove) {
        return index;
      }
      try {
        await dio.download(urlPath, savePath,
            onReceiveProgress: (int count, int total) {
          if (count >= total) {
            // 储存下载进度
            finishCount++;
            List tasks = box.get('download_video_tasks') ?? [];
            int taskNum = tasks.indexWhere((e) => e["id"] == id);
            tasks[taskNum]["progress"] = finishCount / tsTotal;
            tasks[taskNum]["downloading"] = true;
            tasks[taskNum]["tsListsFinished"].add(urlPath);
            box.put("download_video_tasks", tasks);
            // 发送进度数据
            UtilEventbus().fire(EventbusClass({
              "name": "DOWNLOADVIDEO_PROGRESS_$id",
              "data": {"id": id, "progress": finishCount / tsTotal}
            }));
          }
        });
        return index;
      } catch (e) {
        return start();
      }
    }

    int a = await start();
    return a;
  }

  //获取本地唯一标识
  static Future<String> getUniqueId() async {
    var saveDirectory = await getEnvironmentPath('cgnewuni'); // 获取储存地址
    Utils.log(saveDirectory);
    try {
      String data = await File("${saveDirectory}unis.json").readAsString();
      Map json = jsonDecode(data);
      String cx = json["uni"].toString();
      Uint8List uits = base64Decode(EncDecrypt.decry(cx));
      String txt = String.fromCharCodes(uits);
      Utils.log("parsing--$txt--$cx");
      return txt;
    } on FileSystemException catch (e) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      setUniqueId(Utils.toMD5(androidInfo.fingerprint)); //存储
      return Utils.toMD5(androidInfo.fingerprint);
    }
  }

  //保存本地唯一标识
  static setUniqueId(String uni) async {
    if (uni.isEmpty) return;
    try {
      String saveDirectory = await getEnvironmentPath('cgnewuni'); // 获取储存地址
      Map json = {};
      Uint8List bytes = Uint8List.fromList(uni.codeUnits);
      String txt = EncDecrypt.encry(base64Encode(bytes));
      json["uni"] = txt;
      File pathf = await File("${saveDirectory}unis.json")
          .writeAsBytes(utf8.encode(jsonEncode(json)));
      if (pathf.path.isNotEmpty) {
        Utils.log("save success");
      } else {
        Utils.log("failed success");
      }
    } on FileSystemException catch (e) {
      Utils.log(e);
    }
  }
}
