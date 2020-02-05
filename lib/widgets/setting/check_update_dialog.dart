import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:allpass/application.dart';
import 'package:allpass/utils/allpass_ui.dart';


class CheckUpdateDialog extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _CheckUpdateDialog();
  }
}

class _CheckUpdateDialog extends State<StatefulWidget> {

  var _checkRes;
  bool _update = false;
  Widget _content;
  String _updateContent = "";
  String _downloadUrl;
  Dio _dio;

  @override
  void initState() {
    super.initState();
    _checkRes = checkUpdate();
  }

  Future<Null> checkUpdate() async {
    _dio = Dio();
    try {
      Response response = await _dio.get(
          "http://47.102.208.175:8080/AllpassUpdateService/update?version=${Application.version}");
      if (response.headers.value("version") == Application.version) {
        _update = false;
      } else {
        _update = true;
        _downloadUrl = response.headers.value("download_url");
      }
      _updateContent = response.data.replaceAll("~", "\n");
      _content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _update
              ? Text("有新版本可以下载！")
              : Text("您的版本是最新版！"),
          _update
              ? Padding(
            padding: AllpassEdgeInsets.smallTBPadding,
            child: Text("更新内容：", style: TextStyle(fontWeight: FontWeight.bold),),
          )
              : Padding(
            padding: AllpassEdgeInsets.smallTBPadding,
            child: Text("最近更新：", style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          Text(_updateContent)
        ],
      );
    } on DioError catch (e) {
      Navigator.pop(context);
      _updateContent = "Unknow Error: $e";
      Fluttertoast.showToast(msg: "检查更新失败");
      _content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("检查过程中有错误出现！"),
          Text(_updateContent)
        ],
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkRes,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(AllpassUI.smallBorderRadius))
              ),
              title: Text("检查更新"),
              content: SingleChildScrollView(
                child: _content,
              ),
              actions: <Widget>[
                _update
                ? FlatButton(
                  child: Text("下载更新"),
                  onPressed: () async {
                    await launch(_downloadUrl);
                  },
                )
                : FlatButton(
                  child: Text("确认"),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                  child: Text("取消"),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            );
          default:
            return Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }
}