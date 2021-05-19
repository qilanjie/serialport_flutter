import 'dart:async';

import 'package:flutter/material.dart';

import 'common.dart';

class ClockBaseStatefulWidget extends StatefulWidget {
  ClockBaseStatefulWidget({required Key key}) : super(key: key);

  @override
  ClockBaseState createState() {
    var state = new ClockBaseState();
    state.startClock();
    return state;
  }
}

class ClockBaseState<T extends StatefulWidget> extends State {
  ClockBaseState() : super();

  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return new Text('ClockBaseState is not implemented!');
  }

  startClock() {
    Timer.periodic(CLOCK_INTERVAL, (Timer t) {
      if (!mounted) {
        return;
      }

      setState(() {
        now = DateTime.now();
      });
    });
  }

  Size getDeviceSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
}
