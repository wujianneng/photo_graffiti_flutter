import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'MyAnimatedFloatingActionButton.dart';
import 'PictureView.dart';

class DrawImageView extends StatefulWidget {
  List<String> imageListUrls;

  DrawImageView(this.imageListUrls);

  @override
  _DrawImageViewState createState() => _DrawImageViewState();
}

class _DrawImageViewState extends State<DrawImageView>
    with AutomaticKeepAliveClientMixin {
  bool drawMode = false;
  Color paintColor = Colors.red;
  int currentPictureIndex = 0;

  List<PictureView> imageList = List();

  MyAnimatedFloatingActionButton actionButton;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    widget.imageListUrls.forEach((url) {
      imageList.add(PictureView(url, () {
        setState(() {});
      }));
    });

    actionButton = MyAnimatedFloatingActionButton(<Widget>[
      FloatingActionButton(
        elevation: 1000,
        backgroundColor: Colors.red,
        onPressed: () {
          actionButton.animate();
          imageList[currentPictureIndex].changePaintColor(Colors.red);
          actionButton.refreshUi(Colors.red);
          paintColor = Colors.red;
        },
      ),
      FloatingActionButton(
        elevation: 1000,
        backgroundColor: Colors.yellow,
        onPressed: () {
          actionButton.animate();
          imageList[currentPictureIndex].changePaintColor(Colors.yellow);
          actionButton.refreshUi(Colors.yellow);
          paintColor = Colors.yellow;
        },
      ),
      FloatingActionButton(
        elevation: 1000,
        backgroundColor: Colors.blue,
        onPressed: () {
          actionButton.animate();
          imageList[currentPictureIndex].changePaintColor(Colors.blue);
          actionButton.refreshUi(Colors.blue);
          paintColor = Colors.blue;
        },
      ),
    ],
        imageList[currentPictureIndex].getPaintColor(),
        imageList[currentPictureIndex].getPaintColor(),
        AnimatedIcons.menu_close //To principal button
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: IndexedStack(
              index: currentPictureIndex,
              children: imageList,
            ),
          ),
          Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
            child: Stack(
              children: <Widget>[
                Visibility(
                  visible: imageList[currentPictureIndex].getHasDrawed(),
                  child: Positioned(
                    left: 30,
                    top: 20,
                    child: SizedBox(
                      width: 55,
                      height: 55,
                      child: CircleAvatar(
                        child: IconButton(
                          iconSize: 35,
                          onPressed: () {
                            imageList[currentPictureIndex].reset();
                          },
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: imageList[currentPictureIndex].getHasDrawed(),
                  child: Positioned(
                    left: 130,
                    top: 20,
                    child: SizedBox(
                      width: 55,
                      height: 55,
                      child: CircleAvatar(
                        child: IconButton(
                          iconSize: 35,
                          onPressed: () {
                            imageList[currentPictureIndex].undo();
                          },
                          icon: Icon(
                            Icons.undo,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 55,
                    height: 55,
                    child: CircleAvatar(
                      child: IconButton(
                        iconSize: 35,
                        onPressed: () {
                          setState(() {
                            drawMode = !drawMode;
                            imageList[currentPictureIndex].changeMode();
                          });
                        },
                        icon: Icon(
                          drawMode ? Icons.settings_overscan : Icons.brush,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: currentPictureIndex > 0,
                  child: Positioned(
                    right: 130,
                    top: 20,
                    child: SizedBox(
                      width: 55,
                      height: 55,
                      child: CircleAvatar(
                        child: IconButton(
                          iconSize: 35,
                          onPressed: () {
                            setState(() {
                              currentPictureIndex--;
                            });
                            imageList[currentPictureIndex]
                                .setCurrentDrawMode(drawMode);
                            imageList[currentPictureIndex]
                                .changePaintColor(paintColor);
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_left,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: imageList.length > 1 &&
                      currentPictureIndex != imageList.length - 1,
                  child: Positioned(
                    right: 30,
                    top: 20,
                    child: SizedBox(
                      width: 55,
                      height: 55,
                      child: CircleAvatar(
                        child: IconButton(
                          iconSize: 35,
                          onPressed: () {
                            setState(() {
                              currentPictureIndex++;
                            });
                            imageList[currentPictureIndex]
                                .setCurrentDrawMode(drawMode);
                            imageList[currentPictureIndex]
                                .changePaintColor(paintColor);
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
      floatingActionButton: Offstage(
        offstage: !drawMode,
        child: actionButton,
      ),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
          FloatingActionButtonLocation.endFloat,
          MediaQuery.of(context).size.width * -1 / 2 + 130,
          -6),
      floatingActionButtonAnimator: scalingAnimation(),
    );
  }
}

class scalingAnimation extends FloatingActionButtonAnimator {
  double _x;
  double _y;

  @override
  Offset getOffset({Offset begin, Offset end, double progress}) {
    _x = begin.dx + (end.dx - begin.dx) * progress;
    _y = begin.dy + (end.dy - begin.dy) * progress;
    return Offset(_x, _y);
  }

  @override
  Animation<double> getRotationAnimation({Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }

  @override
  Animation<double> getScaleAnimation({Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }
}

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  FloatingActionButtonLocation location;
  double offsetX; // X方向的偏移量
  double offsetY; // Y方向的偏移量
  CustomFloatingActionButtonLocation(this.location, this.offsetX, this.offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    Offset offset = location.getOffset(scaffoldGeometry);
    return Offset(offset.dx + offsetX, offset.dy + offsetY);
  }
}
