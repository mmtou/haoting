import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:haoting/views/search.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/xiami.dart';

final AudioPlayer audioPlayer = new AudioPlayer();

class Index extends StatefulWidget {
  var songId;

  Index({this.songId});

  @override
  _IndexState createState() => _IndexState(songId);
}

class _IndexState extends State<Index> with TickerProviderStateMixin {
  _IndexState(this.songId);

  var songId;
  var detail;
  List _tops;
  var _played;
  List _favorites;

  AnimationController controller; //动画控制器
  Animation curved; //曲线动画，动画插值，

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
          title: Text('好听'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (BuildContext context) {
                    return Search();
                  }));
                })
          ],
          bottom: TabBar(tabs: [
            Tab(
              text: '排行榜',
            ),
            Tab(
              text: '我的',
            ),
          ]),
        ),
        body: TabBarView(children: [
          ListView.builder(
            itemCount: _tops.length,
            itemBuilder: (context, index) {
              var item = _tops[index];

              return Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(item['albumLogo']),
                    ),
                    title: Text(item['songName']),
                    subtitle: Text('${item['singers']}-${item['albumName']}'),
                    trailing: IconButton(
                        icon:
//                        item['favorite']
//                            ? Icon(
//                                Icons.favorite,
//                                color: Colors.red,
//                              )
//                            :
                            Icon(Icons.favorite_border),
                        onPressed: () {
                          this._favorite(item);
                        }),
                    onTap: () {
                      _getDetail(item['songId']);
                    },
                  ),
                  Divider(
                    height: 0,
                  ),
                ],
              );
            },
          ),
          Center(
            child: _favorites.length == 0
                ? Text('暂无喜欢的音乐')
                : ListView.builder(
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      var item = _favorites[index];

                      return Column(
                        children: <Widget>[
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(item['albumLogo']),
                            ),
                            title: Text(item['songName']),
                            subtitle:
                                Text('${item['singers']}-${item['albumName']}'),
                            trailing: IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  this._favorite(item);
                                }),
                            onTap: () {
                              _getDetail(item['songId']);
                            },
                          ),
                          Divider(
                            height: 0,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ]),
        bottomNavigationBar: this.detail == null
            ? null
            : Container(
                child: ListTile(
                  title: Text(detail['songName']),
                  subtitle: Text('${detail['singers']}-${detail['albumName']}'),
                  leading: RotationTransition(
                    //旋转动画
                    turns: curved,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(detail['albumLogo']),
                    ),
                  ),
                  trailing: IconButton(
                      icon: _played
                          ? Icon(Icons.pause_circle_outline)
                          : Icon(Icons.play_circle_outline),
                      onPressed: () {
                        _play();
                      }),
                  onTap: () {},
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.black12,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // 设置歌曲url
  _setDetail() {
    setState(() {
      this._played = false;
    });
    audioPlayer.release();
    audioPlayer.setUrl(this.detail['url']);
    this._play();
  }

  // 查询排行榜
  _getTop() async {
    var data = await Xiami.get(
        '/api/billboard/getBillboardDetail', {'billboardId': '103'});
    List songs = data['result']['data']['billboard']['songs'];
    setState(() {
      this._tops = songs;
    });
  }

  // 查询歌曲详情
  _getDetail(songId) async {
    var data =
        await Xiami.get('/api/song/initialize', {'songId': songId.toString()});
    var songDetail = data['result']['data']['songDetail'];
    var listenFiles = songDetail['listenFiles'];
    var sort = {'e': 1, 'l': 2, 'h': 3, 's': 4};
    var currentQuality = 1;
    String currentUrl;
    listenFiles.forEach((item) {
      var quality = sort[item['quality']];
      quality = quality == null ? 1 : quality;
      if (currentQuality >= quality) {
        currentUrl = item['url'];
      }
    });
    currentUrl = currentUrl.replaceAll('http', 'https');
    songDetail['url'] = currentUrl;

    setState(() {
      this.detail = songDetail;
    });
    this._setDetail();
  }

  // 播放暂停歌曲
  _play() async {
    if (!_played) {
      int result = await audioPlayer.resume();
      if (result == 1) {
        setState(() {
          this._played = true;
        });
      }

      controller.repeat();
    } else {
      int result = await audioPlayer.pause();
      setState(() {
        this._played = false;
      });
      controller.forward();
    }
  }

  // 获取喜欢的音乐
  _getFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var favoriteStr = prefs.getString('favorites');
    if (favoriteStr != null) {
      var favorites = json.decode(favoriteStr);
      setState(() {
        this._favorites = favorites;
      });
    }
  }

  // 喜欢😍
  _favorite(f) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var favoriteStr = prefs.getString('favorites');
    List favorites = [];
    if (favoriteStr != null) {
      favorites = json.decode(favoriteStr);
    }
    for (int i = 0; i < favorites.length; i++) {
      if (favorites[i]['songId'] == f['songId']) {
        favorites.removeAt(i);
        setState(() {
          this._favorites = favorites;
        });
        prefs.setString('favorites', json.encode(favorites));
        return;
      }
    }

    favorites.insert(0, f);
    setState(() {
      this._favorites = favorites;
    });
    prefs.setString('favorites', json.encode(favorites));
  }

  @override
  void initState() {
    super.initState();
    this._played = false;
    this._tops = [];
    this._favorites = [];

    this._getFavorite();
    this._getTop();

    if (this.songId != null) {
      this._getDetail(this.songId);
      this._setDetail();
    }

    controller = new AnimationController(
        vsync: this, duration: const Duration(seconds: 12));
    curved =
        new CurvedAnimation(parent: controller, curve: Curves.linear);
  }
}
