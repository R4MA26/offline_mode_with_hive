// import 'dart:convert';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Box? box;
  final List data = [];

  Future openBox() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    box = await Hive.openBox('data');
    return;
  }

  Future<bool> getAllData() async {
    await openBox();
    data.clear();

    const String url = 'https://reqres.in/api/users?page=2';

    try {
      final http.Response res = await http.get(Uri.parse(url));
      final jsonDcode = jsonDecode(res.body)['data'];

      print(jsonDcode);

      await putData(jsonDcode);
    } on SocketException {
      print('No Internet');
    }

    // get data from db
    var myMap = box!.toMap().values.toList();

    if (myMap.isEmpty) {
      data.add('empty');
    } else {
      data.addAll(myMap);
    }

    return Future.value(true);
  }

  Future putData(data) async {
    await box!.clear();
    print(box?.length);

    // insert data
    for (var d in data) {
      box?.add(d);
      print(box?.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Storage with Hive'),
      ),
      body: Center(
        child: FutureBuilder(
          future: getAllData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (data.contains('empty')) {
                return const Text('No data');
              } else {
                return Column(
                  children: [
                    const Image(
                      image: NetworkImage(
                          'https://images.unsplash.com/photo-1661961110144-12ac85918e40?ixlib=rb-1.2.1&ixid=MnwxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwxfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=800&q=60'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(data[index]['first_name'].toString()),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
