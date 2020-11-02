import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/providers/obavijesti.dart';
import 'package:saborna_crkva/screens/auth_screen.dart';
import 'package:saborna_crkva/screens/conversations_screen.dart';
import 'package:saborna_crkva/screens/home_screen.dart';
import 'package:saborna_crkva/screens/loading_screen.dart';
import 'package:saborna_crkva/screens/novosti_details_screen.dart';
import 'package:saborna_crkva/screens/novosti_screen.dart';
import 'package:saborna_crkva/screens/obavijesti_details_screen.dart';
import 'package:saborna_crkva/screens/obavjestenja_screen.dart';
import 'package:saborna_crkva/screens/pitajsvecenika_screen.dart';
import 'package:saborna_crkva/screens/svecenikporuka_screen.dart';

import 'providers/novosti.dart';
import 'providers/poruke.dart';
import 'providers/svecenik.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Auth()),
          ChangeNotifierProvider(create: (context) => Svecenik()),
          ChangeNotifierProvider(create: (context) => Poruke()),
          ChangeNotifierProvider(create: (context) => Novosti()),
          ChangeNotifierProvider(create: (context) => Obavijesti()),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.brown,
              accentColor: Colors.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: auth.isAuth
                ? HomeScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? LoadingScreen()
                            : AuthScreen(),
                  ),
            routes: {
              PitajSvecenikaScreen.routeName: (ctx) => PitajSvecenikaScreen(),
              SvecenikPorukaScreen.routeName: (ctx) => SvecenikPorukaScreen(),
              ConversationsScreen.routeName: (ctx) => ConversationsScreen(),
              NovostiScreen.routeName: (ctx) => NovostiScreen(),
              NovostiDetailsScreen.routeName: (ctx) => NovostiDetailsScreen(),
              ObavjestenjaScreen.routeName: (ctx) => ObavjestenjaScreen(),
              ObavijestiDetailsScreen.routeName: (ctx) =>
                  ObavijestiDetailsScreen()
            },
          ),
        ));
  }

  Future<void> initPlatformState() async {
    OneSignal.shared.init("24c544c9-3eff-40b8-bae3-b8d58ab01ee9", iOSSettings: {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.inAppLaunchUrl: false
    });

    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      print("Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}");
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print("Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}");
    });
  }
}
