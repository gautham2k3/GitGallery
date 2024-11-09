import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive/hive.dart';

class FullScreenImage extends StatefulWidget {
  final String url;
  const FullScreenImage({super.key, required this.url});

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  late Box<String> bookmarkBox;
  late bool isBookmarked;

  @override
  void initState() {
    super.initState();
    bookmarkBox = Hive.box<String>('bookmarks');
    isBookmarked = bookmarkBox.containsKey(widget.url);
  }

  void refreshBox() {
    setState(() {
      isBookmarked = bookmarkBox.containsKey(widget.url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              if (isBookmarked) {
                bookmarkBox.delete(widget.url);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bookmark Removed')),
                );
              } else {
                bookmarkBox.put(widget.url, widget.url);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bookmark Added')),
                );
              }
              refreshBox();
            },
            icon: Icon(
              isBookmarked ? Icons.bookmark_remove : Icons.bookmark_add_outlined,
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: widget.url,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: widget.url,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
