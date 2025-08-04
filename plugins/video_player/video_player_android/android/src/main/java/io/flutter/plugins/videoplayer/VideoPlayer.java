// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static androidx.media3.common.Player.REPEAT_MODE_ALL;
import static androidx.media3.common.Player.REPEAT_MODE_OFF;

import android.app.Activity;
import android.content.Context;
import android.nfc.Tag;
import android.util.Log;
import android.view.Surface;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.media3.common.AudioAttributes;
import androidx.media3.common.C;
import androidx.media3.common.MediaItem;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.exoplayer.ExoPlayer;

import io.flutter.view.TextureRegistry;
import tv.danmaku.ijk.media.player.IjkMediaPlayer;


final class VideoPlayer {
    private static final String TAG = "VideoPlayer";
    private Activity activity;
    private IjkMediaPlayer ijkMediaPlayer;
    private Surface surface;
    private final TextureRegistry.SurfaceTextureEntry textureEntry;
    private final VideoPlayerCallbacks videoPlayerEvents;
    private final VideoPlayerOptions options;

    /**
     * Creates a video player.
     *
     * @param context      application context.
     * @param events       event callbacks.
     * @param textureEntry texture to render to.
     * @param asset        asset to play.
     * @param options      options for playback.
     * @return a video player instance.
     */
    @NonNull
    static VideoPlayer create(
            Activity activity,
            Context context,
            VideoPlayerCallbacks events,
            TextureRegistry.SurfaceTextureEntry textureEntry,
            VideoAsset asset,
            String url,
            VideoPlayerOptions options) {
        IjkMediaPlayer.loadLibrariesOnce(null);
        IjkMediaPlayer.native_profileBegin("libijkplayer.so");
        return new VideoPlayer(activity, events, textureEntry, asset, url, options);
    }

    @VisibleForTesting
    VideoPlayer(
            Activity activity,
            VideoPlayerCallbacks events,
            TextureRegistry.SurfaceTextureEntry textureEntry,
            VideoAsset asset,
            String url,
            VideoPlayerOptions options) {
        this.activity = activity;
        this.videoPlayerEvents = events;
        this.textureEntry = textureEntry;
        this.options = options;
        ijkMediaPlayer = new IjkMediaPlayer();
        try {
            ijkMediaPlayer.setDataSource(url);
            ijkMediaPlayer.prepareAsync();
        } catch (Exception e) {
            Log.wtf(TAG, "Error setting data source: " + e.getMessage());
        }

        setUpVideoPlayer();
    }

    private void setUpVideoPlayer() {
        surface = new Surface(textureEntry.surfaceTexture());
        ijkMediaPlayer.setSurface(surface);
        setAudioAttributes(options.mixWithOthers);
        ijkMediaPlayer.setOnPreparedListener(mp -> {
            int width = mp.getVideoWidth();
            int height = mp.getVideoHeight();
            long duration = mp.getDuration();
            videoPlayerEvents.onInitialized(width, height, duration, 0);
        });
        ijkMediaPlayer.setOnCompletionListener(mp -> videoPlayerEvents.onCompleted());
        ijkMediaPlayer.setOnErrorListener((mp, what, extra) -> {
            Log.wtf(TAG, "IJKPlayer error: " + what + ", " + extra);
            return true;
        });
        ijkMediaPlayer.setOnBufferingUpdateListener((mp, percent) ->
                videoPlayerEvents.onBufferingUpdate(percent * mp.getDuration() / 100));
    }

    void sendBufferingUpdate() {

        // This method is not directly needed for IJKPlayer as it uses a listener
//    videoPlayerEvents.onBufferingUpdate(exoPlayer.getBufferedPosition());
    }

    private static void setAudioAttributes(boolean isMixMode) {
//    exoPlayer.setAudioAttributes(
//        new AudioAttributes.Builder().setContentType(C.AUDIO_CONTENT_TYPE_MOVIE).build(),
//        !isMixMode);
    }

    void play() {
        ijkMediaPlayer.start();
    }

    void pause() {
        ijkMediaPlayer.pause();
    }

    void setLooping(boolean value) {
        ijkMediaPlayer.setLooping(value);
    }

    void setVolume(double value) {
        float bracketedValue = (float) Math.max(0.0, Math.min(1.0, value));
        ijkMediaPlayer.setVolume(bracketedValue, bracketedValue);
    }

    // 添加新的方法来设置亮度
    void setBrightness(double brightness) {
        if (activity == null) return;

        float brightnessValue = (float) Math.max(0.0, Math.min(1.0, brightness));

        activity.runOnUiThread(() -> {
            Window window = activity.getWindow();
            WindowManager.LayoutParams layoutParams = window.getAttributes();
            layoutParams.screenBrightness = brightnessValue;
            window.setAttributes(layoutParams);
        });
    }

    void setPlaybackSpeed(double value) {
        ijkMediaPlayer.setSpeed((float) value);
    }

    void seekTo(int location) {
        ijkMediaPlayer.seekTo(location);
    }

    long getPosition() {
        return ijkMediaPlayer.getCurrentPosition();
    }

    void dispose() {
        textureEntry.release();
        if (surface != null) {
            surface.release();
        }
        if (ijkMediaPlayer != null) {
            ijkMediaPlayer.release();
        }
        IjkMediaPlayer.native_profileEnd();
    }
}
