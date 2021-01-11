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
  final double itemExtent;
  final double maxExtent;
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
    // print(images);
    return Container(
      child: SnappingListView.builder(
        itemBuilder: (context, index, progress, maxSize) {
          // print(maxHeight);
          String photo = images[index];
          var isVertical = scrollDirection == Axis.vertical;
          double translate =
              progress > 1 ? max(maxSize * (progress - 1.0), 0.0) : 0.0;
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
                              maxHeight: isVertical ? maxSize : null,
                              minHeight: isVertical ? itemExtent : null,
                              maxWidth: isVertical ? null : maxSize,
                              minWidth: isVertical ? null : itemExtent,
                              child: Container(
                                  height: isVertical ? maxSize : null,
                                  width: isVertical ? null : maxSize,
                                  child: Transform(
                                      transform: Matrix4.identity()
                                        ..translate(
                                            !isVertical ? translate : 0.0,
                                            isVertical ? translate : 0.0),
                                      child: provider != null
                                          ? provider(photo)
                                          : Image.network(
                                              photo,
                                              fit: BoxFit.fill,
                                              // height: maxHeight,
                                              // width: 200,
                                              loadingBuilder:
                                                  (context, image, progress) {
                                                if (progress != null)
                                                  return Center(
                                                    child: SizedBox(
                                                      height: maxSize / 3,
                                                      width: maxSize / 3,
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: progress == null
                                                            ? 0
                                                            : (progress.cumulativeBytesLoaded ??
                                                                    0) /
                                                                (progress
                                                                        .expectedTotalBytes ??
                                                                    1.0),
                                                      ),
                                                    ),
                                                  );
                                                return image;
                                              },
                                            ))),
                            ),
                            builder?.call(context, index, progress)
                          ],
                        ),
                      ))));
        },
        itemCount: images.length,
        scrollDirection: scrollDirection,
        itemExtent: itemExtent,
        maxExtent: maxExtent,
      ),
    );
  }
}
