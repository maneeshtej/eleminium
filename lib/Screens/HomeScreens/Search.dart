import 'package:course_app/Screens/InfoScreens/VideoDetails.dart';
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

  void _search() async {
    String query = _controller.text.trim();
    if (query.isEmpty) return;

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
      backgroundColor: Colors.grey.shade900, // Optional dark theme
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
            const SizedBox(height: 30),

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

            const SizedBox(height: 00),

            // Results Section
            if (_isLoading)
              Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_results.isEmpty)
              Text("No results yet.", style: TextStyle(color: Colors.white70))
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
                          color: Colors.grey.shade900,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                              left: 5,
                            ),
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
