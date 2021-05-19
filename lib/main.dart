import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:libserialport/libserialport.dart';
import 'package:synchronized/synchronized.dart';

import 'TimerWidget.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
double kpa = 0;
var recList = [];
var array = [];

void main() => runApp(ExampleApp());

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

extension IntToString on int {
  String toHex() => '0x${toRadixString(16)}';

  String toPadded([int width = 3]) => toString().padLeft(width, '0');

  String toTransport() {
    switch (this) {
      case SerialPortTransport.usb:
        return 'USB';
      case SerialPortTransport.bluetooth:
        return 'Bluetooth';
      case SerialPortTransport.native:
        return 'Native';
      default:
        return 'Unknown';
    }
  }
}

class _ExampleAppState extends State<ExampleApp> {
  final name = SerialPort.availablePorts.first;

  late final port;

  static double t = 0;

  ///声明变量
  late Timer _timer;

  ///记录当前的时间
  int curentTimer = 0;
  Uint8List s = Uint8List(7);
  final xishu = 1.0 / 65536 * 2500 / 128 * 9.843;

  var _lock = Lock();

  @override
  void initState() {
    super.initState();

    fullScreen();
    initPorts();

    ///循环执行
    ///间隔1秒
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      ///自增
      curentTimer += 1000;

      ///到5秒后停止
      // if (curentTimer >= 5000) {
      //   _timer.cancel();
      // }
//      setState(() {});
      _lock.synchronized(() async {
        s[0] = 0x5A;
        s[1] = 0xA5;
        s[2] = 4;
        s[3] = 0x10;
        s[4] = 0x00;
        s[5] = 0x00;
        s[6] = s[3] ^ s[4] ^ s[5];
        port.write(s);
      });
    });
  }

  void initPorts() {
    print(name);
    port = SerialPort(name);

    if (!port.openReadWrite()) {
      print(SerialPort.lastError);
      exit(-1);
    }

//    port.write(Uint8List(1));

    final reader = SerialPortReader(port);
    reader.stream.listen((data) {

      for (int i = 0; i < data.length; i++) {
        recList.add(data[i]);
      }
      if (recList.length >= 7) {
        if(recList[0]==0x5A&&recList[1]==0xA5){
  //               print('received: $recList');
          array = recList.sublist(0, 7);
  //               print('received: $array');
          recList.removeRange(0,7);
  //               print('received: $recList');
          t = (array[4] << 8) + array[5] + 0.0;
          setState(() {
            kpa = t * xishu; //9.845=200/(20*5.08V/5V
          });
        }else{
          recList.removeAt(0);
        }

      }

      //     print('${data[4] << 8}received:--- ${kpa.toStringAsFixed(3)}');
      //   port.write(data);
    });
  }

  void send() {
    // print(port.isOpen);
    if (port.isOpen) {
      _lock.synchronized(() async {
        s[0] = 0x5A;
        s[1] = 0xA5;
        s[2] = 4;
        s[3] = 0x10;
        s[4] = 0x00;
        s[5] = 0x00;
        s[6] = s[3] ^ s[4] ^ s[5];
        port.write(s);
      });
    }
  }

  void fullScreen() {
    // 隐藏底部按钮栏
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

// 隐藏状态栏
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

// 隐藏状态栏和底部按钮栏
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    ///取消计时器
    _timer.cancel();
    super.dispose();
    port.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      home: HomePage(),
      routes: {'/settings': (BuildContext context) => Settings()},
    );
  }
}

class CardListTile extends StatelessWidget {
  final String name;
  final String? value;

  CardListTile(this.name, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(value ?? 'N/A'),
        subtitle: Text(name),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("山东中惠仪器有限公司"),
        actions: <Widget>[TimerWidget()],
      ),
      body: Center(
          child: Column(
        children: [
          Divider(
            height: 10,
          ),
          SizedBox(
            width: 128,
            height: 64,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                )),
              ),
              onPressed: () {
                rootScaffoldMessengerKey.currentState!.showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.orange,
                    content: const Text(
                      '你点击了发送!',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, backgroundColor: Colors.orange),
                    ),
                  ),
                );
              },
              child: Text(
                "发送",
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          Text(
            "压强:${kpa.toStringAsFixed(3)}kPa",
            style: TextStyle(fontSize: 48),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.settings),
        onPressed: () {
          Navigator.pushNamed(context, '/settings');
        },
      ),
    );
  }
}

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
        leading: IconButton(
          iconSize: 36,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: Center(
        child: Text(
          "压强:${kpa.toStringAsFixed(3)}kPa",
          style: TextStyle(fontSize: 48),
        ),
      ),
    );
  }
}
