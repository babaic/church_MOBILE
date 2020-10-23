import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/screens/pitajsvecenika_screen.dart';

class HomeScreen extends StatelessWidget {
  Widget _wSelectItems(String naslov, IconData ikona, Function funkcija) {
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
          height: 115,
          width: 180,
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
              child: Text('Dobrodošli Ime i prezime'),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
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
              image: new NetworkImage(
                'https://sa-c.net/images/stories/MO_news/saborna_crkva/saborna_crkva_mostar_fasada.jpg',
              ),
            ),
          ),
          //child: Image.network('https://sa-c.net/images/stories/MO_news/saborna_crkva/saborna_crkva_mostar_fasada.jpg', fit: BoxFit.cover),
        ),
        Container(
          width: deviceSize.width,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _wSelectItems('Pitaj svećenika', Icons.message, () => Navigator.of(context).pushNamed(PitajSvecenikaScreen.routeName)),
                  _wSelectItems('Obavijesti', Icons.notifications, null),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _wSelectItems('Zakaži obred', Icons.date_range, null),
                  _wSelectItems('Novosti', Icons.photo_library, null),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _wSelectItems('Korisni kontakti', Icons.contact_mail, null),
                  _wSelectItems('Doniraj', Icons.attach_money, null),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
