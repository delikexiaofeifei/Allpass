import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:fluro/fluro.dart';
import 'package:provider/provider.dart';
import 'package:device_info/device_info.dart';

import 'package:allpass/params/config.dart';
import 'package:allpass/params/param.dart';
import 'package:allpass/application.dart';
import 'package:allpass/route/routes.dart';
import 'package:allpass/ui/allpass_ui.dart';
import 'package:allpass/provider/card_list.dart';
import 'package:allpass/provider/password_list.dart';
import 'package:allpass/provider/theme_provider.dart';
import 'package:allpass/pages/login/login_page.dart';
import 'package:allpass/pages/login/auth_login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Router router = Router();
  Routes.configureRoutes(router);
  Application.router = router;
  await Application.initSp();
  Config.initConfig();
  Application.setupLocator();
  Application.initChannelAndHandle();

  if (Platform.isAndroid) {
    //设置Android头部的导航栏透明
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  // 自定义报错页面
  ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "出错了",
          style: AllpassTextUI.titleBarStyle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              child: Text("App出现错误，快去反馈给作者!"),
              padding: AllpassEdgeInsets.smallTBPadding,
            ),
            Padding(
              padding: AllpassEdgeInsets.smallTBPadding,
            ),
            Padding(
              child: Text("以下是出错信息，请截图发到邮箱sys6511@126.com"),
              padding: AllpassEdgeInsets.smallTBPadding,
            ),
            Padding(
              child: Text(flutterErrorDetails.toString(), style: TextStyle(color: Colors.red),),
              padding: AllpassEdgeInsets.smallTBPadding,
            ),
          ],
        ),
      ),
    );
  };

  registerUser();

  final PasswordList passwords = PasswordList()..init();
  final CardList cards = CardList()..init();
  final ThemeProvider theme = ThemeProvider()..init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<PasswordList>.value(
        value: passwords,
      ),
      ChangeNotifierProvider<CardList>.value(
        value: cards,
      ),
      ChangeNotifierProvider<ThemeProvider>.value(
        value: theme
      )
    ],
    child: Allpass(),
  ));
}

class Allpass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allpass',
      theme: Provider.of<ThemeProvider>(context).currTheme,
      home: Config.enabledBiometrics ? AuthLoginPage() : LoginPage(),
      onGenerateRoute: Application.router.generator,
    );
  }
}

void registerUser() async {
  if (Application.sp.getBool(SharedPreferencesKeys.needRegister)??true) {
    DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    String identification;
    String systemInfo;
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await infoPlugin.androidInfo;
      identification = info.androidId;
      systemInfo = "${info.model} android${info.version.release}";
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await infoPlugin.iosInfo;
      identification = info.identifierForVendor;
      systemInfo = "${info.model} IOS${info.systemVersion}";
    } else {
      return;
    }
    try {
      Response response = await Dio().get(
          "$allpassUrl/registerV2?identification=$identification&systemInfo=$systemInfo&allpassVersion=${Application.version}");
      if ((response.data["result"] ?? '0') == "1") {
        Application.sp.setBool(SharedPreferencesKeys.needRegister, false);
      } else {
        Application.sp.setBool(SharedPreferencesKeys.needRegister, true);
      }
    } catch (e) {
      print("网络连接失败");
    }
  }
}
