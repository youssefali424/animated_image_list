# Animated Image List for Flutter

[![Pub](https://img.shields.io/pub/v/animated_image_list.svg)](https://pub.dev/packages/animated_image_list)

Flutter Animated image list with parallax effect and image lightbox .

<!-- [![Animated Image list](https://yt-embed.herokuapp.com/embed?v=EJ7FQjdHYkA)](https://www.youtube.com/watch?v=EJ7FQjdHYkA "Animated Image lis") -->
<img src="https://cdn.kapwing.com/final_60080a3b947bb40029539d46_634761.gif">

[<img src="https://img.youtube.com/vi/MGTt9eqJioc/0.jpg" width="49%">](https://youtu.be/MGTt9eqJioc) [<img src="https://img.youtube.com/vi/gTqUJB75Scc/0.jpg" width="49%">](https://youtu.be/gTqUJB75Scc)

[<img src="https://img.youtube.com/vi/iLn3OgV07KY/0.jpg" width="49%">](https://youtu.be/iLn3OgV07KY) [<img src="https://img.youtube.com/vi/FLpzHNzCSQ8/0.jpg" width="49%">](https://youtu.be/FLpzHNzCSQ8)

## Getting Started

Add the package to your pubspec.yaml:

```yaml
animated_image_list: ^0.5.0
```

In your dart file, import the library:

```Dart
import 'package:animated_image_list/AnimatedImageList.dart';
```

Instead of using a `ListView` create a `AnimatedImageList` Widget:

```Dart
 AnimatedImageList(
               images: arr.map((e) => e.urls.small).toList(),
               builder: (context, index, progress) {
                 return Positioned.directional(
                     textDirection: TextDirection.ltr,
                     bottom: 15,
                     start: 25,
                     child: Opacity(
                       opacity: progress > 1 ? (2 - progress) : progress,
                       child: Text(
                         arr[index].user.username ?? 'Anonymous',
                         style: TextStyle(
                             color: Colors.white,
                             fontSize: 25,
                             fontWeight: FontWeight.w500),
                       ),
                     ));
               },
               scrollDirection: Axis.vertical,
               itemExtent: 100,
               maxExtent: 400,
             ),
```

### Parameters:

| Name              | Description                                                                                                                                                                                                                                          | Required | Default value     |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ----------------- |
| `images`          | A list of images url to display in the list by default it accepts urls if custom image needed use provider paramter                                                                                                                                  | required | -                 |
| `provider`        | Function which maps an url or image string to an image provider                                                                                                                                                                                      | -        | -                 |
| `itemExtent`      | not selected item size required to calculate animations                                                                                                                                                                                              | required | 150               |
| `maxExtent`       | selected item size required to calculate animations                                                                                                                                                                                                  | required | 400               |
| `scrollDirection` | List scroll direction horizontal or vertical                                                                                                                                                                                                         | -        | Axis.vertical     |
| `builder`         | Builder function that returns a widget to display over the image / `progress` from 0...1 item selection progress from 1...2 item leaving view could be usefull if you want to animate something like text opacity above / `index` current item index | -        | -                 |
| `placeHolder`     | Optional function which returns default placeholder for lightbox and error widget if image fails to load                                                                                                                                             | -        | kTransparentImage |
