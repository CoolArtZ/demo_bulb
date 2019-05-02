/*
 * Sources:
 * https://codelabs.developers.google.com/codelabs/flutter-firebase/#0
 *
 *
 *
 */

import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'smart_bulb',
    options: Platform.isIOS
        ? const FirebaseOptions(
            googleAppID: '1:437151721822:ios:75f7715e84472752',
            gcmSenderID: '437151721822',
            databaseURL: 'https://nodemcu-iot-7405c.firebaseio.com',
          )
        : const FirebaseOptions(
            googleAppID: '1:437151721822:android:a0869dd60977418d',
            apiKey: 'AIzaSyDnePVJLl5vwwmAEukZP-LxT4BpAXS9Kfk',
            databaseURL: 'https://nodemcu-iot-7405c.firebaseio.com',
          ),
  );

  runApp(MaterialApp(
    title: 'IoT Button Demo',
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    home: MyHomePage(title: 'Demo Button', app: app),
  ));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.app}) : super(key: key);

  final String title;
  final FirebaseApp app;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _state = 0;
  String _text = 'N/A';
  DatabaseReference _stateRef;
  StreamSubscription<Event> _stateSubscription;
  DatabaseError _error;

  final _backColor = <Color>[
    Colors.lightBlue[50],
    Colors.grey[700],
  ];

  Widget initScreen() {
    return Center(
      child: Text(
        "Init Screen",
      ),
    );
  }



  @override
  void initState() {
    super.initState();

    _stateRef = FirebaseDatabase.instance.reference().child('/LedStatus');
    _stateRef.keepSynced(true);
    _stateSubscription = _stateRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        _state = event.snapshot.value ?? 0;
        if (_state == 1)
          _text = 'LED is OFF';
        else
          _text = 'LED is ON';
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;

      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _stateSubscription.cancel();
  }

  Future<void> _toggleState() async {
    //final TransactionResult transactionResult =
        await _stateRef.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? 0) ^ 1;
      return mutableData;
    });
  }

  /*
  void _toggleState() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _state ^= 1;
      FirebaseDatabase().reference().child('/').update({'LedStatus': _state});
      if (_state == 1)
        _text = 'LED OFF';
      else
        _text = 'LED ON';
    });
  }*/

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(child: Text(widget.title)),
      ),
      backgroundColor: _backColor[_state],
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_text',
              style: Theme.of(context).textTheme.display1,
            ),
            RaisedButton(
              onPressed: _toggleState,
              child: Text(
                'Press me',
                style: Theme.of(context).textTheme.display3,
              ),
            )
          ],
        ),
      ),
    );
  }
}
