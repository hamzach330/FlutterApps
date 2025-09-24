library hydrogen_flutter_examples;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:ffi/ffi.dart';
import 'package:hydrogen_flutter/hydrogen_flutter.dart' as hydrogen;

part 'examples/hash_multi_key.dart';
part 'examples/random_buf.dart';
part 'examples/random_num.dart';
part 'examples/random_num_stream.dart';
part 'examples/sign_key.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          color: Colors.blueGrey.shade900,
        )
      ),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(200),
          child: AppBar(
            title: const Text("Examples"),
            flexibleSpace: Image.asset("assets/images/libhydrogen.png"),
          ),
        ),
        body: ListView(
          padding:  const EdgeInsets.all(10),
          children: const [
            SignKey(),
            Br(),
            HashMulti(size: 100),
            Br(),
            RandomBuf(size: 100),
            Br(),
            RandomNum(),
            Br(),
            RandomNumStream(),
          ],
        ),
      ),
    );
  }
}

class Br extends StatelessWidget {
  final double height;
  const Br({super.key, this.height = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}