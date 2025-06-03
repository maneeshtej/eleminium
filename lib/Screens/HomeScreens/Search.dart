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

  List<Map<String, String>> _results = [];
  bool _isLoading = false;

  void _search() async {
    String query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    List<Map<String, String>> results = await _dataController.searchYoutube(
      query,
    );
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900, // Optional dark theme
      body: SingleChildScrollView(
        child: Padding(
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
                Center(child: CircularProgressIndicator())
              else if (_results.isEmpty)
                Text("No results yet.", style: TextStyle(color: Colors.white70))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final video = _results[index];
                    return Card(
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
                      // ListTile(
                      //   leading: Image.network(
                      //     video['thumbnail']!,
                      //     width: 100,
                      //     fit: BoxFit.cover,
                      //   ),
                      //   title: Text(
                      //     video['title']!,
                      //     style: TextStyle(color: Colors.white, fontSize: 14),
                      //   ),
                      //   subtitle: Text(
                      //     video['creator']!,
                      //     style: TextStyle(color: Colors.grey, fontSize: 12),
                      //   ),
                      //   trailing: PopupMenuButton<String>(
                      //     icon: Icon(Icons.more_vert, color: Colors.white),
                      //     onSelected: (value) {
                      //       if (value == 'open') {
                      //         Get.toNamed(
                      //           '/videoPlayer',
                      //           arguments: video['url'],
                      //         );
                      //       } else if (value == 'copy') {
                      //         Get.snackbar(
                      //           'Copied',
                      //           'Video link copied to clipboard',
                      //           snackPosition: SnackPosition.BOTTOM,
                      //         );
                      //       } else if (value == 'share') {}
                      //     },
                      //     itemBuilder:
                      //         (BuildContext context) =>
                      //             <PopupMenuEntry<String>>[
                      //               PopupMenuItem<String>(
                      //                 value: 'open',
                      //                 child: Text('Open Video'),
                      //               ),
                      //               PopupMenuItem<String>(
                      //                 value: 'copy',
                      //                 child: Text('Copy Link'),
                      //               ),
                      //               PopupMenuItem<String>(
                      //                 value: 'share',
                      //                 child: Text('Share'),
                      //               ),
                      //             ],
                      //   ),
                      //   onTap: () {
                      //     // Optional: tap behavior
                      //   },
                      // ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
