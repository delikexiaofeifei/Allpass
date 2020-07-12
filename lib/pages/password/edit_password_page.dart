import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:allpass/params/config.dart';
import 'package:allpass/params/runtime_data.dart';
import 'package:allpass/model/password_bean.dart';
import 'package:allpass/ui/allpass_ui.dart';
import 'package:allpass/utils/encrypt_util.dart';
import 'package:allpass/provider/theme_provider.dart';
import 'package:allpass/pages/common/detail_text_page.dart';
import 'package:allpass/widgets/common/label_chip.dart';
import 'package:allpass/widgets/common/add_category_dialog.dart';
import 'package:allpass/widgets/common/password_generation_dialog.dart';
import 'package:allpass/widgets/common/none_border_circular_textfield.dart';

/// 查看或编辑密码页面
class EditPasswordPage extends StatefulWidget {
  final PasswordBean data;
  final String pageTitle;

  EditPasswordPage(this.data, this.pageTitle);

  @override
  _EditPasswordPage createState() {
    return _EditPasswordPage();
  }
}

class _EditPasswordPage extends State<EditPasswordPage> {
  PasswordBean _oldData;

  var _futureHelper;

  String _password;
  String _folder = "默认";
  TextEditingController _nameController;
  TextEditingController _usernameController;
  TextEditingController _passwordController;
  TextEditingController _notesController;
  TextEditingController _urlController;
  List<String> _labels;
  int _fav = 0;
  String _createTime;

  Color _mainColor;

  bool _passwordVisible = false;


  @override
  void dispose() {
    _nameController?.dispose();
    _usernameController?.dispose();
    _passwordController?.dispose();
    _notesController?.dispose();
    _urlController?.dispose();
    super.dispose();
  }

  Future<Null> _decryptPassword() async {
    _password =  EncryptUtil.decrypt(_oldData.password);
    _passwordController = TextEditingController(text: _password);
  }

  @override
  void initState() {
    if (widget.data != null) {
      this._oldData = widget.data;
      _nameController = TextEditingController(text: _oldData.name);
      _usernameController = TextEditingController(text: _oldData.username);
      _notesController = TextEditingController(text: _oldData.notes);
      _urlController = TextEditingController(text: _oldData.url);
      if (_passwordController == null) {
        _passwordController = TextEditingController();
      }
      _folder = _oldData.folder;
      _labels = List()..addAll(_oldData.label);
      _fav = _oldData.fav;
      _createTime = _oldData.createTime;
    } else {
      _nameController = TextEditingController();
      _usernameController = TextEditingController();
      _notesController = TextEditingController();
      _urlController = TextEditingController();
      _passwordController = TextEditingController();
      _labels = List();
    }
    _futureHelper = _decryptPassword();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainColor = Provider.of<ThemeProvider>(context).currTheme.primaryColor;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pageTitle,
          style: AllpassTextUI.titleBarStyle,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.code),
            onPressed: () {
              showDialog(context: context, child: PasswordGenerationDialog())
                  .then((value) {
                if (value != null) _passwordController.text = value;
              });
            },
          ),
          IconButton(
            icon: _fav == 1
                ? Icon(Icons.favorite, color: Colors.redAccent,)
                : Icon(Icons.favorite_border),
            onPressed: () {
              setState(() {
                _fav = _fav == 1 ? 0 : 1;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.check,),
            onPressed: () async {
              if (_usernameController.text.length >= 1
                  && _passwordController.text.length >= 1) {
                String pw = EncryptUtil.encrypt(_passwordController.text);
                String name = _nameController.text.trimLeft();
                PasswordBean tempData = PasswordBean(
                  key: _oldData?.uniqueKey,
                  username: _usernameController.text,
                  password: pw,
                  url: _urlController.text,
                  name: name,
                  folder: _folder,
                  label: _labels,
                  notes: _notesController.text,
                  isChanged: true,
                  fav: _fav,
                  color: _oldData?.color??getRandomColor(),
                  createTime: _createTime
                );
                Navigator.pop<PasswordBean>(context, tempData);
              } else {
                Fluttertoast.showToast(msg: "账号和密码不允许为空！");
              }
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _futureHelper,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 40, right: 40, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "名称",
                              style: TextStyle(fontSize: 16, color: _mainColor),
                            ),
                            NoneBorderCircularTextField(
                              editingController: _nameController,
                              trailing: InkWell(
                                child: Icon(
                                  Icons.cancel,
                                  size: 20,
                                ),
                                onTap: () {
                                  // 保证在组件build的第一帧时才去触发取消清空内容，防止报错
                                  WidgetsBinding.instance.addPostFrameCallback((_) => _nameController.clear());
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 40, right: 40, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "账号",
                              style: TextStyle(fontSize: 16, color: _mainColor),
                            ),
                            NoneBorderCircularTextField(
                              editingController: _usernameController,
                              trailing: InkWell(
                                child: Icon(
                                  Icons.cancel,
                                  size: 20,
                                ),
                                onTap: () {
                                  WidgetsBinding.instance.addPostFrameCallback((_) => _usernameController.clear());
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 40, right: 40, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "密码",
                              style: TextStyle(fontSize: 16, color: _mainColor),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: NoneBorderCircularTextField(
                                    editingController: _passwordController,
                                    trailing: InkWell(
                                      child: Icon(
                                          Icons.cancel,
                                          size: 20),
                                      onTap: () {
                                        WidgetsBinding.instance.addPostFrameCallback((_) => _passwordController.clear());
                                      },
                                    ),
                                    obscureText: !_passwordVisible,
                                  ),
                                ),
                                IconButton(
                                  icon: _passwordVisible == true
                                      ? Icon(Icons.visibility)
                                      : Icon(Icons.visibility_off),
                                  onPressed: () {
                                    this.setState(() {
                                      if (_passwordVisible == false)
                                        _passwordVisible = true;
                                      else
                                        _passwordVisible = false;
                                    });
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 40, right: 40, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "链接",
                              style: TextStyle(fontSize: 16, color: _mainColor),
                            ),
                            NoneBorderCircularTextField(
                              editingController: _urlController,
                              trailing: InkWell(
                                child: Icon(
                                  Icons.cancel,
                                  size: 20,
                                ),
                                onTap: () {
                                  WidgetsBinding.instance.addPostFrameCallback((_) => _urlController.clear());
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 40, right: 40, bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "文件夹",
                              style: TextStyle(fontSize: 16, color: _mainColor),
                            ),
                            DropdownButton(
                              onChanged: (newValue) {
                                setState(() {
                                  _folder = newValue;
                                });
                              },
                              items: RuntimeData.folderList.map<DropdownMenuItem<String>>((item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item, style: TextStyle(
                                      color: Config.theme == 'dark'
                                          ? Colors.white
                                          : Colors.black
                                  ),),
                                );
                              }).toList(),
                              style: AllpassTextUI.firstTitleStyle,
                              elevation: 8,
                              iconSize: 30,
                              value: _folder,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 40, right: 40, bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Text(
                                "标签",
                                style: TextStyle(fontSize: 16, color: _mainColor),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.start,
                                      spacing: 8.0,
                                      runSpacing: 10.0,
                                      children: _getTag()),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 40, right: 40, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "备注",
                              style: TextStyle(fontSize: 16, color: _mainColor),
                            ),
                            NoneBorderCircularTextField(
                              editingController: _notesController,
                              maxLines: null,
                              onTap: () {
                                Navigator.push(context, CupertinoPageRoute(
                                  builder: (context) => DetailTextPage("备注", _notesController.text, true),
                                )).then((newValue) {
                                  setState(() {
                                    _notesController.text = newValue;
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ));
            default:
              return Center(
                child: Text("未知状态，请与开发者联系：sys6511@126.com"),
              );
          }
        },
      ),
    );
  }

  List<Widget> _getTag() {
    List<Widget> labelChoices = List();
    RuntimeData.labelList.forEach((item) {
      labelChoices.add(LabelChip(
        text: item,
        selected: _labels.contains(item),
        onSelected: (selected) {
          setState(() => _labels.contains(item)
              ? _labels.remove(item)
              : _labels.add(item));
        },
      ));
    });
    labelChoices.add(
      ChoiceChip(
          label: Icon(Icons.add),
          selected: false,
          onSelected: (_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AddCategoryDialog("标签"),
            ).then((_) => setState((){}));
          }),
    );
    return labelChoices;
  }
}
