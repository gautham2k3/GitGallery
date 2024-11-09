import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive/hive.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'full_screen_image.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late Box<String> bookmarkBox;
  late List<String> bookmarkedImages;

  @override
  void initState() {
    super.initState();
    bookmarkBox = Hive.box<String>('bookmarks');
    bookmarkedImages = bookmarkBox.values.toList();
  }
  void refreshBookmarks() {
    setState(() {
      bookmarkedImages = bookmarkBox.values.toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: Colors.black,
      ),
      body: bookmarkedImages.isEmpty
          ? const Center(
        child: Text(
          'No bookmarks yet',
          style: TextStyle(fontSize: 18),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: MasonryGridView.builder(
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: bookmarkedImages.length,
          itemBuilder: (context, index) {
            final imageUrl = bookmarkedImages[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(url: imageUrl),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.red),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}