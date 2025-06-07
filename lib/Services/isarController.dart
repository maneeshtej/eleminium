import 'dart:typed_data';

import 'package:course_app/Model/playlist.dart';
import 'package:course_app/Model/video.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class Isarcontroller extends GetxController {
  late final Future<Isar> isar;

  @override
  void onInit() {
    super.onInit();
    isar = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open([VideoSchema, PlaylistSchema], directory: dir.path);
  }

  // --------------------------------------
  // ---------  PLAYLIST INIT -------------
  // --------------------------------------

  Future<void> defaultPlaylistInitialize() async {
    final isar = await this.isar;

    final liked =
        await isar.playlists.filter().playlistNameEqualTo("Liked").findFirst();
    final watchLater =
        await isar.playlists
            .filter()
            .playlistNameEqualTo("Watch Later")
            .findFirst();
    final history =
        await isar.playlists
            .filter()
            .playlistNameEqualTo("History")
            .findFirst();

    await isar.writeTxn(() async {
      if (liked == null) {
        await isar.playlists.put(Playlist()..playlistName = "Liked");
      }

      if (watchLater == null) {
        await isar.playlists.put(Playlist()..playlistName = "Watch Later");
      }

      if (history == null) {
        await isar.playlists.put(Playlist()..playlistName = "History");
      }
    });
  }

  Future<void> clearAllData() async {
    final isar = await this.isar;

    await isar.writeTxn(() async {
      // Delete all playlists (this also clears all links)
      await isar.playlists.clear();

      // Delete all videos
      await isar.videos.clear();
    });
  }

  // --------------------------------------
  // -------------- UTILITY ---------------
  // --------------------------------------

  Future<List<int>?> fetchThumbnailBytes(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) return response.bodyBytes;
      print('Failed to fetch thumbnail: ${response.statusCode}');
    } catch (e) {
      print('Error fetching thumbnail: $e');
    }
    return null;
  }

  Future<Video> convertMapStringDynamictoVideo(
    String videoId,
    Map<String, dynamic>? data,
  ) async {
    if (data == null) {
      return Video();
    }
    final video =
        Video()
          ..videoId = videoId
          ..watchedDuration = 0
          ..totalDuration = 0
          ..lastWatched = DateTime.now()
          ..isWatched = false
          ..title = data['title']
          ..channelTitle = data['channelTitle']
          ..thumbnailBytes = await fetchThumbnailBytes(
            data['thumbnails']?['high']?['url'] ??
                data['thumbnails']?['medium']?['url'] ??
                data['thumbnails']?['default']?['url'],
          );

    return video;
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final isar = await this.isar;

    final playlists = await isar.playlists.where().findAll();

    for (final playlist in playlists) {
      await playlist.videos.load();
    }

    return playlists;
  }

  // --------------------------------------
  // -------------- VIDEOS ----------------
  // --------------------------------------

  Future<void> createVideo(String videoId, Map<String, dynamic>? data) async {
    final isar = await this.isar;

    final video = await convertMapStringDynamictoVideo(videoId, data);

    await isar.writeTxn(() async {
      await isar.videos.put(video);
    });
  }

  // Update existing video with snackbar
  Future<void> updateVideo(Video existing, Map<String, dynamic>? data) async {
    final isar = await this.isar;

    existing.lastWatched = DateTime.now();

    // Update all fields if present and valid in data
    if (data != null) {
      if (data['watchedDuration'] != null) {
        existing.watchedDuration = data['watchedDuration'] as int;
      }
      if (data['totalDuration'] != null) {
        existing.totalDuration = data['totalDuration'] as int;
      }
      if (data['isWatched'] != null) {
        existing.isWatched = data['isWatched'] as bool;
      }
      if (data['title'] != null && (data['title'] as String).isNotEmpty) {
        existing.title = data['title'] as String;
      }
      if (data['channelTitle'] != null &&
          (data['channelTitle'] as String).isNotEmpty) {
        existing.channelTitle = data['channelTitle'] as String;
      }

      // Update thumbnailBytes if a valid URL is provided
      final thumbUrl =
          (data['thumbnails']?['high']?['url'] ??
                  data['thumbnails']?['medium']?['url'] ??
                  data['thumbnails']?['default']?['url'])
              as String?;

      if (thumbUrl != null && thumbUrl.isNotEmpty) {
        existing.thumbnailBytes = await fetchThumbnailBytes(thumbUrl);
      }
    }

    await isar.writeTxn(() async {
      await isar.videos.put(existing);
    });

    print("updated");
  }

  // Combined create or update with snackbar
  Future<Video> createOrUpdateVideo(
    String videoId,
    Map<String, dynamic>? data,
  ) async {
    final isar = await this.isar;

    final existing =
        await isar.videos.filter().videoIdEqualTo(videoId).findFirst();

    if (existing != null) {
      await updateVideo(existing, data);
      return existing;
    } else {
      await createVideo(videoId, data);
      final newVideo =
          await isar.videos.filter().videoIdEqualTo(videoId).findFirst();
      return newVideo!;
    }
  }

  Future<List<Map<String, dynamic>>> getHistoryVideosMinimal() async {
    try {
      final isar = await this.isar;

      final sortedVideos =
          await isar.videos
              .filter()
              .watchedDurationGreaterThan(0)
              .sortByLastWatchedDesc()
              .findAll();

      return sortedVideos.map((video) {
        return {
          'videoId': video.videoId,
          'title': video.title ?? '',
          'thumbnailBytes': video.thumbnailBytes ?? Uint8List(0),
          'channelTitle': video.channelTitle ?? '',
        };
      }).toList();
    } catch (e, st) {
      print('Error fetching history videos: $e\n$st');
      return [];
    }
  }

  // --------------------------------------
  // --------- LIKED PLAYLIST -------------
  // --------------------------------------

  Future<void> toggleLiked(
    String videoId,
    Map<String, dynamic>? data,
    BuildContext context,
  ) async {
    final isar = await this.isar;

    final liked =
        await isar.playlists.filter().playlistNameEqualTo("Liked").findFirst();

    if (liked == null) {
      print("Liked playlist does not exist!!!");
      return;
    }

    Video? video =
        await isar.videos.filter().videoIdEqualTo(videoId).findFirst();

    if (video == null) {
      video = await convertMapStringDynamictoVideo(videoId, data);

      await createOrUpdateVideo(videoId, data);
    }

    // Load linked videos
    await liked.videos.load();

    // Check if video already exists in the liked playlist
    final doesExist = await isLiked(videoId);

    await isar.writeTxn(() async {
      if (doesExist) {
        // Find the exact video instance in the link and remove it
        final existingVideo = liked.videos.firstWhere(
          (v) => v.videoId == video?.videoId,
        );
        liked.videos.remove(existingVideo);
      } else {
        liked.videos.add(video!);
      }
      await liked.videos.save();
    });
  }

  Future<bool> isLiked(String videoId) async {
    final isar = await this.isar;

    final liked =
        await isar.playlists.filter().playlistNameEqualTo("Liked").findFirst();

    if (liked == null) {
      print("Liked does not exist!!!");
      return false;
    }

    await liked.videos.load();

    final doesExist = liked.videos.toList().any(
      (video) => video.videoId == videoId,
    );

    return doesExist;
  }

  Future<List<Map<String, dynamic>>> getLikedVideosMinimal() async {
    final isar = await this.isar;

    final liked =
        await isar.playlists.filter().playlistNameEqualTo("Liked").findFirst();

    if (liked == null) {
      return [{}];
    }

    await liked.videos.load();

    final likedVideos =
        await liked.videos.map((video) {
          return {
            'videoId': video.videoId,
            'title': video.title,
            'thumbnailBytes': video.title,
            'channelTitle': video.channelTitle,
          };
        }).toList();

    return likedVideos;
  }

  // --------------------------------------
  // ------ WATCH LATER PLAYLIST ----------
  // --------------------------------------

  Future<void> toggleWatchLater(
    String videoId,
    Map<String, dynamic>? data,
    BuildContext context,
  ) async {
    final isar = await this.isar;

    final watchLater =
        await isar.playlists
            .filter()
            .playlistNameEqualTo("Watch Later")
            .findFirst();

    if (watchLater == null) {
      print("Watch Later playlist does not exist!!!");
      return;
    }

    Video? video =
        await isar.videos.filter().videoIdEqualTo(videoId).findFirst();

    if (video == null) {
      video = await convertMapStringDynamictoVideo(videoId, data);

      await createOrUpdateVideo(videoId, data);
    }

    // Load linked videos
    await watchLater.videos.load();

    // Check if video already exists in the watch later playlist
    final doesExist = await isWatchLater(videoId);

    await isar.writeTxn(() async {
      if (doesExist) {
        // Find the exact video instance in the link and remove it
        final existingVideo = watchLater.videos.firstWhere(
          (v) => v.videoId == video?.videoId,
        );
        watchLater.videos.remove(existingVideo);
      } else {
        watchLater.videos.add(video!);
      }
      await watchLater.videos.save();
    });
  }

  Future<bool> isWatchLater(String videoId) async {
    final isar = await this.isar;

    final watchLater =
        await isar.playlists
            .filter()
            .playlistNameEqualTo("Watch Later")
            .findFirst();

    if (watchLater == null) {
      print("Watch Later does not exist!!!");
      return false;
    }

    await watchLater.videos.load();

    final doesExist = watchLater.videos.toList().any(
      (video) => video.videoId == videoId,
    );

    return doesExist;
  }

  Future<List<Map<String, dynamic>>> getWatchLaterVideosMinimal() async {
    final isar = await this.isar;

    final watchLater =
        await isar.playlists
            .filter()
            .playlistNameEqualTo("Watch Later")
            .findFirst();

    if (watchLater == null) {
      return [];
    }

    await watchLater.videos.load();

    final watchLaterVideos =
        watchLater.videos.map((video) {
          return {
            'videoId': video.videoId,
            'title': video.title,
            'thumbnailBytes': video.thumbnailBytes,
            'channelTitle': video.channelTitle,
          };
        }).toList();

    return watchLaterVideos;
  }

  // --------------------------------------
  // ------------- HISTORY ----------------
  // --------------------------------------

  Future<void> insertOrUpdateintoHistory(
    String videoId,
    Map<String, dynamic> data,
  ) async {
    final isar = await this.isar;

    final history =
        await isar.playlists
            .filter()
            .playlistNameEqualTo("History")
            .findFirst();

    if (history == null) {
      return;
    }

    await createOrUpdateVideo(videoId, data);

    final video =
        await isar.videos.filter().videoIdEqualTo(videoId).findFirst();
    if (video == null) return;

    await isar.writeTxn(() async {
      await history.videos.load();
      final doesExist = await history.videos.any(
        (v) => v.videoId == video.videoId,
      );

      if (doesExist) return;

      history.videos.add(video);
      await history.videos.save();
    });
  }

  // --------------------------------------
  // --------- CUSTOM PLAYLIST ------------
  // --------------------------------------

  Future<void> createPlaylist(String name) async {
    final isar = await this.isar;

    final doesExist =
        await isar.playlists.filter().playlistNameEqualTo(name).findFirst();

    if (doesExist != null) {
      return;
    }

    await isar.writeTxn(() async {
      await isar.playlists.put(Playlist()..playlistName = name);
    });
  }

  Future<void> deletePlaylist(String name) async {
    final isar = await this.isar;

    final doesExist =
        await isar.playlists.filter().playlistNameEqualTo(name).findFirst();

    if (doesExist != null) {
      await isar.playlists.delete(doesExist.id);
    }
  }

  Future<void> addToPlaylist(
    String name,
    String videoId,
    Map<String, dynamic>? data,
  ) async {
    final isar = await this.isar;

    final playlist =
        await isar.playlists.filter().playlistNameEqualTo(name).findFirst();

    if (playlist == null) return;

    // Step 1: Write/update video to DB
    await createOrUpdateVideo(videoId, data);

    // Step 2: Get the video back with ID from the DB
    final video =
        await isar.videos.filter().videoIdEqualTo(videoId).findFirst();
    if (video == null) return;

    await isar.writeTxn(() async {
      await playlist.videos.load();

      final alreadyExists = playlist.videos.any(
        (v) => v.videoId == video.videoId,
      );
      if (alreadyExists) return;

      playlist.videos.add(video);
      await playlist.videos.save();
    });
  }

  Future<void> removeFromPlaylist(String videoId, String name) async {
    final isar = await this.isar;

    final playlist =
        await isar.playlists.filter().playlistNameEqualTo(name).findFirst();

    if (playlist == null) return;

    await isar.writeTxn(() async {
      await playlist.videos.load();

      final videoToRemove =
          playlist.videos
              .where((v) => v.videoId == videoId)
              .cast<Video?>()
              .firstOrNull;

      if (videoToRemove != null) {
        await playlist.videos.remove(videoToRemove);
      }
    });
  }
}
