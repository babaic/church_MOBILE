import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/screens/auth_screen.dart';
import 'package:saborna_crkva/screens/home_screen.dart';
import 'package:saborna_crkva/screens/loading_screen.dart';
import 'package:saborna_crkva/screens/pitajsvecenika_screen.dart';
import 'package:saborna_crkva/screens/svecenikporuka_screen.dart';

import 'providers/poruke.dart';
import 'providers/svecenik.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Auth()),
          ChangeNotifierProvider(create: (context) => Svecenik()),
          ChangeNotifierProvider(create: (context) => Poruke())
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
            },
          ),
        ));
  }
}
