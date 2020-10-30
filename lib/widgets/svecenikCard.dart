import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/screens/svecenikporuka_screen.dart';

class SvecenikCard extends StatelessWidget {
  final String ime;
  final String prezime;
  final String id;
  SvecenikCard(this.ime, this.prezime, this.id);

  final snackBar = SnackBar(content: Text('Ne možete sebi poslati poruku!'), backgroundColor: Colors.red,);

  String get imePrezime {
    return ime+' '+prezime;
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<Auth>(context, listen: false).user;
    return Card(
      margin: EdgeInsets.all(10),
      child: Container(
        height: 50,
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$ime $prezime'),
            FlatButton.icon(
                onPressed: () => userData.id.toString() == id ? Scaffold.of(context).showSnackBar(snackBar) : Navigator.of(context).pushNamed(SvecenikPorukaScreen.routeName, arguments: {'imePrezime': imePrezime, 'svecenikId': id}),
                icon: Icon(Icons.message),
                label: Text('Odaberi'))
          ],
        ),
      ),
    );
  }
}
