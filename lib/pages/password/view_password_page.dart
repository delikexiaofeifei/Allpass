import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:allpass/model/password_bean.dart';
import 'package:allpass/ui/allpass_ui.dart';
import 'package:allpass/utils/encrypt_util.dart';
import 'package:allpass/utils/screen_util.dart';
import 'package:allpass/provider/theme_provider.dart';
import 'package:allpass/pages/common/detail_text_page.dart';
import 'package:allpass/pages/password/edit_password_page.dart';
import 'package:allpass/widgets/common/label_chip.dart';
import 'package:allpass/widgets/common/confirm_dialog.dart';

/// 查看密码页
class ViewPasswordPage extends StatefulWidget {
  final PasswordBean oldData;

  ViewPasswordPage(this.oldData);

  @override
  State<StatefulWidget> createState() {
    return _ViewPasswordPage();
  }
}

class _ViewPasswordPage extends State<ViewPasswordPage> {
  PasswordBean _bean;

  bool _passwordVisible = false;
  var _futureHelper;

  String _password = "";
  Color _mainColor;

  Future<Null> _decryptPassword() async {
    _password = EncryptUtil.decrypt(_bean.password);
  }

  @override
  void initState() {
    PasswordBean data = widget.oldData;
    _bean = PasswordBean(
      username: data.username,
      password: data.password,
      url: data.url,
      key: data.uniqueKey,
      name: data.name,
      folder: data.folder,
      label: data.label,
      notes: data.notes,
      fav: data.fav,
      color: data.color,
      createTime: data.createTime
    );

    _futureHelper = _decryptPassword();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainColor = Provider.of<ThemeProvider>(context).currTheme.primaryColor;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (_bean.isChanged) {
            Navigator.pop<PasswordBean>(context, _bean);
          } else {
            Navigator.pop<PasswordBean>(context, null);
          }
          return Future<bool>.value(false);
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                "查看密码",
                style: AllpassTextUI.titleBarStyle,
              ),
              centerTitle: true,
              actions: <Widget>[
                  _bean.fav == 1
                      ? Icon(Icons.favorite, color: Colors.redAccent,)
                      : Icon(Icons.favorite_border),
                Padding(padding: AllpassEdgeInsets.smallLPadding,),
                Padding(padding: AllpassEdgeInsets.smallLPadding,)
              ],
            ),
            backgroundColor: Provider.of<ThemeProvider>(context).specialBackgroundColor,
            body: FutureBuilder(
              future: _futureHelper,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: AllpassEdgeInsets.forViewCardInset,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AllpassUI.smallBorderRadius)
                              ),
                              elevation: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 23, horizontal: 0),
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: _bean.color,
                                      child: Text(
                                        _bean.name.substring(0, 1),
                                        style: TextStyle(fontSize: 25, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: AllpassEdgeInsets.smallLPadding,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(left: 0),
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                                maxWidth: AllpassScreenUtil.setWidth(450)
                                            ),
                                            child: Text(_bean.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                                            ),
                                          )
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(left: 0, right: 5, top: 3, bottom: 0),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.folder_open),
                                              Container(
                                                margin: EdgeInsets.only(left: 5),
                                                color: Colors.grey[250],
                                                child: Container(
                                                  child: Text(_bean.folder,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  width: 50,
                                                ),
                                              ),
                                            ],
                                          )),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: AllpassEdgeInsets.forViewCardInset,
                            child: Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AllpassUI.smallBorderRadius))),
                                elevation: 0,
                                child: SizedBox(
                                  width: ScreenUtil.screenWidth * 0.8,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(padding: AllpassEdgeInsets.smallTBPadding,),
                                      // 账号标题
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: AllpassScreenUtil.setWidth(100),
                                            right: AllpassScreenUtil.setWidth(100),
                                            bottom: AllpassScreenUtil.setHeight(10)),
                                        child: Text("账号", style: TextStyle(fontSize: 16, color: _mainColor),
                                        ),
                                      ),
                                      // 用户名主体
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: AllpassScreenUtil.setWidth(100),
                                            right: AllpassScreenUtil.setWidth(100),
                                            bottom: AllpassScreenUtil.setHeight(50)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(_bean.username,
                                                overflow: TextOverflow.ellipsis,
                                                style: AllpassTextUI.firstTitleStyle,
                                              ),),
                                            Padding(padding: AllpassEdgeInsets.smallLPadding,),
                                            InkWell(
                                              child: Text("复制", style: TextStyle(fontSize: 14, color: _mainColor),),
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(text: _bean.username));
                                                Fluttertoast.showToast(msg: "已复制账号");
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                      // 密码标题
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: AllpassScreenUtil.setWidth(100),
                                            right: AllpassScreenUtil.setWidth(100),
                                            bottom: AllpassScreenUtil.setHeight(10)),
                                        child: Text("密码", style: TextStyle(fontSize: 16, color: _mainColor),),
                                      ),
                                      // 密码主体
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: AllpassScreenUtil.setWidth(100),
                                            right: AllpassScreenUtil.setWidth(100),
                                            bottom: AllpassScreenUtil.setHeight(30)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(_passwordVisible
                                                  ? _password
                                                  : "*" * _password.length,
                                                overflow: TextOverflow.ellipsis,
                                                style: AllpassTextUI.firstTitleStyle,
                                              ),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                InkWell(
                                                  child: _passwordVisible
                                                      ? Icon(Icons.visibility)
                                                      : Icon(Icons.visibility_off),
                                                  onTap: () {
                                                    setState(() {
                                                      _passwordVisible = !_passwordVisible;
                                                    });
                                                  },
                                                ),
                                                Padding(padding: AllpassEdgeInsets.smallLPadding,),
                                                InkWell(
                                                  onTap: () {
                                                    Clipboard.setData(ClipboardData(text: _password));
                                                    Fluttertoast.showToast(msg: "已复制密码");
                                                  },
                                                  child: Text("复制",
                                                    style: TextStyle(fontSize: 14, color: _mainColor),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      // 链接标题
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: AllpassScreenUtil.setWidth(100),
                                            right: AllpassScreenUtil.setWidth(100),
                                            bottom: AllpassScreenUtil.setHeight(10)),
                                        child: Text("链接",
                                          style: TextStyle(fontSize: 16, color: _mainColor)
                                        ),
                                      ),
                                      // 链接主体
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: AllpassScreenUtil.setWidth(100),
                                            right: AllpassScreenUtil.setWidth(100),
                                            bottom: AllpassScreenUtil.setHeight(50)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                                child: InkWell(
                                                  onTap: () async {
                                                    if (_bean.url.startsWith("https")
                                                        || _bean.url.startsWith("http"))
                                                      await launch(_bean.url);
                                                  },
                                                  child: Text(_bean.url,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: AllpassTextUI
                                                        .firstTitleStyle,
                                                  ),
                                                  onLongPress: () => Fluttertoast.showToast(msg: _bean.url),
                                                )),
                                            Padding(padding: AllpassEdgeInsets.smallLPadding,),
                                            InkWell(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(text: _bean.url));
                                                Fluttertoast.showToast(msg: "已复制链接");
                                              },
                                              child: Text("复制",
                                                style: TextStyle(fontSize: 14, color: _mainColor),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      // 备注标题
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: AllpassScreenUtil.setWidth(100),
                                            right: AllpassScreenUtil.setWidth(100),
                                            bottom: AllpassScreenUtil.setHeight(10)),
                                        child: Text("备注",
                                          style: TextStyle(fontSize: 16, color: _mainColor),
                                        ),
                                      ),
                                      // 备注主体
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: AllpassScreenUtil.setWidth(100),
                                            right: AllpassScreenUtil.setWidth(100),
                                            bottom: AllpassScreenUtil.setHeight(50)),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    if (_bean.notes.length >= 1) {
                                                      Navigator.push(context, CupertinoPageRoute(
                                                        builder: (context) => DetailTextPage("备注", _bean.notes, false),));
                                                    }
                                                  },
                                                  child: Text(_bean.notes.length<1?"无备注":_bean.notes,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: _bean.notes.length<1
                                                        ?AllpassTextUI.hintTextStyle
                                                        :AllpassTextUI.firstTitleStyle,
                                                  ),
                                                )),
                                          ],
                                        ),
                                      ),
                                      // 标签标题
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: AllpassScreenUtil.setWidth(100),
                                            right: AllpassScreenUtil.setWidth(100),
                                            bottom: AllpassScreenUtil.setHeight(10)),
                                        child: Text("标签",
                                          style: TextStyle(fontSize: 16, color: _mainColor),
                                        ),
                                      ),
                                      // 标签主体
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: AllpassScreenUtil.setWidth(100),
                                            right: AllpassScreenUtil.setWidth(100),
                                            bottom: AllpassScreenUtil.setHeight(50)),
                                        child: Wrap(
                                          children: _getTag(),
                                          spacing: 5,
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                          ),
                          Padding(
                            padding: AllpassEdgeInsets.smallTBPadding,
                          ),
                          // 最下面一行点击按钮
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              FloatingActionButton(
                                heroTag: "edit",
                                backgroundColor: Colors.blueAccent,
                                elevation: 0,
                                onPressed: () {
                                  Navigator.push(context,
                                      CupertinoPageRoute(
                                          builder: (context) => EditPasswordPage(_bean, "编辑密码")))
                                      .then((bean) {
                                    if (bean != null) {
                                      setState(() {
                                        _bean = bean;
                                        _decryptPassword();
                                      });
                                    }
                                  });
                                },
                                child: Icon(Icons.edit),
                              ),
                              Padding(
                                padding: AllpassEdgeInsets.smallLPadding,
                              ),
                              FloatingActionButton(
                                heroTag: "delete",
                                elevation: 0,
                                backgroundColor: Colors.redAccent,
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => ConfirmDialog("确认删除", "你将删除此密码，确认吗？"))
                                      .then((delete) {
                                    if (delete) {
                                      // 如果想删除，则先将isChanged属性改为false
                                      // 否则如果先修改再删除会导致password页不删除
                                      _bean.isChanged = false;
                                      Navigator.pop<PasswordBean>(context, _bean);
                                    }
                                  });
                                },
                                child: Icon(Icons.delete),
                              ),
                            ],
                          ),
                          Padding(
                            padding: AllpassEdgeInsets.smallTBPadding,
                          )
                        ],
                      ),
                    );
                  default:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                }
              },
            )));
  }

  List<Widget> _getTag() {
    List<Widget> labelChoices = List();
    _bean.label.forEach((item) {
      labelChoices.add(LabelChip(
          text: item,
          selected: true,
          onSelected: (_) {}
      ));
    });
    if (labelChoices.length == 0) {
      labelChoices.add(Text("无标签", style: AllpassTextUI.hintTextStyle,));
    }
    return labelChoices;
  }
}
