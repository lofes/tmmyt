import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'package:audioplayer/audioplayer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

enum PlayerState { stopped, playing, paused }

class LoadingScreen extends StatefulWidget {
  final String id;
  LoadingScreen({Key key, @required this.id}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  var vidurl = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: FutureBuilder<dynamic>(
            future: fetchPostData(
                'https://www.youtube.com/watch?v=' + widget.id), // async work
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text('Loading....');
                default:
                  if (snapshot.hasError )
                    return new Text('Error: ${snapshot.error}');
                  else
                  for (var i = 0; i < snapshot.data['result']['formats'].length; i++) {
                    if(snapshot.data['result']['formats'][i]['acodec'] != 'none' && snapshot.data['result']['formats'][i]['ext'] == 'mp4'){
                      vidurl = snapshot.data['result']['formats'][i]['url'];
                    }
                  }
                  
                  return MusicPlayerScreen(snapshot.data['result']['title'],snapshot.data['result']['thumbnail'],snapshot.data['result']['uploader'],vidurl);
                    
              }
            },
          ),
        ),
      ),
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  final String title;
  final String pic;
  final String uploader;
  final String url;

  MusicPlayerScreen(this.title,this.pic,this.uploader, this.url);

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
    
    play();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(widget.url);
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = new Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildWidgetAlbumCoverBlur(mediaQuery),
          _buildWidgetContainerMusicPlayer(mediaQuery),
        ],
      ),
    );
  }

  Widget _buildWidgetContainerMusicPlayer(MediaQueryData mediaQuery) {
    return Padding(
      padding: EdgeInsets.only(top: mediaQuery.padding.top + 16.0),
      child: Column(
        children: <Widget>[
          _buildWidgetActionAppBar(),
          SizedBox(height: 48.0),
          _buildWidgetPanelMusicPlayer(mediaQuery),
        ],
      ),
    );
  }

  Widget _buildWidgetPanelMusicPlayer(MediaQueryData mediaQuery) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(48.0),
            topRight: Radius.circular(48.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 36.0),
              _buildWidgetArtistPhoto(mediaQuery),
              SizedBox(height: 48.0),
              _buildWidgetLinearProgressIndicator(),
              SizedBox(height: 4.0),
              _buildWidgetLabelDurationMusic(),
              SizedBox(height: 36.0),
              _buildWidgetMusicInfo(),
              _buildWidgetControlMusicPlayer(),
              
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildWidgetControlMusicPlayer() {
    return Expanded(
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            InkWell(
              onTap: (){
                isPlaying ? pause() : play();
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Icon(isPlaying ? Icons.pause:Icons.play_arrow),
                ),
              ),
            ),
            Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetMusicInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: "Campton_Light",
              fontSize: 20.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.0),
          Text(
            widget.uploader,
            style: TextStyle(
              fontFamily: "Campton_Light",
              color: Color(0xFFfe0000),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetLabelDurationMusic() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          position != null ? "${positionText ?? ''}" : "",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12.0,
          ),
        ),
        Text(
          position != null ? "${durationText ?? ''}" : "",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }



  Widget _buildWidgetLinearProgressIndicator() {
    return Container(
      child: Slider(
          activeColor: Color(0xFFfe0000),
          inactiveColor: Colors.grey.withOpacity(0.5),
          value: position != null ? position.inMilliseconds.toDouble() : 0.0,
          onChanged: (double value) =>
                      audioPlayer.seek((value / 1000).roundToDouble()),
          min: 0.0,
          max: position != null ? duration.inMilliseconds.toDouble(): 0.0,),
    );
  }

  Widget _buildWidgetArtistPhoto(MediaQueryData mediaQuery) {
    return Center(
      child: Container(
        width: mediaQuery.size.width / 2.5,
        height: mediaQuery.size.width / 2.5,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(
            Radius.circular(24.0),
          ),
          image: DecorationImage(
            image: NetworkImage(widget.pic),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetActionAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          Text(
            "TM YouTube",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Campton_Light",
              fontWeight: FontWeight.w900,
              fontSize: 16.0,
            ),
          ),
          Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetAlbumCoverBlur(MediaQueryData mediaQuery) {
    return Container(
      width: double.infinity,
      height: mediaQuery.size.height / 1.8,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        image: DecorationImage(
          image:
              NetworkImage(widget.pic),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.0,
          sigmaY: 10.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.0),
          ),
        ),
      ),
    );
  }
}

Future fetchPost(String url) async {
  final response = await http.post(
    'https://api.w02.savethevideo.com/tasks',
    headers: {HttpHeaders.contentTypeHeader: "application/json"},
    body: '{"type":"info","url":"$url"}',
  );
  final responseJson = json.decode(response.body);

  return responseJson;
}

Future fetchPostData(String url) async {
  var result = await fetchPost(url);
  while (result['state'] == 'SENT') {
    result = await fetchPost(url);
    print("Waiting.....");
  }

  var responseJson;
  if (result['state'] == 'SUCCESS') {
    final response = await http.get(
    'https://api.w02.savethevideo.com' + result['href'],
    headers: {HttpHeaders.contentTypeHeader: "application/json"},
  );
  print('okkkaayyy....');
  responseJson = json.decode(response.body);
  } else {
    responseJson = 'ERROR';
  }

  return responseJson;
}

