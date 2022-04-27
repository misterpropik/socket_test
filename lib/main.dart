import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  HttpServer? _httpServer;
  WebSocket? _socket;
  int _counter = 0;
  final List<String> _deviceIp = ['192.168.0.104'];

  Future<void> _startServer() async {
    _httpServer = await HttpServer.bind(InternetAddress.anyIPv4, 7777);
    _httpServer!.listen((req) async {
      if (req.uri.path == '/ws') {
        final socket = await WebSocketTransformer.upgrade(req);
        socket.listen(
          (dynamic event) {
            print(int.parse(event.toString()));
            setState(() {
              _counter = int.parse(event.toString());
            });
          },
        );
      }
    });
    setState(() {});
  }

  Future<void> _startClient() async {
    if (_socket != null) return;
    for (final ip in _deviceIp) {
      _socket = await WebSocket.connect('ws://$ip:7777/ws');
    }
    setState(() {});
  }

  Future<void> _incrementCounter() async {
    _counter++;
    _socket?.add(_counter.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ElevatedButton(
              onPressed: _startServer,
              child: Row(
                children: [
                  Text(
                    _httpServer != null ? 'server started' : 'server is off',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(width: 50),
            ElevatedButton(
              onPressed: _startClient,
              child: Row(
                children: [
                  Text(
                    _socket != null ? 'client started' : 'client is off',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
