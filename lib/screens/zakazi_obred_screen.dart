import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/providers/obredi.dart';

import 'obred_konverzacija.dart';
import 'obred_zahtjevi_screen.dart';

enum SingingCharacter { lafayette, jefferson }

class ZakaziObredScreen extends StatefulWidget {
  static const routeName = '/zakazi-obred';
  @override
  _ZakaziObredScreenState createState() => _ZakaziObredScreenState();
}

class _ZakaziObredScreenState extends State<ZakaziObredScreen> {
  //List<ObredKategorija> kategorije = [];
  var _odabranaKategorija = 1;
  bool _isLoading = true;
  int obredId;

  @override
  void initState() {
    print('initState');
    Provider.of<Obredi>(context, listen: false)
        .fetchAndSetObredKategorije()
        .then((value) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  Widget w_Category(String category, var value) {
    return Card(
      child: RadioListTile(
        title: Text(category),
        activeColor: Theme.of(context).primaryColor,
        value: value,
        groupValue: _odabranaKategorija,
        onChanged: (value) {
          setState(() {
            _odabranaKategorija = value;
          });
        },
      ),
    );
  }

  Future<void> zakaziObred() async {
    obredId = await Provider.of<Obredi>(context, listen: false).zakaziObred(Provider.of<Auth>(context, listen: false).user.id,_odabranaKategorija);
    Navigator.of(context).popAndPushNamed(ObredKonverzacijaScreen.routeName, arguments: obredId);
  }

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<Auth>(context, listen: false).user;
    print('zakazi obred build');
    return Scaffold(
      appBar: AppBar(
        title: Text('Zakaži obred'),
        actions: [
          FlatButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(ObredZahtjeviScreen.routeName, arguments: userData.id),
            icon: Icon(Icons.history),
            label: Text('Moji zahtjevi'),
            textColor: Colors.white,
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(top: 30),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Odaberite kategoriju', style: TextStyle(fontSize: 25)),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Consumer<Obredi>(
                    builder: (ctx, obredi, _) => Expanded(
                        child: ListView.builder(
                      itemCount: obredi.obrediKategorije.length,
                      itemBuilder: (ctx, index) => w_Category(
                          obredi.obrediKategorije[index].naziv,
                          obredi.obrediKategorije[index].id),
                    )),
                  ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 20, right: 20),
              child: RaisedButton(
                child: Text('ZAKAŽI'),
                color: Colors.green,
                textColor: Colors.white,
                onPressed: zakaziObred,
              ),
            )
          ],
        ),
      ),
    );
  }
}
