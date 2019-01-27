import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/netease.dart';
import '../utils/xiami.dart';
import '../views/index.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var _xiamiList = [];
  var _neteaseList = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            autofocus: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '关键字搜索',
                hintStyle: TextStyle(color: Colors.white30)),
            onSubmitted: (text) {
              _search(text);
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                text: '虾米音乐',
              ),
              Tab(
                text: '网易云音乐',
              ),
              Tab(
                text: 'QQ音乐',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: _xiamiList.length,
              itemBuilder: (context, index) {
                var item = _xiamiList[index];

                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(item['albumLogo']),
                      ),
                      title: Text(item['songName']),
                      subtitle: Text('${item['singers']}-${item['albumName']}'),
                      trailing: IconButton(
                          icon: Icon(Icons.favorite_border), onPressed: () {}),
                      onTap: () {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (BuildContext context) {
                              return Index(songId: item['songId']);
                            },
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 0,
                    ),
                  ],
                );
              },
            ),
            ListView.builder(
              itemCount: _neteaseList.length,
              itemBuilder: (context, index) {
                var item = _neteaseList[index];

                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: item['al']['picUrl'] != null
                            ? NetworkImage(item['al']['picUrl'])
                            : null,
                      ),
                      title: Text(item['name']),
                      subtitle: Text(
                          '${item['ar'][0]['name']}-${item['al']['name']}'),
                      trailing: IconButton(
                          icon: Icon(Icons.favorite_border), onPressed: () {}),
                      onTap: () {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (BuildContext context) {
                              return Index(songId: item['songId']);
                            },
                          ),
                        );
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
              child: null,
            ),
          ],
        ),
      ),
    );
  }

  _search(keyword) async {
    _searchXiami(keyword);
//    _searchNetease(keyword);
  }

  _searchXiami(keyword) async {
    var param = {
      'key': keyword,
      'pagingVO': {'page': 1, 'pageSize': 60}
    };
    var data = await Xiami.get('/api/search/searchSongs', param);
    var songs = data['result']['data']['songs'];
    setState(() {
      this._xiamiList = songs;
    });
  }

  _searchNetease(keyword) async {
    var param = json.encode({
      'limit': 20,
      'offset': 0,
      'queryCorrect': true,
      's': keyword,
      'strategy': 5,
      'type': 1,
    });
    var data = await Netease.get('/weapi/search/get', param);

    var songs = data['result']['songs'];
    setState(() {
      this._neteaseList = songs;
    });
  }
}
