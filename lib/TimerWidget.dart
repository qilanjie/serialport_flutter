import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:serialport_flutter/theme_base.dart';

import 'common.dart';

class TimerWidget extends StatefulWidget {

  late String name;
  late String title;

  @override
  State<StatefulWidget> createState() {
    var state = new _TimerWidgetState();
    state.startClock();
    return state;
  }
}

class _TimerWidgetState extends ClockBaseState<TimerWidget> {

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: [

        TextSpan(
            text:
            "${now.year}-${now.month}-${now.day} ${pad0(now.hour)}:${pad0(now.minute)}:${pad0(now.second)}  ",
            style: TextStyle(
              fontSize: 20.0,
height: 2

            ))
      ],),
    );
  }
}

