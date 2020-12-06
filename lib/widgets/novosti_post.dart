import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saborna_crkva/screens/novosti_details_screen.dart';

class NovostiPost extends StatelessWidget {
  final Uint8List glavnaSlika;
  // final List<Uint8List> slikeGalerija;
  final String naslov;
  final String datum;
  final int id;
  final String text;
  NovostiPost(this.glavnaSlika, this.naslov, this.datum, this.id, this.text);

  @override
  Widget build(BuildContext context) {
    print('NovostiPost build');
    final deviceSize = MediaQuery.of(context).size;
    return Material(
      child: InkWell(
        onTap: () => Navigator.of(context)
            .pushNamed(NovostiDetailsScreen.routeName, arguments: {
          'id': id,
          'glavnaSlika': glavnaSlika,
          'naslov': naslov,
          'datum': datum,
          'text': text
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
                // height: 115,
                // width: 180,
                height: deviceSize.height * 0.20,
                width: deviceSize.width * 0.4,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.memory(
                      glavnaSlika,
                      fit: BoxFit.cover,
                    )),
              ),
              Expanded(
                child: Container(
                  width: deviceSize.width * 0.5,
                  height: deviceSize.height * 0.20,
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
