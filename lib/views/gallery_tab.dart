import 'package:flutter/material.dart';
import 'package:gitgallery/api/network_service.dart';
import 'package:gitgallery/views/full_screen_image.dart';

class GalleryTab extends StatefulWidget {
  @override
  _GalleryTabState createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  late Future<List<dynamic>> _imagesFuture;
  final NetworkService _networkService = NetworkService();
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _fetchImagesOnce();
  }

  void _fetchImagesOnce() {
    if (_isFirstLoad) {
      _imagesFuture = _networkService.fetchImages();
      _isFirstLoad = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No images found.'));
        }

        final images = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refreshImages,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return GestureDetector(
                onTap: ()=> Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FullScreenImage(url: image['urls']['small'])),
                  ),
                child: Hero(
                  tag: image['urls']['small'],
                  child: Image.network(
                  image['urls']['small'],
                  fit: BoxFit.cover,
                ),
              ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _refreshImages() async {
    await _networkService.fetchImages(forceRefresh: true);
    setState(() {
      _imagesFuture = _networkService.fetchImages();
    });
  }
}
