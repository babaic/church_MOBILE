import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/obredi.dart';

import 'obred_konverzacija.dart';

class ObredZahtjeviScreen extends StatelessWidget {
  static const routeName = '/obredi-zahtjevi';

  Widget w_ZahtjevCard(
      {String naziv,
      String imePrezime,
      String datum,
      int id,
      BuildContext context}) {
    return Material(
      child: InkWell(
        onTap: () => Navigator.of(context)
            .pushNamed(ObredKonverzacijaScreen.routeName, arguments: id),
        child: Card(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                            width: 80,
                            child: Text('Obred ',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Text(
                          naziv,
                          style: TextStyle(letterSpacing: 2),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                            width: 80,
                            child: Text(
                              'Korisnik ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        Text(
                          imePrezime,
                          style: TextStyle(letterSpacing: 2),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                            width: 80,
                            child: Text(
                              'Datum ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        Text(
                          DateFormat('dd.MM.yyyy hh:mm')
                              .format(DateTime.parse(datum))
                              .toString(),
                          style: TextStyle(letterSpacing: 2),
                        )
                      ],
                    )
                  ],
                ),
                // Spacer(),
                // Column(
                //   children: [
                //     Icon(
                //       Icons.check_circle,
                //       color: Colors.green,
                //     ),
                //     Text('Odgovoreno')
                //   ],
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context).settings.arguments as int;
    return Scaffold(
        appBar: AppBar(
          title: Text('Obredi zahtjevi'),
          actions: [
    
          ],
        ),
        body: FutureBuilder(
            future: Provider.of<Obredi>(context, listen: false).getObredi(args),
            builder: (ctx, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColorDark)),
                );
              }
              var obredi = Provider.of<Obredi>(context, listen: false).obredi;
              return ListView.builder(
                  itemCount: obredi.length,
                  itemBuilder: (ctx, index) => w_ZahtjevCard(
                      naziv: obredi[index].naziv,
                      imePrezime: obredi[index].imePrezime,
                      datum: obredi[index].datum,
                      id: obredi[index].id,
                      context: context));
            }));
  }
}
