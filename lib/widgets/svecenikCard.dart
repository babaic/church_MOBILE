import 'package:flutter/material.dart';
import 'package:saborna_crkva/screens/svecenikporuka_screen.dart';

class SvecenikCard extends StatelessWidget {
  final String ime;
  final String prezime;
  final String id;
  SvecenikCard(this.ime, this.prezime, this.id);

  String get imePrezime {
    return ime+' '+prezime;
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => Navigator.of(context).pushNamed(SvecenikPorukaScreen.routeName, arguments: {'imePrezime': imePrezime, 'svecenikId': id}),
                icon: Icon(Icons.message),
                label: Text('Odaberi'))
          ],
        ),
      ),
    );
  }
}
