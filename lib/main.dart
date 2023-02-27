import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
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
      home: const MyHomePage(title: 'IS-Vanilla Way: Pull to refresh'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final scrolController = ScrollController();
  List items = [];
  int page = 1;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetch();
    scrolController.addListener(() {
      if (scrolController.position.maxScrollExtent == scrolController.offset) {
        fetch();
      }
    });
  }

  @override
  void dispose() {
    scrolController.dispose();
    super.dispose();
  }

  Future fetch() async {
    const limit = 20;
    final url =
        Uri.parse('https://rickandmortyapi.com/api/character/?page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map newItems = json.decode(response.body);
      final List jsonResults = newItems['results'];

      setState(() {
        page++;

        items = items + jsonResults;
        if (items.length < limit) {
          hasMore = false;
        }
      });
    }
  }

  Future refresh() async {
    setState(() {
      items.clear();
    });

    final url =
        Uri.parse('https://rickandmortyapi.com/api/character/?page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map newItems = json.decode(response.body);
      final List jsonResults = newItems['results'];

      setState(() {
        page = 1;
        items = items + jsonResults;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: refresh,
                child: ListView.builder(
                    controller: scrolController,
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length + 1,
                    itemBuilder: (context, index) {
                      if (index < items.length) {
                        final item = items[index]['name'];
                        final imageUrl = items[index]["image"];
                        return ListTile(
                          title: Text("No:" + index.toString() + " " + item),
                          leading: CircleAvatar(child: Image.network(imageUrl)),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: hasMore
                                ? const CircularProgressIndicator()
                                : const Text("No more data to load"),
                          ),
                        );
                      }
                    })));
  }
}
