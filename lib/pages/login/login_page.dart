import 'dart:io';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:allpass/application.dart';
import 'package:allpass/params/params.dart';
import 'package:allpass/utils/allpass_ui.dart';
import 'package:allpass/utils/navigation_util.dart';
import 'package:allpass/utils/encrypt_util.dart';
import 'package:allpass/utils/screen_util.dart';
import 'package:allpass/provider/card_list.dart';
import 'package:allpass/provider/password_list.dart';
import 'package:allpass/pages/login/register_page.dart';
import 'package:allpass/pages/about_page.dart';
import 'package:allpass/widgets/common/none_border_circular_textfield.dart';

/// 登陆页面
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  var _usernameController;
  var _passwordController;

  int inputErrorTimes = 0; // 超过五次自动清除所有内容

  @override
  void initState() {
    _usernameController = TextEditingController(text: Params.username);
    _passwordController = TextEditingController();
    if (Application.sp.getBool("FIRST_RUN")??true) {
      WidgetsBinding.instance.addPostFrameCallback((callback) {
        showDialog(
            context: context,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AllpassUI.smallBorderRadius),
              ),
              title: Text("服务条款"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AboutPage.serviceContent,
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("同意并继续"),
                  onPressed: () {
                    initAppFirstRun();
                    Params.paramsInit();
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("取消"),
                  onPressed: () => exit(0),
                )
              ],
            ));
      });
    }
    super.initState();
  }
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AllpassColorUI.mainBackgroundColor,
        elevation: 0,
        brightness: Brightness.light,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AllpassColorUI.mainBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: AllpassScreenUtil.setHeight(400)),
        child: Padding(
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(150), right: ScreenUtil().setWidth(150)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                child: Text(
                  "登录 Allpass",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold
                  ),
                ),
                padding: AllpassEdgeInsets.smallTBPadding,
              ),
              NoneBorderCircularTextField(
                _usernameController,
                "请输入用户名",
                null,
                false,
                null
              ),
              NoneBorderCircularTextField(
                _passwordController,
                "请输入密码",
                null,
                true,
                login,
              ),
              Padding(
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AllpassUI.bigBorderRadius)
                  ),
                  padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                  child: Text("登录", style: TextStyle(color: Colors.white, fontSize: 16)),
                  color: AllpassColorUI.mainColor,
                  onPressed: () => login(),
                ),
                padding: AllpassEdgeInsets.smallTBPadding,
              ),
              Padding(
                padding: EdgeInsets.only(top: AllpassScreenUtil.setHeight(300)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text("注册"),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => RegisterPage()
                    )),
                  ),
                  Text("|"),
                  FlatButton(
                    child: Text("使用生物识别"),
                    onPressed: () {
                      if (Params.enabledBiometrics)
                        NavigationUtil.goAuthLoginPage(context);
                      else Fluttertoast.showToast(msg: "您还未开启生物识别");
                    },
                  )
                ],
              ),
              Padding(padding: EdgeInsets.only(bottom: AllpassScreenUtil.setHeight(80)),)
            ],
          ),
        ),
      ),
    );
  }

  void login() async {
    if (inputErrorTimes >= 5) {
      await Provider.of<PasswordList>(context).clear();
      await Provider.of<CardList>(context).clear();
      await Application.sp.clear();
      Params.paramsClear();
      Fluttertoast.showToast(msg: "连续错误超过五次！已清除所有数据，请重新注册");
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => RegisterPage()
      ));
    } else {
      if (Params.username != "" && Params.password != "") {
        if (Params.username == _usernameController.text
            && _passwordController.text == EncryptUtil.decrypt(Params.password)) {
          NavigationUtil.goHomePage(context);
          Fluttertoast.showToast(msg: "登录成功");
        } else if (_usernameController.text == "" || _passwordController.text == "") {
          Fluttertoast.showToast(msg: "请输入用户名或密码");
        } else {
          inputErrorTimes++;
          Fluttertoast.showToast(msg: "用户名或密码错误，已错误$inputErrorTimes次，连续超过五次将删除所有数据！");
        }
      } else {
        Fluttertoast.showToast(msg: "当前不存在用户，请先注册！");
      }
    }
  }
}
