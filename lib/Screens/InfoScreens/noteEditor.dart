import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NoteEditorPage extends StatefulWidget {
  final String? initialNote;
  final List<String>? initialImages;

  const NoteEditorPage({super.key, this.initialNote, this.initialImages});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialNote ?? '';
    _images.addAll(widget.initialImages ?? []);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      setState(() => _images.add(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note Editor"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'note': _controller.text.trim(),
                'images': _images,
              });
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(hintText: "Write your note..."),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children:
                  _images.map((path) {
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.file(
                          File(path),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => _images.remove(path));
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    );
                  }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
