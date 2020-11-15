import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/obredi.dart';

import 'obred_konverzacija.dart';

class ObredZahtjeviScreen extends StatefulWidget {
  static const routeName = '/obredi-zahtjevi';

  @override
  _ObredZahtjeviScreenState createState() => _ObredZahtjeviScreenState();
}

class _ObredZahtjeviScreenState extends State<ObredZahtjeviScreen> {

  List<Status> statusi = [Status('Svi', true), Status('Nije odgovoreno', false), Status('Odgovoreno', false), Status('Zavrseno', false)];
  var selectedStatus = 'Svi';
  Widget w_IconToDisplay(String status) {
    if (status == 'Odgovoreno') {
      return Icon(Icons.check_circle, color: Colors.green);
    } else if (status == 'Nije odgovoreno') {
      return Icon(Icons.highlight_off, color: Colors.red);
    } else if (status == 'Zavrseno') {
      return Icon(Icons.lock);
    } else {
      return Icon(Icons.error);
    }
  }

  Widget w_ZahtjevCard(
      {String naziv,
      String imePrezime,
      String datum,
      String status,
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
                          imePrezime != null ? imePrezime : 'Nepoznat korisnik',
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
                Spacer(),
                Column(
                  children: [
                    w_IconToDisplay(status),
                    //status == 'Odgovoreno' ? Icon(Icons.check_circle,color: Colors.green) : Icon(Icons.remove_circle ,color: Colors.red),
                    Text(status)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('rebuild called obred_zahtjevi_screen');
    var args = ModalRoute.of(context).settings.arguments as int;
    return Scaffold(
        appBar: AppBar(
          title: Text('Obredi zahtjevi'),
          actions: [
            //FlatButton.icon(onPressed: () {}, icon: Icon(Icons.swap_vert), label: Text('Filter'), textColor: Colors.white,)
            PopupMenuButton<String>(
        icon: Icon(Icons.swap_vert),
        itemBuilder: (ctx) => statusi
            .map((status) => CheckedPopupMenuItem(
                  value: status.name,
                  child: Text(status.name),
                  checked: status.isSelected,
                ))
            .toList(),
        onSelected: (value) {
          print(value);
          setState(() {
            selectedStatus = value;
            var oldStatus = statusi.firstWhere((status) => status.isSelected);
            oldStatus.isSelected = false;
            var newStatus = statusi.firstWhere((status) => status.name == value);
            newStatus.isSelected = true;
          });
          //obavijest.changeSelectedCategory(value);
        },
      )
          ],
        ),
        body: FutureBuilder(
            future: Provider.of<Obredi>(context, listen: false).getObredi(args, selectedStatus),
            builder: (ctx, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColorDark)),
                );
              } else {
                return Consumer<Obredi>(builder: (ctx, obredData, _) {
                  if(obredData.obredi.length == 0) {
                    return Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network('https://img.icons8.com/cute-clipart/64/000000/search.png'),
                          Text('Nemate zahtjeva')
                        ],),
                    );
                  } 
                  return ListView.builder(
                      itemCount: obredData.obredi.length,
                      itemBuilder: (ctx, index) => w_ZahtjevCard(
                          naziv: obredData.obredi[index].naziv,
                          imePrezime: obredData.obredi[index].imePrezime,
                          datum: obredData.obredi[index].datum,
                          status: obredData.obredi[index].status == null
                              ? 'N/A'
                              : obredData.obredi[index].status,
                          id: obredData.obredi[index].id,
                          context: context));
                });
              }
            }));
  }
}

class Status {
  final String name;
  bool isSelected;
  Status(this.name, this.isSelected);
}
