import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/localization/language_constants.dart';
import 'package:saborna_crkva/providers/obavijesti.dart';
import 'package:saborna_crkva/widgets/obavijesti_post.dart';

enum WhyFarther { harder, smarter, selfStarter, tradingCharter }

class ObavjestenjaScreen extends StatefulWidget {
  static const routeName = '/obavjestenja';

  @override
  _ObavjestenjaScreenState createState() => _ObavjestenjaScreenState();
}

class _ObavjestenjaScreenState extends State<ObavjestenjaScreen> {
  int pageNumber;
  int categoryId;
  ScrollController _scrollController = new ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value, int duration) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      duration: Duration(seconds: duration),
    ));
  }

  @override
  void initState() {
    super.initState();
    print('initState ObavjestenjaScreen');
    categoryId = 0;
    pageNumber = 1;

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (pageNumber !=
            Provider.of<Obavijesti>(context, listen: false).totalPage) {
          showInSnackBar(getTranslated(context, '_ucitavanjeObavijesti'), 20);
          try {
            var res = await Provider.of<Obavijesti>(context, listen: false)
                .getObavijesti(pageNumber: ++pageNumber, id: categoryId);
          } catch (error) {}
          _scaffoldKey.currentState.hideCurrentSnackBar();
        } else {
          showInSnackBar(getTranslated(context, '_nemaObavijesti'), 4);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _popup() {
    return Consumer<Obavijesti>(
      builder: (context, obavijest, _) => PopupMenuButton<int>(
        icon: Icon(Icons.category),
        itemBuilder: (ctx) => obavijest.kategorije
            .map((kategorija) => CheckedPopupMenuItem(
                  value: kategorija.kategorijaId,
                  child: Text(kategorija.naziv),
                  checked: kategorija.isSelected,
                ))
            .toList(),
        onSelected: (value) {
          setState(() {
            categoryId = value;
            pageNumber = 1;
          });
          obavijest.changeSelectedCategory(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('ObavjestenjaScreen build');
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(getTranslated(context, 'obavijesti')),
        actions: [
          _popup()
          //FlatButton.icon(onPressed: () => Provider.of<Obavijesti>(context, listen: false).getCategories(), icon: Icon(Icons.category), label: Text('ok'))
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<Obavijesti>(context, listen: false)
            .getObavijesti(pageNumber: 1, id: categoryId),
        builder: (ctx, futureSnapshot) {
          if (futureSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColorDark)),
            );
          } else {
            return Consumer<Obavijesti>(
                builder: (ctx, obavijestiData, child) => ListView.builder(
                    controller: _scrollController,
                    itemCount: obavijestiData.obavijesti.length,
                    itemBuilder: (ctx, index) {
                      Uint8List glavnaSlika = Base64Codec()
                          .decode(obavijestiData.obavijesti[index].glavnaSlika);
                      List<Uint8List> slikeGalerija = new List<Uint8List>();
                      if (obavijestiData.obavijesti[index].slike != null) {
                        obavijestiData.obavijesti[index].slike.forEach((slika) {
                          slikeGalerija.add(Base64Codec().decode(slika));
                        });
                      }

                      return ObavijestiPost(
                          glavnaSlika,
                          obavijestiData.obavijesti[index].naslov,
                          obavijestiData.obavijesti[index].datum,
                          obavijestiData.obavijesti[index].id,
                          obavijestiData.obavijesti[index].text,
                          obavijestiData.obavijesti[index].kategorija,
                          obavijestiData.obavijesti[index].kategorijaId);
                    }));
          }
        },
      ),
    );
  }
}
