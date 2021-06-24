import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoZoom extends StatefulWidget {
  int index;
  List images;

  PhotoZoom(int index, List images) {
    this.index = index;
    this.images = images;
  }

  _PhotoZoom createState() => _PhotoZoom(index, images);
}

class _PhotoZoom extends State<PhotoZoom> {
  int currentIndex;
  int initialIndex;
  List images;

  _PhotoZoom(int index, List images) {
    this.currentIndex = index;
    this.initialIndex = index;
    this.images = images;
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[Container(
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(images[index],
                    ),
                    initialScale: PhotoViewComputedScale.contained * 0.8,
                    heroAttributes: PhotoViewHeroAttributes(tag: index),
                  );
                },
                itemCount: images.length,
                loadingBuilder: (context, event) => Center(
                  child: Container(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      value: event == null
                          ? 0
                          : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                    ),
                  ),
                ),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
                pageController: PageController(initialPage: initialIndex),
                onPageChanged: onPageChanged,
              )),new IconButton(
              icon: new Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => {
                Navigator.pop(context)
              })],
        ),
      ),
    );
  }
}
