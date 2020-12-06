import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/localization/language_constants.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/providers/obavijesti.dart';

class ObavijestiDetailsScreen extends StatelessWidget {
  static const routeName = '/obavijest-details';
  var id;
  var naslov;
  var glavnaSlika;
  var text;
  var datum;
  var kategorija;
  List<Uint8List> slike;
  
  @override
  Widget build(BuildContext context) {
    print('ObavijestiDetailsScreen build');
    final deviceSize = MediaQuery.of(context).size;
    //ModalRoute.of(context).settings.arguments as Map<String, Object>;
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    id = args['id'];
    naslov = args['naslov'];
    glavnaSlika = args['glavnaSlika'];
    text = args['text'];
    datum = args['datum'];
    kategorija = args['kategorija'];


    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'obavijest')),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder(
                    future: Provider.of<Obavijesti>(context, listen: false)
                        .getImages(id, Provider.of<Auth>(context, listen: false).token),
                    builder: (ctx, futureSnapShot) {
                      if (futureSnapShot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorDark)),
                        );
                      }
                      var slikeData =
                          Provider.of<Obavijesti>(context, listen: false).slike;

                      if (slikeData.length != 0) {
                        return Container(
                          child: CarouselSlider.builder(
                            itemCount: slikeData.length,
                            options: CarouselOptions(
                              height: 200,
                              autoPlay: true,
                              aspectRatio: 2.0,
                              enlargeCenterPage: true,
                            ),
                            itemBuilder: (context, index) {
                              return Container(
                                child: Center(
                                    child: Image.memory(slikeData[index],
                                        fit: BoxFit.cover, width: 1000)),
                              );
                            },
                          ),
                        );
                      }
                      else {
                        return Text('');
                      }
                    },
                  ),
                  Text(naslov, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20,),
                  Text(text, style: TextStyle(fontSize: 15, letterSpacing: 0.5),),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(getTranslated(context, 'objavljeno')+ DateFormat('dd.MM.yyyy hh:mm').format(DateTime.parse(datum)).toString(), textAlign: TextAlign.start, style: TextStyle(fontStyle: FontStyle.italic),),
                  ),
                  SizedBox(height: 20,),
                  Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.category, size: 50),
                                title: Text(getTranslated(context, 'kategorija')),
                                subtitle: Text(kategorija),
                              ),
                            ],
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}