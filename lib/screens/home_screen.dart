import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/screens/obavjestenja_screen.dart';
import 'package:saborna_crkva/screens/pitajsvecenika_screen.dart';

import 'conversations_screen.dart';
import 'novosti_screen.dart';

class HomeScreen extends StatelessWidget {
  Widget _wSelectItems(String naslov, IconData ikona, Function funkcija, Size devSize) {
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
          // height: 115,
          // width: 180,
          height: devSize.height * 0.15,
          width: devSize.width * 0.4,
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

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final userData = Provider.of<Auth>(context, listen: false).user;
    return Scaffold(
      //backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('Саборна црква Moctap',
            style:
                TextStyle(fontFamily: 'RuslanDisplay-Regular', fontSize: 18)),
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
              child: Text('Dobrodošli '+ userData.username),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
              ),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Poruke'),
              onTap: () => Navigator.of(context).popAndPushNamed(ConversationsScreen.routeName),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Odjavi se'),
              onTap: () {
                Provider.of<Auth>(context, listen: false).logout();
              },
            ),
          ],
        ),
      ),
      body: Stack(children: [
        Container(
          height: deviceSize.height,
          width: deviceSize.width,
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
          width: deviceSize.width,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _wSelectItems('Pitaj svećenika', Icons.message, () => Navigator.of(context).pushNamed(PitajSvecenikaScreen.routeName), deviceSize),
                  _wSelectItems('Obavijesti', Icons.notifications, () => Navigator.of(context).pushNamed(ObavjestenjaScreen.routeName), deviceSize),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _wSelectItems('Zakaži obred', Icons.date_range, null, deviceSize),
                  _wSelectItems('Novosti', Icons.photo_library, () => Navigator.of(context).pushNamed(NovostiScreen.routeName), deviceSize),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _wSelectItems('Korisni kontakti', Icons.contact_mail, null, deviceSize),
                  _wSelectItems('Doniraj', Icons.attach_money, null, deviceSize),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
