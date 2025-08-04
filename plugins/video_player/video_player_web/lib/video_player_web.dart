// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'src/shims/dart_ui.dart' as ui;
import 'src/video_player.dart';

/// The web implementation of [VideoPlayerPlatform].
///
/// This class implements the `package:video_player` functionality for the web.
class VideoPlayerPlugin extends VideoPlayerPlatform {
  /// Registers this class as the default instance of [VideoPlayerPlatform].
  static void registerWith(Registrar registrar) {
    final plugin = VideoPlayerPlugin().._initPool();
    VideoPlayerPlatform.instance = plugin;
    late final StreamSubscription _subscription;
    _subscription = window.onClick.listen((event) {
      plugin._blessing();
      _subscription.cancel();
    });
  }

  // Map of textureId -> VideoPlayer instances
  final Map<int, VideoPlayer> _videoPlayers = <int, VideoPlayer>{};

  // Simulate the native "textureId".
  int _textureCounter = 1;

  final _available = Queue<int>();
  final _unavailable = Set<int>();
  bool _isBlessed = false;

  @override
  Future<void> init() async {
    _disposeAllPlayers();
  }

  void _initPool() {
    for (var i = 1; i <= 6; i++) {
      final int textureId = _textureCounter++;
      _createPlayer(textureId)..muted = true;
      _available.add(textureId);
    }
    _isBlessed = false;
  }

  void _blessing() {
    if (_isBlessed) return;
    _isBlessed = true;
    [..._available, ..._unavailable].forEach((element) {
      _player(element).muted(false);
    });
  }

  @override
  Future<void> dispose(int textureId) async {
    _player(textureId).dispose();
    if (_unavailable.remove(textureId)) {
      _available.add(textureId);
    } else if (!_available.contains(textureId)) {
      _videoPlayers.remove(textureId);
    }
  }

  void _disposeAllPlayers() {
    for (final int textureId in _videoPlayers.keys) {
      dispose(textureId);
    }
  }

  VideoElement _createPlayer(int textureId) {
    final videoElement = VideoElement()
      ..style.border = 'none'
      ..style.height = '100%'
      ..style.width = '100%';

    ui.platformViewRegistry.registerViewFactory(
        'videoPlayer-$textureId', (int viewId) => videoElement);

    final VideoPlayer player = VideoPlayer(videoElement: videoElement);

    _videoPlayers[textureId] = player;
    return videoElement;
  }

  @override
  Future<int> create(DataSource dataSource) async {
    late String uri;
    switch (dataSource.sourceType) {
      case DataSourceType.network:
        // Do NOT modify the incoming uri, it can be a Blob, and Safari doesn't
        // like blobs that have changed.
        uri = dataSource.uri ?? '';
        break;
      case DataSourceType.asset:
        String assetUrl = dataSource.asset!;
        if (dataSource.package != null && dataSource.package!.isNotEmpty) {
          assetUrl = 'packages/${dataSource.package}/$assetUrl';
        }
        assetUrl = ui.webOnlyAssetManager.getAssetUrl(assetUrl);
        uri = assetUrl;
        break;
      case DataSourceType.file:
        return Future<int>.error(UnimplementedError(
            'web implementation of video_player cannot play local files'));
      case DataSourceType.contentUri:
        return Future<int>.error(UnimplementedError(
            'web implementation of video_player cannot play content uri'));
    }

    late final int textureId;
    if (_available.isEmpty) {
      textureId = _textureCounter++;
      _createPlayer(textureId);
    } else {
      textureId = _available.removeFirst();
      _unavailable.add(textureId);
    }
    changeVideo(textureId, uri);

    return textureId;
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {
    return _player(textureId).setLooping(looping);
  }

  @override
  Future<void> play(int textureId) async {
    if (!_isBlessed) return;
    return _player(textureId).play();
  }

  @override
  Future<void> pause(int textureId) async {
    return _player(textureId).pause();
  }

  @override
  Future<void> setVolume(int textureId, double volume) async {
    return _player(textureId).setVolume(volume);
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {
    return _player(textureId).setPlaybackSpeed(speed);
  }

  @override
  Future<void> seekTo(int textureId, Duration position) async {
    return _player(textureId).seekTo(position);
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    return _player(textureId).getPosition();
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return _player(textureId).events;
  }

  // Retrieves a [VideoPlayer] by its internal `id`.
  // It must have been created earlier from the [create] method.
  VideoPlayer _player(int id) {
    return _videoPlayers[id]!;
  }

  @override
  Widget buildView(int textureId) {
    return HtmlElementView(viewType: 'videoPlayer-$textureId');
  }

  /// Sets the audio mode to mix with other sources (ignored)
  @override
  Future<void> setMixWithOthers(bool mixWithOthers) => Future<void>.value();

  @override
  void requestFullScreen(int textureId) {
    _player(textureId).requestFullScreen();
  }

  @override
  void exitFullScreen(int textureId) {
    _player(textureId).exitFullScreen();
  }

  @override
  Future<void> changeVideo(int textureId, String src) async {
    await _player(textureId).changeVideo(src);
  }
}
