import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/providers/obavijesti.dart';
import 'package:saborna_crkva/providers/obredi.dart';
import 'package:saborna_crkva/screens/auth_screen.dart';
import 'package:saborna_crkva/screens/conversations_screen.dart';
import 'package:saborna_crkva/screens/donacije_screen.dart';
import 'package:saborna_crkva/screens/doniraj_screen.dart';
import 'package:saborna_crkva/screens/home_screen.dart';
import 'package:saborna_crkva/screens/loading_screen.dart';
import 'package:saborna_crkva/screens/novosti_details_screen.dart';
import 'package:saborna_crkva/screens/novosti_screen.dart';
import 'package:saborna_crkva/screens/obavijesti_details_screen.dart';
import 'package:saborna_crkva/screens/obavjestenja_screen.dart';
import 'package:saborna_crkva/screens/pitajsvecenika_screen.dart';
import 'package:saborna_crkva/screens/svecenikporuka_screen.dart';
import 'package:saborna_crkva/screens/zakazi_obred_screen.dart';

import 'localization/demo_localization.dart';
import 'localization/language_constants.dart';
import 'providers/donacije.dart';
import 'providers/novosti.dart';
import 'providers/poruke.dart';
import 'providers/svecenik.dart';
import 'screens/korisni_linkovi_screen.dart';
import 'screens/obred_konverzacija.dart';
import 'screens/obred_zahtjevi_screen.dart';

void main() {
  runApp(DevicePreview(
    enabled: false,
    builder: (context) => MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

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
          ChangeNotifierProvider(create: (context) => Donacije()),
          ChangeNotifierProvider(create: (context) => Obredi()),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.brown,
              accentColor: Colors.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            locale: _locale,
            supportedLocales: [
              Locale("bs", "BA"),
              Locale("sr", "RS"),
            ],
            localizationsDelegates: [
              DemoLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode &&
                    supportedLocale.countryCode == locale.countryCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
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
              ObavijestiDetailsScreen.routeName: (ctx) => ObavijestiDetailsScreen(),
              DonirajScreen.routeName: (ctx) => DonirajScreen(),
              DonacijeScreen.routeName: (ctx) => DonacijeScreen(),
              ZakaziObredScreen.routeName: (ctx) => ZakaziObredScreen(),
              ObredKonverzacijaScreen.routeName: (ctx) => ObredKonverzacijaScreen(),
              ObredZahtjeviScreen.routeName: (ctx) => ObredZahtjeviScreen(),
              KorisniLinkoviScreen.routeName: (ctx) => KorisniLinkoviScreen()
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
