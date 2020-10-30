import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/globalVar.dart';
import 'package:saborna_crkva/providers/novosti.dart';
import 'package:saborna_crkva/widgets/novosti_post.dart';
import 'package:http/http.dart' as http;

class NovostiScreen extends StatefulWidget {
  static const routeName = '/novosti';

  @override
  _NovostiScreenState createState() => _NovostiScreenState();
}

class _NovostiScreenState extends State<NovostiScreen> {
  int pageNumber = 1;
  ScrollController _scrollController = new ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  void showInSnackBar(String value, int duration) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(value), duration: Duration(seconds: duration),));
  }
  

  @override
  void initState() {
    super.initState();
  
    _scrollController.addListener(() async {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if(pageNumber != Provider.of<Novosti>(context, listen: false).totalPage) {
          showInSnackBar('Učitavanje vijesti...', 20);
          try {
            var res = await Provider.of<Novosti>(context, listen: false).getNovosti(pageNumber: ++pageNumber);
          }
          catch (error) {

          }
          _scaffoldKey.currentState.hideCurrentSnackBar();
        }
        else {
          showInSnackBar('Nema više vijesti', 4);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Uint8List imageConvert(Uint8List image) {
    String _base64 = base64.encode(image);
     Uint8List bytes = base64.decode(_base64);
     return bytes;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Novosti'),
        actions: [
         
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<Novosti>(context, listen: false).getNovosti(pageNumber: 1),
        builder: (ctx, futureSnapshot) {
          if (futureSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorDark)),
            );
          } else {
            return Consumer<Novosti>(
                builder: (ctx, novostiData, child) => ListView.builder(
                    controller: _scrollController,
                    itemCount: novostiData.novosti.length,
                    itemBuilder: (ctx, index) {
                      Uint8List glavnaSlika = Base64Codec().decode(novostiData.novosti[index].glavnaSlika);
                      List<Uint8List> slikeGalerija = new List<Uint8List>();
                      if(novostiData.novosti[index].slike != null) {
                        novostiData.novosti[index].slike.forEach((slika) {
                          slikeGalerija.add(Base64Codec().decode(slika));
                        });
                      }

                      return NovostiPost(glavnaSlika, novostiData.novosti[index].naslov, novostiData.novosti[index].datum, novostiData.novosti[index].id, novostiData.novosti[index].text);
                    }));
          }
        },
      ),
    );
  }
}
