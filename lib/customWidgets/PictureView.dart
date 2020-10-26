import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photograffitiflutter/beans/DrawPoint.dart';

class PictureView extends StatefulWidget {
  final String _path;
  _PictureViewState __pictureViewState;
  Function undateOptionBar;

  PictureView(this._path, this.undateOptionBar) {
    this.__pictureViewState = _PictureViewState();
  }

  @override
  State<StatefulWidget> createState() => __pictureViewState;

  void reset() {
    __pictureViewState.reset();
  }

  void changeMode() {
    __pictureViewState.changeMode();
  }

  void undo() {
    __pictureViewState.undo();
  }

  void setCurrentDrawMode(bool mode) {
    __pictureViewState.setCurrentDrawMode(mode);
  }

  bool getCurrentDrawMode() {
    return __pictureViewState.drawMode;
  }

  bool getHasDrawed() {
    return __pictureViewState.preOffsets.length != 0;
  }

  Color getPaintColor() {
    return __pictureViewState.paintColor;
  }

  void changePaintColor(Color color) {
    __pictureViewState.changePaintColor(color);
  }
}

class _PictureViewState extends State<PictureView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  double _scale = 1.0;
  double _tmpScale = 1.0;
  double _moveX = 0.0;
  double _tmpMoveX = 0.0;
  double _moveY = 0.0;
  double _tmpMoveY = 0.0;
  double _rotation = 0.0;
  double _tmpRotation = 0.0;

  Offset _tmpFocal = Offset.zero;

  AnimationController _animationController;
  Animation<double> _values;

  List<DrawPoint> _points = <DrawPoint>[];

  List<List<DrawPoint>> preOffsets = List();

  bool drawing = false;

  bool drawMode = false;

  Color paintColor = Colors.red;

  double strokeWidth = 5.0;

  Matrix4 matrix4;

  var gestureKey = GlobalKey();

  @override
  bool get wantKeepAlive => true;

  void changePaintColor(Color color) {
    setState(() {
      paintColor = color;
    });
  }

  void setCurrentDrawMode(bool mode) {
    setState(() {
      drawMode = mode;
    });
  }

  void changeMode() {
    setState(() {
      drawMode = !drawMode;
    });
  }

  void reset() {
    setState(() {
      _points.clear();
      preOffsets.clear();
    });

    widget.undateOptionBar(preOffsets.length != 0);
  }

  void undo() {
    setState(() {
      preOffsets[preOffsets.length - 1].forEach((element) {
        _points.remove(element);
      });
      preOffsets.removeAt(preOffsets.length - 1);
    });

    widget.undateOptionBar(preOffsets.length != 0);
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 120));
    // Tween 将动画的 0 - 1 的值映射到我们设置的范围内
    _values = Tween(begin: 1.0, end: 0.0).animate(_animationController);
    _animationController.addListener(() {
      setState(() {
        // 通过动画逐帧还原位置
        _moveX = _tmpMoveX * _values.value;
        _moveY = _tmpMoveY * _values.value;
        _scale = (_tmpScale - 1) * _values.value + 1;
        _rotation = _tmpRotation * _values.value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 配置 Matrix
    matrix4 = Matrix4.identity()
      ..scale(_scale, _scale)
      ..translate(_moveX, _moveY)
      ..rotateZ(_rotation);
    return Container(
      color: Color(0xfff3f3f3),
      child: Center(
        child: Transform(
            alignment: FractionalOffset.center,
            transform: matrix4,
            child: Container(
              child: Stack(
                children: [
                  Center(
                    child: Image.network(widget._path),
                  ),
                  drawMode
                      ? GestureDetector(
                          key: gestureKey,
                          onPanUpdate: (DragUpdateDetails details) {
                            if (drawing == false) {
                              List<DrawPoint> drawingOffsets = <DrawPoint>[];
                              preOffsets.add(drawingOffsets);
                            }
                            drawing = true;
                            RenderBox referenceBox =
                                gestureKey.currentContext.findRenderObject();
                            Offset localPosition = referenceBox
                                .globalToLocal(details.globalPosition);
                            DrawPoint dp = DrawPoint(
                                localPosition, strokeWidth, paintColor);
                            preOffsets[preOffsets.length - 1].add(dp);
                            setState(() {
                              _points = new List.from(_points)..add(dp);
                            });
                          },
                          onPanEnd: (DragEndDetails details) {
                            drawing = false;
                            _points.add(null);
                            widget.undateOptionBar(preOffsets.length != 0);
                          })
                      : GestureDetector(
                          onDoubleTap: () {
                            if (!_animationController.isAnimating) {
                              _tmpMoveX = _moveX;
                              _tmpMoveY = _moveY;
                              _tmpScale = _scale;
                              _tmpRotation = _rotation;
                              _animationController.reset();
                              _animationController.forward();
                            }
                          },
                          onScaleStart: (details) {
                            if (!_animationController.isAnimating) {
                              _tmpFocal = details.focalPoint;
                              _tmpMoveX = _moveX;
                              _tmpMoveY = _moveY;
                              _tmpScale = _scale;
                              _tmpRotation = _rotation;
                            }
                          },
                          onScaleUpdate: (details) {
                            if (!_animationController.isAnimating) {
                              setState(() {
                                _moveX = _tmpMoveX +
                                    (details.focalPoint.dx - _tmpFocal.dx) /
                                        _tmpScale;
                                _moveY = _tmpMoveY +
                                    (details.focalPoint.dy - _tmpFocal.dy) /
                                        _tmpScale;
                                _scale = _tmpScale * details.scale;
                                _rotation = _tmpRotation + details.rotation;
                                print(_rotation);
                              });
                            }
                          },
                        ),
                  CustomPaint(painter: DrawBoard(_points, matrix4))
                ],
              ),
            )),
      ),
    );
  }
}

class DrawBoard extends CustomPainter {
  Matrix4 matrix4;

  DrawBoard(this.points, this.matrix4);

  final List<DrawPoint> points;
  Paint paintf;

  void paint(Canvas canvas, Size size) {
    debugPrint("paint:");
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null &&
          points[i + 1] != null &&
          points[i].offset != null &&
          points[i + 1].offset != null) {
        paintf = new Paint()
          ..color = points[i].color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = points[i].paintWidth;
        canvas.drawLine(points[i].offset, points[i + 1].offset, paintf);
      }
    }
  }

  bool shouldRepaint(DrawBoard other) {
    debugPrint("repaint:" + (other.points != points).toString());
//    return other.points != points;
    return true;
  }
}
