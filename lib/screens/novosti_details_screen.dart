import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/localization/language_constants.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/providers/novosti.dart';

class NovostiDetailsScreen extends StatelessWidget {
  static const routeName = '/novost-details';

  var id;
  var naslov;
  var glavnaSlika;
  var text;
  var datum;
  List<Uint8List> slike;

  final List<String> images = [
    'https://images.unsplash.com/photo-1586882829491-b81178aa622e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2850&q=80',
    'https://images.unsplash.com/photo-1586871608370-4adee64d1794?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2862&q=80',
    'https://images.unsplash.com/photo-1586901533048-0e856dff2c0d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
    'https://images.unsplash.com/photo-1586902279476-3244d8d18285?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2850&q=80',
    'https://images.unsplash.com/photo-1586943101559-4cdcf86a6f87?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1556&q=80',
    'https://images.unsplash.com/photo-1586951144438-26d4e072b891?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
    'https://images.unsplash.com/photo-1586953983027-d7508a64f4bb?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    //ModalRoute.of(context).settings.arguments as Map<String, Object>;
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    id = args['id'];
    naslov = args['naslov'];
    glavnaSlika = args['glavnaSlika'];
    text = args['text'];
    datum = args['datum'];

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'novost')),
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
                    future: Provider.of<Novosti>(context, listen: false)
                        .getImages(id, Provider.of<Auth>(context, listen: false).token),
                    builder: (ctx, futureSnapShot) {
                      if (futureSnapShot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorDark)),
                        );
                      }
                      var slikeData =
                          Provider.of<Novosti>(context, listen: false).slike;

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
                  //Divider(color: Colors.grey),
                  Column(
                    children: [
                      Text(
                        text,
                        style: TextStyle(fontSize: 15, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(getTranslated(context, 'objavljeno')+ DateFormat('dd.MM.yyyy hh:mm').format(DateTime.parse(datum)).toString(), textAlign: TextAlign.start, style: TextStyle(fontStyle: FontStyle.italic),),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
