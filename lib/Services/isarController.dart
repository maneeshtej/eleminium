import 'package:course_app/Enums/playListType.dart';
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

  Future<void> createAndStoreVideo(
    String videoId,
    Map<String, dynamic>? data,
  ) async {
    final isarInstance = await isar;

    final video =
        Video()
          ..videoId = videoId
          ..watchedDuration = 0
          ..lastWatched = DateTime.now()
          ..totalDuration = 0
          ..isWatched = false
          ..title = data?['title']
          ..channelTitle = data?['channelTitle']
          ..thumbnailBytes = await fetchThumbnailBytes(
            data?['thumbnails']?['high']?['url'] ??
                data?['thumbnails']?['medium']?['url'] ??
                data?['thumbnails']?['default']?['url'],
          );

    await isarInstance.writeTxn(() async {
      await isarInstance.videos.put(video);
    });

    // print(data);
  }

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

  Future<void> updateVideoProgress(
    String videoId, {
    required int watchedDuration,
    required int totalDuration,
    required bool isWatched,
    String? title,
    String? thumbnailUrl,
    String? channelTitle,
  }) async {
    final isar = await this.isar;
    final video =
        await isar.videos.filter().videoIdEqualTo(videoId).findFirst();

    if (video != null) {
      video.watchedDuration = watchedDuration;
      video.totalDuration = totalDuration;
      video.isWatched = isWatched;
      video.lastWatched = DateTime.now();

      // Update metadata if provided and not empty
      if (title != null && title.isNotEmpty) video.title = title;
      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
        video.thumbnailBytes = await fetchThumbnailBytes(thumbnailUrl);
      }
      if (channelTitle != null && channelTitle.isNotEmpty) {
        video.channelTitle = channelTitle;
      }
      await isar.writeTxn(() async {
        await isar.videos.put(video);
      });
    }
  }

  Future<void> ensureDefaultPlaylistsExist() async {
    final isar = await this.isar;

    final liked =
        await isar.playlists
            .filter()
            .typeEqualTo(PlaylistType.liked)
            .findFirst();

    await isar.writeTxn(() async {
      if (liked == null) {
        await isar.playlists.put(
          Playlist()
            ..name = 'Liked'
            ..type = PlaylistType.liked,
        );
      }
    });
  }

  Future<void> toggleLikedStatus(
    String videoId,
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    final isar = await this.isar;

    await isar.writeTxn(() async {
      // Get or create video
      final existingVideo =
          await isar.videos.filter().videoIdEqualTo(videoId).findFirst();

      final video =
          existingVideo ??
          (Video()
            ..videoId = videoId
            ..watchedDuration = 0
            ..lastWatched = DateTime.now()
            ..totalDuration = 0
            ..isWatched = false
            ..title = data['title']
            ..channelTitle = data['channelTitle']
            ..thumbnailBytes = await fetchThumbnailBytes(
              data['thumbnails']?['high']?['url'] ??
                  data['thumbnails']?['medium']?['url'] ??
                  data['thumbnails']?['default']?['url'],
            ));

      // Ensure video is saved (newly created or updated existing)
      await isar.videos.put(video);

      // Get or create 'Liked' playlist
      Playlist? liked =
          await isar.playlists
              .filter()
              .typeEqualTo(PlaylistType.liked)
              .findFirst();

      if (liked == null) {
        liked =
            Playlist()
              ..name = 'Liked'
              ..type = PlaylistType.liked;
        await isar.playlists.put(liked);
      }

      await liked.videos.load(); // Load existing video links

      final isAlreadyLiked = liked.videos.any(
        (v) => v.videoId == video.videoId,
      );

      if (isAlreadyLiked) {
        // ❌ Remove from liked
        final toRemove =
            liked.videos.where((v) => v.videoId == video.videoId).toList();
        liked.videos.removeAll(toRemove);
        await liked.videos.save();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('💔 Removed from Liked'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // ✅ Add to liked
        liked.videos.add(video);
        await liked.videos.save();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❤️ Added to Liked'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Future<bool> isInLikedPlaylist(String videoId) async {
    final isar = await this.isar;

    final liked =
        await isar.playlists
            .filter()
            .typeEqualTo(PlaylistType.liked)
            .findFirst();

    if (liked == null) return false;

    await liked.videos.load();

    return liked.videos.any((video) => video.videoId == videoId);
  }

  Future<void> printLikedPlaylistVideos() async {
    final isar = await this.isar;

    // Get the 'Liked' playlist
    final liked =
        await isar.playlists
            .filter()
            .typeEqualTo(PlaylistType.liked)
            .findFirst();

    if (liked == null) {
      print('No "Liked" playlist found.');
      return;
    }

    await liked.videos.load();

    if (liked.videos.isEmpty) {
      print('"Liked" playlist is empty.');
    } else {
      print('Videos in "Liked" playlist:');
      for (var video in liked.videos) {
        print(' - ${video.title ?? video.videoId}');
      }
    }
  }
}
