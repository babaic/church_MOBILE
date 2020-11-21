import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/localization/language_constants.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/providers/svecenik.dart';
import 'package:saborna_crkva/widgets/svecenikCard.dart';

class PitajSvecenikaScreen extends StatefulWidget {
  static const routeName = '/pitaj-svecenika';
  @override
  _PitajSvecenikaScreenState createState() => _PitajSvecenikaScreenState();
}

class _PitajSvecenikaScreenState extends State<PitajSvecenikaScreen> {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<Auth>(context, listen: false).user;
    bool imeprezimeNull = userData.username == null;
    print(imeprezimeNull);
    return Scaffold(
        appBar: AppBar(
          title: Text(getTranslated(context, 'pitaj_svecenika')),
        ),
        body: imeprezimeNull ? Center(child: Text('Potrebno unijeti ime i prezime ukoliko želite postaviti pitanje svećeniku.', textAlign: TextAlign.center,),) : FutureBuilder(
          future: Provider.of<Svecenik>(context, listen: false).fetchAndSetSvecenici(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorDark),
              ));
            } else {
              return Consumer<Svecenik>(
                  builder: (ctx, svecenikData, child) => ListView.builder(
                      itemCount: svecenikData.svecenici.length,
                      itemBuilder: (ctx, index) => SvecenikCard(
                          svecenikData.svecenici[index].ime, svecenikData.svecenici[index].prezime, svecenikData.svecenici[index].id.toString())));
            }
          },
        ));
  }
}
