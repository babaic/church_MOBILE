import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saborna_crkva/providers/auth.dart';
import 'package:saborna_crkva/providers/donacije.dart';

import 'doniraj_screen.dart';

class DonacijeScreen extends StatelessWidget {
  static const routeName = '/donacije';

  Widget w_Donacija(double amount, String poruka, String datum, String imePrezime) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        child: Padding(
          padding: EdgeInsets.all(6),
          child: FittedBox(
            child: Text('$amount KM'),
          ),
        ),
      ),
      title: Text(
        poruka.isEmpty ? '-' : poruka,
      ),
      subtitle: Text((imePrezime == null ? 'Nepoznati korisnik' : imePrezime) + ' - ' + DateFormat('dd.MM.yyyy').format(DateTime.parse(datum)).toString()),
    );
  }

  Widget w_NemaDonacija(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
            'assets/images/emptydonations.png'),
        Text(
          'Nemate donacija',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(
          height: 30,
        ),
        FlatButton(
          child: Text('Doniraj sada'),
          onPressed: () =>
              Navigator.of(context).popAndPushNamed(DonirajScreen.routeName),
          color: Colors.green[100],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //override id if user role is Blagajnik
    bool isBlagajnik = false;
    if(Provider.of<Auth>(context, listen: false).user.role.toLowerCase() == 'blagajnik') {
      isBlagajnik = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Donacije'),
      ),
      body: Container(
          width: double.infinity,
          child: FutureBuilder(
              future: Provider.of<Donacije>(context, listen: false)
                  .fetchAndSetDonacije(id: isBlagajnik ? null : Provider.of<Auth>(context, listen: false).user.id),
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColorDark)),
                  );
                } else {
                  var donacije =
                      Provider.of<Donacije>(context, listen: false).donacije;
                  if (donacije.length == 0) {
                    return w_NemaDonacija(context);
                  }
                  return ListView.builder(
                      itemCount: donacije.length,
                      itemBuilder: (ctx, index) => w_Donacija(
                          donacije[index].iznos,
                          donacije[index].poruka,
                          donacije[index].datum,
                          donacije[index].imePrezime
                          ));
                }
              })),
    );
  }
}
