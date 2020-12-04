import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../globalVar.dart';
import 'auth.dart';

class ObredKategorija {
  final int id;
  final String naziv;
  ObredKategorija({this.id, this.naziv});
}

class Obred {
  final int id;
  final String naziv;
  final String imePrezime;
  final String datum;
  String status;

  Obred({this.id, this.naziv, this.imePrezime, this.datum, this.status});
}

class Obredi with ChangeNotifier {
  List<ObredKategorija> obrediKategorije = [];
  List<Obred> _obredi = [];

  List<Obred> get obredi {
    return [..._obredi];
  }

  Future<void> fetchAndSetObredKategorije() async {
    var url = GlobalVar.apiUrl+'obredi/getobredikategorije';
    var response = await http.get(url);

    var extractData = json.decode(response.body);
    List<ObredKategorija> kategorijeToAdd = new List<ObredKategorija>();

    extractData.forEach((kategorija) {
      //print(kategorija);
      kategorijeToAdd.add(ObredKategorija(
       id: kategorija['id'],
       naziv: kategorija['naziv']
      ));
    });
    obrediKategorije = kategorijeToAdd;
    notifyListeners();
  }

  Future<int> zakaziObred(int userId, int obredKategorijaId, String token) async {
    var url = GlobalVar.apiUrl+'obredi/addobred';
    var response = await http.post(url, headers: GlobalVar.headersToken(token), body: json.encode({
      'userId': userId,
      'obredKategorijaId': obredKategorijaId
    }));

    var extractData = json.decode(response.body);
    print('extractData: $extractData');
    _obredi.forEach((element) {
      print(element.id);
    });

    return extractData['obredId'];

  }

  Future<void> getObredi(int userid, String status, String token) async {
    print('getObredi');
    var url = GlobalVar.apiUrl+'obredi/getobredi';

    Map<String, String> queryParams = {};
    if(userid != null) {
      queryParams['userid'] = userid.toString();
    }
    if(status != null && status != 'Svi') {
      queryParams['status'] = status;
    }
    
    var uri = new Uri.http(GlobalVar.apiUri, "/api/obredi/getobredi", queryParams);
    var response = await http.get(uri, headers: GlobalVar.headersToken(token));
    var extractedResult = json.decode(response.body) as List<dynamic>;
    List<Obred> obrediToAdd = new List<Obred>();
    extractedResult.forEach((obred) {
      obrediToAdd.add(Obred(
        id: obred['id'],
        naziv: obred['kategorija'],
        imePrezime: obred['imePrezime'],
        datum: obred['datum'],
        status: obred['status']
      ));
    });
    _obredi = obrediToAdd;
    notifyListeners();
}


  Future<void> updateStatus(int obredId, String status, String token) async {
    print('updateStatus');
    print('obredId: $obredId');
    print('status: $status');
    final obredIndex = _obredi.indexWhere((obred) => obred.id == obredId);
    var url = GlobalVar.apiUrl+'obredi/updatestatus/$obredId';

    var response = http.put(url, headers: GlobalVar.headersToken(token), body: json.encode({
      'status': status
    }));
    _obredi[obredIndex].status = status;

    notifyListeners();
  }

  bool isZavrsen(int obredId) {
    print('isZavrsen $obredId');
    var obredIndex = _obredi.indexWhere((element) => element.id == obredId);
    print('obredIndex: $obredIndex');
    //print(_obredi[obredIndex].status);
    if(obredIndex < 1) {
      return false;
    }
    return _obredi[obredIndex].status == 'Zavrseno';
  }

}