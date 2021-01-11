library animated_image_list;

import 'dart:ui';
import 'package:flutter/material.dart';
import "package:flutter/widgets.dart";
import "dart:math";
import 'SnappingListView.dart';
import 'photoViewerArbnb/PhotoViewerArbnb_page.dart';
import 'photoViewerArbnb/PhotoViewerArbnb_screen.dart';
import 'photoViewerArbnb/TransparentRoute.dart';

typedef ItemBuilder = Widget Function(
    BuildContext context, int index, double progress);

class AnimatedImageList extends StatelessWidget {
  final List<String> images;
  final ProviderBuilder provider;
  final ProviderBuilder placeHolder;
  final ItemBuilder builder;
  final Axis scrollDirection;
  final int itemExtent;
  final int maxExtent;
  const AnimatedImageList(
      {Key key,
      this.images,
      this.provider,
      this.placeHolder,
      this.builder,
      this.itemExtent = 150,
      this.maxExtent = 400,
      this.scrollDirection = Axis.vertical})
      : assert(images != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SnappingListView.builder(
        itemBuilder: (context, index, progress, maxHeight) {
          // print(maxHeight);
          String photo = images[index];
          return Padding(
              padding: const EdgeInsets.all(5),
              child: Hero(
                  tag: "$photo-$index",
                  child: Material(
                      color: Colors.transparent,
                      elevation: 10,
                      clipBehavior: Clip.antiAlias,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(TransparentRoute(
                            builder: (BuildContext context) =>
                                PhotoViewerArbnbPage(photo, index),
                          ));
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            OverflowBox(
                              maxHeight: maxHeight,
                              minHeight: 150,
                              child: Container(
                                  height: maxHeight,
                                  child: Transform(
                                      transform: Matrix4.identity()
                                        ..translate(
                                            0.0,
                                            progress > 1
                                                ? max(
                                                    maxHeight * (progress - 1),
                                                    0.0)
                                                : 0),
                                      child: provider != null
                                          ? provider(photo)
                                          : Image.network(
                                              photo,
                                              fit: BoxFit.fill,
                                              loadingBuilder:
                                                  (context, _, progress) =>
                                                      CircularProgressIndicator(
                                                value: progress
                                                        .cumulativeBytesLoaded /
                                                    progress.expectedTotalBytes,
                                              ),
                                            ))),
                            ),
                            Positioned.directional(
                                textDirection: TextDirection.ltr,
                                bottom: 0,
                                start: 0,
                                top: 0,
                                end: 0,
                                child: builder?.call(context, index, progress))
                          ],
                        ),
                      ))));
        },
        itemCount: images.length,
        scrollDirection: scrollDirection,
        itemExtent: 150,
        maxExtent: 400,
      ),
    );
  }
}
