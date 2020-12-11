import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:comic_reader/manager/state_manager.dart';
import 'package:comic_reader/model/comic.dart';
import 'package:comic_reader/ui/chapter_screen.dart';
import 'package:comic_reader/ui/read_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
      name: 'comic_reader_app',
      options: Platform.isMacOS || Platform.isIOS
          ? FirebaseOptions(
              appId: '1:1025369795119:ios:c18bbe5d1c81dfccf634da',
              apiKey: 'AIzaSyAbyZdxyJ83vaf8ffVXBL7yqrtCNILBPWk',
              projectId: 'abur-cubur-bf216',
              messagingSenderId: '1025369795119',
              databaseURL: 'https://abur-cubur-bf216.firebaseio.com/')
          : FirebaseOptions(
              appId: '1:1025369795119:android:dce9da2f46e5594cf634da',
              apiKey: 'AIzaSyBr71d--CICixIYVCHsgAVgz8Jv_0ztgos',
              projectId: 'abur-cubur-bf216',
              messagingSenderId: '1025369795119',
              databaseURL: 'https://abur-cubur-bf216.firebaseio.com/'));

  runApp(ProviderScope(child: MyApp(app: app)));
}

class MyApp extends StatelessWidget {
  FirebaseApp app;

  MyApp({this.app});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      routes: {
        '/chapters' : (context) => ChapterScreen(),
        '/read' : (context) => ReadScreen()
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
        title: 'Comic Reader',
        app: app,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.app}) : super(key: key);

  final String title;
  final FirebaseApp app;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference _refBanner, _refComic;

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase _db = FirebaseDatabase(app: widget.app);
    _refBanner = _db.reference().child("Banners");
    _refComic = _db.reference().child("Comic");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF44A3E),
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: getBanners(_refBanner),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CarouselSlider(
                    items: snapshot.data
                        .map((e) => Builder(builder: (context) {
                              return Image.network(
                                e,
                                fit: BoxFit.cover,
                              );
                            }))
                        .toList(),
                    options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 1,
                        initialPage: 0,
                        height: MediaQuery.of(context).size.height / 3)),
                Row(
                  children: [
                    Expanded(
                        flex: 4,
                        child: Container(
                          color: Color(0xFFF44A3E),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'NEW COMIC',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(''),
                          ),
                        ))
                  ],
                ),
                FutureBuilder(
                    future: getComic(_refComic),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('${snapshot.error}'),
                        );
                      } else if (snapshot.hasData) {
                        List<Comic> comics = new List<Comic>();
                        snapshot.data.forEach((item) {
                          var comic =
                              Comic.fromJson(json.decode(json.encode(item)));
                          comics.add(comic);
                        });

                        return Expanded(
                            child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          padding: const EdgeInsets.all(4),
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 1.0,
                          children: comics.map((comic) {
                            return GestureDetector(
                              onTap: () {
                                context.read(comicSelected).state = comic;
                                Navigator.pushNamed(context, "/chapters");
                              },
                              child: Card(
                                  elevation: 12,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        comic.image,
                                        fit: BoxFit.cover,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            color: Color(0xAA434343),
                                            padding: const EdgeInsets.all(8),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                  '${comic.name}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  )),
                            );
                          }).toList(),
                        ));
                      }

                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    })
              ],
            );
          } else if (snapshot.hasError) {
            Center(
              child: Text('${snapshot.error}'),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<List<String>> getBanners(DatabaseReference ref) {
    return ref
        .once()
        .then((snapshot) => snapshot.value.cast<String>().toList());
  }

  Future<List<dynamic>> getComic(DatabaseReference ref) {
    return ref.once().then((snapshot) => snapshot.value);
  }
}
