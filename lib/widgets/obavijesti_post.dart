import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saborna_crkva/screens/obavijesti_details_screen.dart';

class ObavijestiPost extends StatelessWidget {
  final Uint8List glavnaSlika;
  // final List<Uint8List> slikeGalerija;
  final String naslov;
  final String datum;
  final int id;
  final String text;
  final String kategorija;
  final int kategorijaId;
  ObavijestiPost(this.glavnaSlika, this.naslov, this.datum, this.id, this.text,
      this.kategorija, this.kategorijaId);


  _wImage(Uint8List glavnaSlika) {
    if(glavnaSlika != null) {
      print('its null');
      return Image.memory(
                      glavnaSlika,
                      fit: BoxFit.cover,
                    );
    }
    else return Image.network(
                      'https://i.imgur.com/HjZLnil.png',
                      fit: BoxFit.cover,
                    );
  }
  
  @override
  Widget build(BuildContext context) {
    print('ObavijestiPost build');
    final deviceSize = MediaQuery.of(context).size;
    return Material(
      child: InkWell(
        onTap: () => Navigator.of(context)
            .pushNamed(ObavijestiDetailsScreen.routeName, arguments: {
          'id': id,
          'glavnaSlika': glavnaSlika,
          'naslov': naslov,
          'datum': datum,
          'text': text,
          'kategorija': kategorija
        }),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.only(bottom: 15),
                // height: 100,
                // width: 120,
                height: deviceSize.height * 0.20,
                width: deviceSize.width * 0.4,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: _wImage(glavnaSlika)),
              ),
              Expanded(
                child: Container(
                  //width: deviceSize.width * 0.5,
                  //height: deviceSize.height * 0.20,
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        naslov,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        softWrap: true,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(DateFormat('dd.MM.yyyy hh:mm')
                          .format(DateTime.parse(datum))
                          .toString()),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
