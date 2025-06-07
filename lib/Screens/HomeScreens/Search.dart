import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course_app/Screens/InfoScreens/videoDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:course_app/Services/DataController.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _controller = TextEditingController();
  final Datacontroller _dataController = Get.put(Datacontroller());
  String? _nextPageToken;
  ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  String _lastQuery = '';

  List<Map<String, String>> _results = [];
  bool _isLoading = false;
  List<String> _history = [];

  void _search() async {
    String input = _controller.text.trim();
    if (input.isEmpty) return;

    String? extractVideoId(String input) {
      final uri = Uri.tryParse(input);
      if (uri == null) return null;

      // Example URLs:
      // https://www.youtube.com/watch?v=VIDEOID
      // https://youtu.be/VIDEOID

      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      } else if (uri.host == 'youtu.be') {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      }
      return null;
    }

    // Check if input is a YouTube URL and extract video ID
    final videoId = extractVideoId(input);
    if (videoId != null) {
      // It's a video URL - go directly to VideoDetails page
      FocusScope.of(context).unfocus(); // hide keyboard
      Get.to(VideoDetails(videoId: videoId));
      return;
    }

    // Not a URL, perform search
    _saveSearchQuery(input);

    setState(() {
      _isLoading = true;
      _lastQuery = input;
    });

    final data = await _dataController.searchYoutube(input);
    setState(() {
      _results = data['results'];
      _nextPageToken = data['nextPageToken'];
      _isLoading = false;
    });
  }

  void _saveSearchQuery(String query) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection('users')
        .doc(uid)
        .collection('searchHistory')
        .add({'query': query, 'timestamp': FieldValue.serverTimestamp()});
  }

  void _fetchSearchQueries() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final firestore = FirebaseFirestore.instance;

    final snapshot =
        await firestore
            .collection('users')
            .doc(uid)
            .collection('searchHistory')
            .orderBy('timestamp', descending: true)
            .limit(20)
            .get();

    if (!mounted) return;

    setState(() {
      final allQueries =
          snapshot.docs.map((doc) => doc['query'] as String).toList();

      // Use a LinkedHashSet to preserve order and remove duplicates
      final uniqueQueries = LinkedHashSet<String>.from(allQueries).toList();

      _history = uniqueQueries;
    });
  }

  void _loadMore() async {
    if (_nextPageToken == null || _isFetchingMore) return;

    setState(() => _isFetchingMore = true);

    final data = await _dataController.searchYoutube(
      _lastQuery,
      pageToken: _nextPageToken,
    );

    setState(() {
      _results.addAll(data['results']);
      _nextPageToken = data['nextPageToken'];
      _isFetchingMore = false;
    });
  }

  Future<void> _refresh() async {
    if (_lastQuery.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _results.clear();
    });

    final data = await _dataController.searchYoutube(_lastQuery);
    setState(() {
      _results = data['results'];
      _nextPageToken = data['nextPageToken'];
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        _loadMore();
      }
    });
    _fetchSearchQueries();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Text(
                "Search",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Got any cookies?...",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 30),

              // Search Bar
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              _results.clear();
                              _nextPageToken = null;
                              _isLoading = false;
                            });
                          }
                        },
                        controller: _controller,
                        onSubmitted: (_) => _search(),
                        decoration: InputDecoration(
                          hintText: "Search YouTube or paste URL",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.grey.shade900),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.black),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _search();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Main Content
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_results.isEmpty)
                if (_history.isNotEmpty)
                  ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _history.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.grey),
                    itemBuilder: (context, index) {
                      final recentQuery = _history[index];
                      return ListTile(
                        title: Text(
                          recentQuery,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          _controller.text = recentQuery;
                          _search();
                        },
                        trailing: const Icon(Icons.history, color: Colors.grey),
                      );
                    },
                  )
                else
                  const SizedBox.shrink()
              else
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _results.length + (_isFetchingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _results.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final video = _results[index];
                        return GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            Get.to(VideoDetails(videoId: video['id']!));
                          },
                          child: Card(
                            color: Colors.black,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.only(left: 5),
                              leading: Image.network(
                                video['thumbnail']!,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                video['title']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                video['creator']!,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
