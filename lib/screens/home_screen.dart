import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 0;
  int totalPages = 0;
  int pageSize = 10;
  dynamic data;
  List<dynamic> items = [];

  TextEditingController queryTextEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();

  void getData() async {
    final response = await http.get(
      Uri.parse(
        'https://api.github.com/search/repositories?q=${queryTextEditingController.text}&per_page=$pageSize&page=$currentPage',
      ),
    );
    setState(() {
      data = jsonDecode(response.body);
      items.addAll(data!['items']);
      if (data['total_count'] % pageSize == 0) {
        totalPages = data['total_count'] ~/ pageSize;
      } else {
        totalPages = (data['total_count'] / pageSize).floor() + 1;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        setState(() {
          if (currentPage < totalPages - 1) {
            ++currentPage;
            getData();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'GitHub API',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      controller: queryTextEditingController,
                      cursorColor: Colors.white,
                      style: const TextStyle(fontSize: 14.0),
                      textAlignVertical: TextAlignVertical.center,
                      cursorHeight: 14.0,
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              getData();
                            }
                            items = [];
                            currentPage = 0;
                          },
                          child: const Icon(
                            Icons.search,
                            size: 24.0,
                          ),
                        ),
                        hintText: 'Enter the repository name',
                        labelStyle: const TextStyle(fontSize: 14.0),
                        hintStyle: const TextStyle(fontSize: 14.0),
                        contentPadding: const EdgeInsets.only(left: 16.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1.0,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            data == null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: const Center(
                        child: Text(
                          'No search results\nEnter the repository name above',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            data?['total_count'] == 0
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: const Center(
                        child: Text(
                          'No matches\nTry changing the repository name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      final url = Uri.parse(items[index]['html_url']);
                      if (await canLaunchUrl(url)) {
                        launchUrl(url);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Repository name: '
                              '${items[index]['name']}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 14.0,
                              ),
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              'Owner: '
                              '${items[index]['owner']['login']}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
