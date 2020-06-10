import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:allpass/ui/allpass_ui.dart';
import 'package:allpass/provider/password_list.dart';
import 'package:allpass/params/runtime_data.dart';
import 'package:allpass/params/allpass_type.dart';
import 'package:allpass/pages/password/edit_password_page.dart';
import 'package:allpass/pages/password/password_widget_item.dart';
import 'package:allpass/pages/search/search_page.dart';
import 'package:allpass/widgets/common/search_button_widget.dart';
import 'package:allpass/widgets/common/confirm_dialog.dart';
import 'package:allpass/widgets/common/select_item_dialog.dart';
import 'package:allpass/widgets/common/nodata_widget.dart';
import 'package:allpass/widgets/common/letter_index_bar.dart';


/// 密码页面
class PasswordPage extends StatefulWidget {
  @override
  _PasswordPageState createState() {
    return _PasswordPageState();
  }
}

class _PasswordPageState extends State<PasswordPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<Null> _query(PasswordList model) async {
    await model.refresh();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<PasswordList>(
      builder: (context, model, _) {
        return Scaffold(
            appBar: AppBar(
              title: Padding(
                padding: AllpassEdgeInsets.smallLPadding,
                child: InkWell(
                  splashColor: Colors.transparent,
                  child: Text("密码", style: AllpassTextUI.titleBarStyle,),
                  onTap: () {
                    _controller.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.linear);
                  },
                ),
              ),
              automaticallyImplyLeading: false,
              actions: <Widget>[
                RuntimeData.multiSelected
                    ? Row(
                  children: <Widget>[
                    PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case "删除":
                              _deletePassword(context, model);
                              break;
                            case "移动":
                              _movePassword(context, model);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                              value: "移动",
                              child: Text("移动")
                          ),
                          PopupMenuItem(
                              value: "删除",
                              child: Text("删除")
                          ),
                        ]
                    ),
                    Padding(
                      padding: AllpassEdgeInsets.smallLPadding,
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      child: Icon(Icons.select_all),
                      onTap: () {
                        if (RuntimeData.multiPasswordList.length != model.passwordList.length) {
                          RuntimeData.multiPasswordList.clear();
                          setState(() {
                            RuntimeData.multiPasswordList.addAll(model.passwordList);
                          });
                        } else {
                          setState(() {
                            RuntimeData.multiPasswordList.clear();
                          });
                        }
                      },
                    ),
                  ],
                ) : Container(),
                Padding(
                  padding: AllpassEdgeInsets.smallLPadding,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  child: RuntimeData.multiSelected ? Icon(Icons.clear) : Icon(Icons.sort),
                  onTap: () {
                    setState(() {
                      RuntimeData.multiPasswordList.clear();
                      RuntimeData.multiSelected = !RuntimeData.multiSelected;
                    });
                  },
                ),
                Padding(
                  padding: AllpassEdgeInsets.smallLPadding,
                ),
                Padding(
                  padding: AllpassEdgeInsets.smallLPadding,
                )
              ],
            ),
            body: Column(
              children: <Widget>[
                // 搜索框 按钮
                SearchButtonWidget(_searchPress, "密码"),
                // 密码列表
                Expanded(
                  child: RefreshIndicator(
                      onRefresh: () => _query(model),
                      child: Scrollbar(
                        child: model.passwordList.length >= 1
                            ? RuntimeData.multiSelected
                            ? ListView.builder(
                          controller: _controller,
                          itemBuilder: (context, index) => MultiPasswordWidgetItem(index),
                          itemCount: model.passwordList.length,
                        )
                            : Stack(
                          children: <Widget>[
                            ListView.builder(
                              controller: _controller,
                              itemBuilder: (context, index) => PasswordWidgetItem(index),
                              itemCount: model.passwordList.length,
                            ),
                            LetterIndexBar(_controller),
                          ],
                        )
                            : NoDataWidget("这里存储你的密码信息，例如\n微博账号、知乎账号等"),
                      )),
                )
              ],
            ),
            // 添加 按钮
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => EditPasswordPage(null, "添加密码")))
                    .then((resData) async {
                  if (resData != null) {
                    await model.insertPassword(resData);
                    if (RuntimeData.newPasswordOrCardCount >= 3) {
                      await model.refresh();
                    }
                  }
                });
              },
              heroTag: "password",
            ));
      },
    );
  }

  _searchPress() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchPage(AllpassType.PASSWORD)));
  }

  void _deletePassword(BuildContext context, PasswordList model) {
    if (RuntimeData.multiPasswordList.length == 0) {
      Fluttertoast.showToast(msg: "请选择至少一项密码");
    } else {
      showDialog<bool>(
          context: context,
          builder: (context) => ConfirmDialog("确认删除",
              "您将删除${RuntimeData.multiPasswordList.length}项密码，确认吗？"))
          .then((confirm) async {
        if (confirm) {
          for (var item in RuntimeData.multiPasswordList) {
            await model.deletePassword(item);
          }
          RuntimeData.multiPasswordList.clear();
        }
      });
    }
  }

  void _movePassword(BuildContext context, PasswordList model) {
    if (RuntimeData.multiPasswordList.length == 0) {
      Fluttertoast.showToast(msg: "请选择至少一项密码");
    } else {
      showDialog(
          context: context,
          builder: (context) => SelectItemDialog())
          .then((value) async {
        if (value != null) {
          for (int i = 0; i < RuntimeData.multiPasswordList.length; i++) {
            RuntimeData.multiPasswordList[i].folder = value;
            await model.updatePassword(RuntimeData.multiPasswordList[i]);
          }
          Fluttertoast.showToast(msg: "已移动${RuntimeData.multiPasswordList.length}项密码至 $value 文件夹");
          setState(() {
            RuntimeData.multiPasswordList.clear();
          });
        }
      });
    }
  }
}