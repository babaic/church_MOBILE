import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class KorisniLinkoviScreen extends StatelessWidget {
  static const routeName = '/korisni-linkovi';

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Korisni kontakti'),
      ),
      body: Center(
        child: Column(
          children: [
            ListTile(
              onTap: () => _launchURL('https://eparhija-zahumskohercegovacka.com/'),
              leading: Image.network(
                  'http://saborna-crkva-mostar.com/novav/wp-content/gallery/banneri/zahumlje.jpg'),
              title: Text('Епархија ЗХиП'),
            ),
            ListTile(
              onTap: () => _launchURL('https://www.tvrdos.com/'),
              leading: Image.network(
                  'http://saborna-crkva-mostar.com/novav/wp-content/uploads/2013/10/tvrdos.png'),
              title: Text('Подруми манастира Тврдош'),
            )
          ],
        ),
      ),
    );
  }
}
