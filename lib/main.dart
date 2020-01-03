import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'music_player_screen.dart';

void main() => runApp(App());

GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFfe0000),
        accentColor: Color(0xFFfe0000),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Song> listSong = List();

  @override
  void initState() {
    initListSong();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    return Scaffold(
      key: scaffoldState,
      body: Stack(
        children: <Widget>[
          _buildWidgetAlbumCover(mediaQuery),
          _buildWidgetActionAppBar(mediaQuery),
          _buildWidgetArtistName(mediaQuery),
          _buildWidgetListSong(mediaQuery),
        ],
      ),
    );
  }

  Widget _buildWidgetArtistName(MediaQueryData mediaQuery) {
    return SizedBox(
      height: mediaQuery.size.height / 1.8,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              children: <Widget>[
                Positioned(
                  child: Text(
                    "Almutairi",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "CoralPen",
                      fontSize: 72.0,
                    ),
                  ),
                  top: constraints.maxHeight - 100.0,
                ),
                Positioned(
                  child: Text(
                    "Turki",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "CoralPen",
                      fontSize: 72.0,
                    ),
                  ),
                  top: constraints.maxHeight - 140.0,
                ),
                Positioned(
                  child: Text(
                    "Designed By",
                    style: TextStyle(
                      color: Color(0xFFfe0000),
                      fontSize: 14.0,
                      fontFamily: "Campton_Light",
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  top: constraints.maxHeight - 160.0,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWidgetListSong(MediaQueryData mediaQuery) {
    TextEditingController textcontroller = TextEditingController();
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            top: mediaQuery.size.height / 1.8 + 100.0,
            right: 20.0,
            bottom: 25,
          ),
          child: TextField(
            controller: textcontroller,
              style: TextStyle(
                color: Color(0xFF282828),
                fontWeight: FontWeight.w600,
                fontFamily: "Campton_Light",
              ),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  prefixIcon: Icon(Icons.play_arrow),
                  hintText: "Enter Your URL Music",
                  border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF282828), width: 0.5),
                      borderRadius: BorderRadius.circular(48.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF282828), width: 0.5),
                      borderRadius: BorderRadius.circular(48.0)))),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 60.0,
            //top: mediaQuery.size.height / 1.8 - 490,
            right: 60.0,
            bottom: mediaQuery.padding.bottom + 16.0,
          ),
          child: InkWell(
            onTap: () {
              var id;
              var text = textcontroller.text;
              if (text.contains('youtu.be')) {
                var x = text.split('youtu.be/');
                id = x[1];
              } else if (text.contains('watch?v=')) {
                var x = text.split('watch?v=');
                id = x[1];
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LoadingScreen(
                          id: id,
                        )),
              );
            },
            child: Container(
              height: 45.0,
              color: Colors.transparent,
              child: new Container(
                  decoration: new BoxDecoration(
                      color: Color(0xff282828),
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(48.0),
                        topRight: const Radius.circular(48.0),
                        bottomLeft: const Radius.circular(48.0),
                        bottomRight: const Radius.circular(48.0),
                      )),
                  child: new Center(
                    child: new Text(
                      "Play",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Campton_Light",
                      ),
                    ),
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetActionAppBar(MediaQueryData mediaQuery) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        top: mediaQuery.padding.top + 16.0,
        right: 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[],
      ),
    );
  }

  Widget _buildWidgetAlbumCover(MediaQueryData mediaQuery) {
    return Container(
      width: double.infinity,
      height: mediaQuery.size.height / 1.8,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48.0),
          bottomRight: Radius.circular(48.0),
        ),
        image: DecorationImage(
          image: AssetImage("assets/b.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void initListSong() {
    listSong.add(Song(title: "No tears left to cry", duration: "5:20"));
    listSong.add(Song(title: "Imagine", duration: "3:20"));
    listSong.add(Song(title: "Into you", duration: "4:12"));
    listSong.add(Song(title: "One last time", duration: "4:40"));
    listSong.add(Song(title: "7 rings", duration: "2:58"));
    listSong.add(Song(title: "Thank u, next", duration: "3:27"));
    listSong.add(Song(
        title: "Break up with your girlfriend, i'm bored", duration: "3:10"));
  }
}

class Song {
  String title;
  String duration;

  Song({this.title, this.duration});

  @override
  String toString() {
    return 'Song{title: $title, duration: $duration}';
  }
}
