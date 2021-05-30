import 'package:flutter/material.dart';
import 'PhotoViewerArbnb_screen.dart';

class PhotoViewerArbnbPage extends StatefulWidget {
  static const String routeName = '/PhotoViewerArbnb';
  final String url;
  final ProviderBuilder? provider;
  final ProviderBuilder? placeHolder;
  final int index;
  PhotoViewerArbnbPage(this.url, this.index, {this.provider, this.placeHolder});
  @override
  _PhotoViewerArbnbState createState() => _PhotoViewerArbnbState();
}

class _PhotoViewerArbnbState extends State<PhotoViewerArbnbPage> {
  _PhotoViewerArbnbState();
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
        body: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0)),
          child: PhotoViewerArbnbScreen(
            widget.url,
            widget.index,
            placeHolder: widget.placeHolder,
            provider: widget.provider,
          ),
        ));
  }
}
