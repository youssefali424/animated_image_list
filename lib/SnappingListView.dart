import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import "package:flutter/widgets.dart";
import "dart:math";
import 'CustomScrollPhysics.dart';
import 'interpolate.dart';

typedef Builder = Widget Function(
    BuildContext context, int index, double progress, double maxHeight);

class SnappingListView extends StatefulWidget {
  final Axis scrollDirection;
  final ScrollController controller;
  final Builder itemBuilder;
  final int itemCount;
  final double itemExtent;
  final double maxExtent;
  final ValueChanged<int> onItemChanged;

  final EdgeInsets padding;
  SnappingListView.builder(
      {this.scrollDirection,
      this.controller,
      @required this.itemBuilder,
      this.itemCount,
      @required this.itemExtent,
      this.onItemChanged,
      this.padding = const EdgeInsets.only(top: 0),
      @required this.maxExtent})
      : assert(itemExtent != null && itemExtent > 0),
        assert(maxExtent != null && maxExtent > 0),
        assert(maxExtent > itemExtent);

  @override
  createState() => _SnappingListViewState();
}

class _SnappingListViewState extends State<SnappingListView>
    with WidgetsBindingObserver {
  int _lastItem = 0;
  double position = 0.0;
  double defaultPadding = 0;
  StreamController<double> currentPositionStream;
  DummyChangePhysics dummy = DummyChangePhysics.H;
  Orientation currentOrientation;
  Size currSize;
  ScrollController controller;
  bool rotated;
  @override
  void initState() {
    super.initState();
    currentPositionStream = StreamController.broadcast()..add(position);
    WidgetsBinding.instance.addObserver(this);
    currSize = window.physicalSize;
    controller = ScrollController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    currentPositionStream.close();
    super.dispose();
  }

  didChangeMetrics() {
    if (currSize.width != window.physicalSize.width ||
        currSize.height != window.physicalSize.height) {
      setState(() {
        dummy = (dummy == DummyChangePhysics.H
            ? DummyChangePhysics.L
            : DummyChangePhysics.H);
        rotated = true;
      });
      final startPadding = widget.scrollDirection == Axis.horizontal
          ? widget.padding.left
          : widget.padding.top;
      controller.jumpTo(startPadding + defaultPadding);
    }
  }

  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxExtent != widget.maxExtent) {
      if (!rotated) {
        dummy = (dummy == DummyChangePhysics.H
            ? DummyChangePhysics.L
            : DummyChangePhysics.H);
      } else
        rotated = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final startPadding = widget.scrollDirection == Axis.horizontal
        ? widget.padding.left
        : widget.padding.top;
    return OrientationBuilder(builder: (_, orientation) {
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        var maxSize = min(
            widget.scrollDirection == Axis.vertical
                ? constraints.maxHeight
                : constraints.maxWidth,
            widget.maxExtent);
        var remain = 0.0;
        if ((widget.scrollDirection == Axis.vertical &&
                !constraints.hasInfiniteHeight) ||
            (widget.scrollDirection == Axis.horizontal &&
                !constraints.hasInfiniteWidth)) {
          remain = (widget.scrollDirection == Axis.vertical
                  ? constraints.maxHeight
                  : constraints.maxWidth) -
              maxSize;
        }
        return NotificationListener<ScrollNotification>(
            child: _buildList(startPadding, maxSize, remain, orientation),
            onNotification: (notif) {
              if (notif.depth == 0 && notif is ScrollUpdateNotification) {
                final currPosition =
                    (notif.metrics.pixels - startPadding - defaultPadding) /
                        maxSize;
                final currItem = currPosition.truncate();
                if (currItem != _lastItem) {
                  setState(() {
                    _lastItem = currItem;
                  });
                  widget.onItemChanged?.call(currItem);
                }
                position = currPosition;
                currentPositionStream.add(currPosition);
              }
              return false;
            });
      });
    });
  }

  _buildList(double startPadding, double maxSize, double remain,
      Orientation orientation) {
    return ListView.builder(
        scrollDirection: widget.scrollDirection,
        controller: controller,
        itemBuilder: (context, index) {
          if (index > widget.itemCount - 1) {
            if (remain < 0) {
              return Container();
            }
            return Container(
              height: remain,
            );
          }

          var currItem = _lastItem;
          if (currItem >= index - 1.0 && currItem <= index + 1.0) {
            return StreamBuilder(
                stream: currentPositionStream.stream,
                builder: (context, snapshot) {
                  var currPos = snapshot.hasData ? snapshot.data : position;
                  var interpolation = interpolate(
                      currPos,
                      InterpolateConfig([
                        (index - 1.0),
                        (index + 0.0),
                        index + 1.0
                      ], [
                        0,
                        1,
                        2,
                      ], extrapolate: Extrapolate.CLAMP));
                  return SizedBox(
                      height: widget.scrollDirection == Axis.vertical
                          ? lerpDouble(widget.itemExtent, maxSize,
                              interpolation > 1 ? 1 : interpolation)
                          : null,
                      width: widget.scrollDirection == Axis.horizontal
                          ? lerpDouble(widget.itemExtent, maxSize,
                              interpolation > 1 ? 1 : interpolation)
                          : null,
                      child: widget.itemBuilder(
                          context, index, interpolation, maxSize));
                });
          }
          return SizedBox(
              height: widget.scrollDirection == Axis.vertical
                  ? lerpDouble(widget.itemExtent, maxSize,
                      currItem > index + 1.0 ? 1 : 0)
                  : null,
              width: widget.scrollDirection == Axis.horizontal
                  ? lerpDouble(widget.itemExtent, maxSize,
                      currItem > index + 1.0 ? 1 : 0)
                  : null,
              child: widget.itemBuilder(
                  context, index, currItem > (index + 1.0) ? 2 : 0, maxSize));
        },
        itemCount: widget.itemCount + 1,
        physics: dummy == DummyChangePhysics.H
            ? DummyHScrollPhysics(
                mainAxisStartPadding: startPadding + defaultPadding,
                itemExtent: maxSize)
            : DummyVScrollPhysics(
                mainAxisStartPadding: startPadding + defaultPadding,
                itemExtent: maxSize),
        padding: widget.padding);
  }
}
