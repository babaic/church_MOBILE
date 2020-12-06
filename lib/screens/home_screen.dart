import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/localization/language.dart';
import 'package:saborna_crkva/localization/language_constants.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/screens/obavjestenja_screen.dart';
import 'package:saborna_crkva/screens/obred_zahtjevi_screen.dart';
import 'package:saborna_crkva/screens/pitajsvecenika_screen.dart';
import 'package:saborna_crkva/screens/zakazi_obred_screen.dart';

import '../main.dart';
import 'conversations_screen.dart';
import 'donacije_screen.dart';
import 'doniraj_screen.dart';
import 'korisni_linkovi_screen.dart';
import 'novosti_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _latinica = false;
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  void selectPismo(bool isLatinicaCheck) {
    _changeLanguage(isLatinicaCheck
        ? Language.languageList()[1]
        : Language.languageList()[0]);
  }

  Future<bool> isLatinica() async {
    var pismo = await getLocale();
    return pismo.languageCode == 'bs';
  }

  Widget _wSelectItems(
      String naslov, IconData ikona, Function funkcija, Size devSize) {
    return Material(
      color: Colors.white.withOpacity(0.0),
      child: InkWell(
        onTap: funkcija,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.only(bottom: 15),
          height: devSize.height * 0.15,
          width: devSize.width * 0.35 - 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ikona,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                naslov,
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _handleSendNotification() async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();

    //var playerId = status.subscriptionStatus.userId;
    var playerId = '94d71f36-794f-4b46-b2d7-4eaac3ba149d';

    var imgUrlString =
        "http://cdn1-www.dogtime.com/assets/uploads/gallery/30-impossibly-cute-puppies/impossibly-cute-puppy-2.jpg";

    var notification = OSCreateNotification(
        playerIds: [playerId],
        content: "this is a test from OneSignal's Flutter SDK",
        heading: "Test Notification",
        iosAttachments: {"id1": imgUrlString},
        bigPicture: imgUrlString,
        buttons: [
          OSActionButton(text: "test1", id: "id1"),
          OSActionButton(text: "test2", id: "id2")
        ]);

    var response = await OneSignal.shared.postNotification(notification);

    print("Sent notification with response: $response");
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final userData = Provider.of<Auth>(context, listen: false).user;
    return Scaffold(
      //backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text(getTranslated(context, 'home_naslov'),
            style: TextStyle(fontSize: 18)),
        //title: Text(getTranslated(context, 'about_us')),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(getTranslated(context, 'home_dobrodosliImePrezime') +
                  ' ' +
                  userData.username),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
              ),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text(getTranslated(context, 'poruke')),
              onTap: () => Navigator.of(context)
                  .popAndPushNamed(ConversationsScreen.routeName),
            ),
            if (Provider.of<Auth>(context).user.role.toLowerCase() ==
                'blagajnik')
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text(getTranslated(context, 'donacije')),
                onTap: () => Navigator.of(context)
                    .popAndPushNamed(DonacijeScreen.routeName),
              ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(getTranslated(context, 'odjavi_se')),
              onTap: () {
                Provider.of<Auth>(context, listen: false).logout();
              },
            ),
            FutureBuilder(
              future: getLocale(),
              builder: (ctx, AsyncSnapshot<Locale> futureSnapshot) {
                if(futureSnapshot.connectionState == ConnectionState.waiting) {
                  return Text('...');
                }
                else {
                  bool isLatinica = futureSnapshot.data.languageCode == 'bs';
                  return SwitchListTile(
                    activeColor: Colors.brown,
                    inactiveThumbColor: Colors.brown,
                    title: Text(getTranslated(context, 'promijeni_pismo')),
                    subtitle: !isLatinica ? Text('Ћирилица') : Text('Latinica'),
                    value: isLatinica,
                    onChanged: (value) {
                      selectPismo(value);
                      setState(() {
                        _latinica = value;
                      });
                    });
                }
              },
            ),
          ],
        ),
      ),
      body: Stack(children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: new BoxDecoration(
            color: const Color(0xff7c94b6),
            image: new DecorationImage(
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.2), BlendMode.dstATop),
              image: new AssetImage(
                'assets/images/main.jpg',
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _wSelectItems(
                      getTranslated(context, 'pitaj_svecenika'),
                      Icons.message,
                      () => Navigator.of(context)
                          .pushNamed(PitajSvecenikaScreen.routeName),
                      deviceSize),
                  _wSelectItems(
                      getTranslated(context, 'obavijesti'),
                      Icons.notifications,
                      () => Navigator.of(context)
                          .pushNamed(ObavjestenjaScreen.routeName),
                      deviceSize),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  userData.role.toLowerCase() == 'svecenik'
                      ? _wSelectItems(
                          getTranslated(context, 'obredi_zahtjevi'),
                          Icons.date_range,
                          () => Navigator.of(context)
                              .pushNamed(ObredZahtjeviScreen.routeName),
                          deviceSize)
                      : _wSelectItems(
                          getTranslated(context, 'zakazi_obred'),
                          Icons.date_range,
                          () => Navigator.of(context)
                              .pushNamed(ZakaziObredScreen.routeName),
                          deviceSize),
                  _wSelectItems(
                      getTranslated(context, 'novosti'),
                      Icons.photo_library,
                      () => Navigator.of(context)
                          .pushNamed(NovostiScreen.routeName),
                      deviceSize),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _wSelectItems(getTranslated(context, 'korisni_kontakti'),
                      Icons.contact_mail, () => Navigator.of(context).pushNamed(KorisniLinkoviScreen.routeName), deviceSize),
                  _wSelectItems(
                      getTranslated(context, 'doniraj'),
                      Icons.attach_money,
                      () => Navigator.of(context)
                          .pushNamed(DonirajScreen.routeName),
                      deviceSize),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
