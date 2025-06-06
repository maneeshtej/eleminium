import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course_app/Screens/InfoScreens/videoDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    String query = _controller.text.trim();
    if (query.isEmpty) return;

    _saveSearchQuery(query);

    setState(() {
      _isLoading = true;
      _lastQuery = query;
    });

    final data = await _dataController.searchYoutube(query);
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
            .limit(10)
            .get();

    setState(() {
      _history = snapshot.docs.map((doc) => doc['query'] as String).toList();
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
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Search",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Got any cookies?...",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 30),

            // Search Bar
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
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
                    onPressed: _search,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Main Content
            if (_isLoading)
              Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_results.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_history.isNotEmpty) ...[
                    SizedBox(
                      height: 400,
                      child: ListView.separated(
                        itemCount: _history.length,
                        separatorBuilder:
                            (_, __) => Divider(color: Colors.grey),
                        itemBuilder: (context, index) {
                          final recentQuery = _history[index];
                          return ListTile(
                            title: Text(
                              recentQuery,
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              _controller.text = recentQuery;
                              _search();
                            },
                            trailing: Icon(Icons.history, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _results.length + (_isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _results.length) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final video = _results[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(VideoDetails(videoId: video['id']!));
                        },
                        child: Card(
                          color: Colors.black,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.only(left: 5),
                            leading: Image.network(
                              video['thumbnail']!,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              video['title']!,
                              style: TextStyle(
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
    );
  }
}
