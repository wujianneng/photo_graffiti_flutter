library animated_floatactionbutton;

import 'dart:async';
import 'package:animated_float_action_button/transform_float_button.dart';
import 'package:flutter/material.dart';


class MyAnimatedFloatingActionButton extends StatefulWidget {
  final List<Widget> fabButtons;
  final Color colorStartAnimation;
  final Color colorEndAnimation;
  final AnimatedIconData animatedIconData;

  MyAnimatedFloatingActionButtonState state;

  MyAnimatedFloatingActionButton(
        this.fabButtons,
        this.colorStartAnimation,
        this.colorEndAnimation,
        this.animatedIconData){
    state = MyAnimatedFloatingActionButtonState();
  }

  @override
  MyAnimatedFloatingActionButtonState createState() => state;


  void refreshUi(Color color){
    state.refresh(color);
  }

  void animate(){
    state.animate();
  }
}


class MyAnimatedFloatingActionButtonState
    extends State<MyAnimatedFloatingActionButton>
    with SingleTickerProviderStateMixin , AutomaticKeepAliveClientMixin{
  bool isOpened = false;
  bool isOpenedVisible = false;
  AnimationController _animationController;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  Color buttonColor = Colors.red;

  void refresh(Color color){
    setState(() {
      buttonColor = color;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  initState() {
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 300))
      ..addListener(() {
        setState(() {});
      });
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  delayOpen() {
    Future.delayed(const Duration(milliseconds: 300), () {
      isOpenedVisible = !isOpenedVisible;
    });
  }

  animate() {
    if (!isOpened) {
      isOpenedVisible = !isOpenedVisible;
      _animationController.forward();
    } else {
      _animationController.reverse();
      delayOpen();
    }
    isOpened = !isOpened;
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        elevation: 0,
        backgroundColor: buttonColor,
        onPressed: animate,
        tooltip: 'Toggle',
        child: Text(""),
      ),
    );
  }

  List<Widget> _setFabButtons() {
    List<Widget> processButtons = List<Widget>();
    for (int i = 0; i < widget.fabButtons.length; i++) {
      processButtons.add(TransformFloatButton(
        floatButton: Visibility(
          child: widget.fabButtons[i],
          visible: isOpenedVisible,
        ),
        translateValue: _translateButton.value * (widget.fabButtons.length - i),
      ));
    }
    processButtons.add(toggle());
    return processButtons;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: _setFabButtons(),
    );
  }
}
